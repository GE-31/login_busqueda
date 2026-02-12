/**
 * session-manager.js
 * 
 * Manejo de sesión del lado del cliente.
 * - Detecta actividad del usuario (clic, mouse, teclado, scroll, navegación).
 * - Renueva la sesión JWT cada vez que hay actividad (debounced a 1 min).
 * - Muestra advertencia cuando quedan 2 minutos de inactividad.
 * - Redirige a login cuando la sesión expira por inactividad.
 */
(function () {
    'use strict';

    const SESSION_TIMEOUT_MS = 20 * 60 * 1000;        // 20 minutos
    const WARNING_BEFORE_MS = 1 * 60 * 1000;          // Advertir 1 min antes (a los 19 min)
    const RENEW_DEBOUNCE_MS = 60 * 1000;              // Renovar máximo cada 1 minuto
    const CHECK_INTERVAL_MS = 10 * 1000;              // Verificar cada 10 segundos

    let lastActivity = Date.now();
    let lastRenew = 0;
    let warningShown = false;
    let sessionExpired = false;
    let warningModal = null;
    let countdownInterval = null;

    /**
     * Obtiene el contextPath del sistema.
     */
    function getContextPath() {
        const path = window.location.pathname;
        const parts = path.split('/');
        if (parts.length > 1 && parts[1]) {
            return '/' + parts[1];
        }
        return '';
    }

    /**
     * Registra actividad del usuario y renueva la sesión si corresponde.
     */
    function registrarActividad() {
        if (sessionExpired) return;

        lastActivity = Date.now();

        // Ocultar advertencia y detener cuenta regresiva
        if (warningShown) {
            if (countdownInterval) {
                clearInterval(countdownInterval);
                countdownInterval = null;
            }
            ocultarAdvertencia();
        }

        // Renovar sesión con debounce (máximo cada 1 minuto)
        const ahora = Date.now();
        if (ahora - lastRenew >= RENEW_DEBOUNCE_MS) {
            lastRenew = ahora;
            renovarSesion();
        }
    }
 
    /**
     * Llama al endpoint de renovación de sesión.
     */
    function renovarSesion() {
        const contextPath = getContextPath();

        fetch(contextPath + '/api/session/renew', {
            method: 'POST',
            credentials: 'same-origin',
            headers: {
                'Content-Type': 'application/json'
            }
        })
        .then(function (response) {
            if (!response.ok) {
                // Sesión expirada en el servidor
                manejarExpiracion();
            }
        })
        .catch(function (error) {
            console.warn('Error al renovar sesión:', error);
        });
    }

    /**
     * Verifica periódicamente si la sesión debe expirar por inactividad.
     */
    function verificarInactividad() {
        if (sessionExpired) return;

        const tiempoInactivo = Date.now() - lastActivity;

        // Si ha pasado el tiempo total → sesión expirada
        if (tiempoInactivo >= SESSION_TIMEOUT_MS) {
            manejarExpiracion();
            return;
        }

        // Si queda poco tiempo → mostrar advertencia
        if (tiempoInactivo >= (SESSION_TIMEOUT_MS - WARNING_BEFORE_MS) && !warningShown) {
            const segundosRestantes = Math.ceil((SESSION_TIMEOUT_MS - tiempoInactivo) / 1000);
            mostrarAdvertencia(segundosRestantes);
        }
    }

    /**
     * Maneja la expiración de la sesión.
     * Llama al endpoint /logout para eliminar la cookie AUTH_TOKEN,
     * invalidar la sesión HTTP y redirigir al login.
     */
    function manejarExpiracion() {
        sessionExpired = true;
        const contextPath = getContextPath();

        // Detener cuenta regresiva si estaba activa
        if (countdownInterval) {
            clearInterval(countdownInterval);
            countdownInterval = null;
        }

        // Ocultar advertencia si estaba visible
        if (warningModal) {
            warningModal.remove();
            warningModal = null;
        }

        // Mostrar modal de sesión expirada
        const modal = document.createElement('div');
        modal.id = 'session-expired-modal';
        modal.innerHTML = 
            '<div style="position:fixed;top:0;left:0;width:100%;height:100%;' +
            'background:rgba(0,0,0,0.6);display:flex;align-items:center;' +
            'justify-content:center;z-index:99999;">' +
            '<div style="background:#fff;border-radius:12px;padding:32px;' +
            'max-width:400px;text-align:center;box-shadow:0 8px 32px rgba(0,0,0,0.2);">' +
            '<div style="font-size:48px;margin-bottom:16px;">⏰</div>' +
            '<h3 style="margin:0 0 8px;color:#1a1a2e;font-size:20px;">' +
            'Sesión expirada</h3>' +
            '<p style="color:#666;margin:0 0 24px;font-size:14px;">' +
            'Tu sesión ha expirado por inactividad.<br>Serás redirigido al inicio de sesión.</p>' +
            '<button onclick="window.location.href=\'' + contextPath + '/login\'" ' +
            'style="background:#4361ee;color:#fff;border:none;padding:10px 32px;' +
            'border-radius:8px;font-size:14px;cursor:pointer;font-weight:500;">' +
            'Ir a Iniciar Sesión</button></div></div>';

        document.body.appendChild(modal);

        // Llamar al endpoint /logout para eliminar cookie y cerrar sesión en el servidor
        fetch(contextPath + '/logout', {
            method: 'GET',
            credentials: 'same-origin'
        }).finally(function () {
            // Redirigir automáticamente después de 3 segundos
            setTimeout(function () {
                window.location.href = contextPath + '/login';
            }, 3000);
        });
    }

    /**
     * Muestra la advertencia con cuenta regresiva en tiempo real.
     */
    function mostrarAdvertencia(segundosRestantes) {
        warningShown = true;

        warningModal = document.createElement('div');
        warningModal.id = 'session-warning-modal';
        warningModal.innerHTML = generarHTMLAdvertencia(segundosRestantes);
        document.body.appendChild(warningModal);

        // Cuenta regresiva actualizada cada segundo
        var segsRestantes = segundosRestantes;
        countdownInterval = setInterval(function () {
            segsRestantes--;
            if (segsRestantes <= 0 || sessionExpired) {
                clearInterval(countdownInterval);
                countdownInterval = null;
                return;
            }
            if (warningModal) {
                warningModal.innerHTML = generarHTMLAdvertencia(segsRestantes);
            }
        }, 1000);
    }

    /**
     * Genera el HTML de la advertencia con los segundos restantes.
     */
    function generarHTMLAdvertencia(segundos) {
        var texto;
        if (segundos >= 60) {
            var minutos = Math.ceil(segundos / 60);
            texto = minutos + ' minuto' + (minutos > 1 ? 's' : '');
        } else {
            texto = segundos + ' segundo' + (segundos > 1 ? 's' : '');
        }
        return '<div style="position:fixed;top:20px;right:20px;z-index:99998;' +
            'background:#fff3cd;border:1px solid #ffc107;border-radius:10px;' +
            'padding:16px 20px;max-width:320px;box-shadow:0 4px 12px rgba(0,0,0,0.15);' +
            'display:flex;align-items:center;gap:12px;">' +
            '<span style="font-size:24px;">⚠️</span>' +
            '<div><strong style="color:#856404;font-size:14px;">Sesión por expirar</strong>' +
            '<p style="margin:4px 0 0;color:#856404;font-size:13px;">' +
            'Tu sesión expirará en <strong>' + texto + '</strong> por inactividad. ' +
            'Realiza cualquier acción para mantenerla activa.</p></div></div>';
    }

    /**
     * Oculta la advertencia de sesión.
     */
    function ocultarAdvertencia() {
        warningShown = false;
        if (warningModal) {
            warningModal.remove();
            warningModal = null;
        }
    }

    // =================== INICIALIZACIÓN ===================

    // Eventos de actividad del usuario
    var eventos = ['click', 'mousemove', 'keydown', 'keypress', 'scroll', 'touchstart'];
    eventos.forEach(function (evento) {
        document.addEventListener(evento, registrarActividad, { passive: true });
    });

    // Verificar inactividad periódicamente
    setInterval(verificarInactividad, CHECK_INTERVAL_MS);

    // Renovar sesión al cargar la página (confirma que el token es válido)
    renovarSesion();

})();
