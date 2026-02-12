// Variables globales
let modoEdicion = false;
let paginaActualUsr = 1;
const registrosPorPaginaUsr = 5;

// === BÚSQUEDA POR NOMBRE/APELLIDO ===
function filtrarUsuarios() {
    const texto = document.getElementById('buscarUsuario').value.trim().toLowerCase();
    const tbody = document.getElementById('usuarios-tbody');
    if (!tbody) return;

    const filas = Array.from(tbody.querySelectorAll('tr.usuario-row'));

    filas.forEach(fila => {
        const nombres = (fila.getAttribute('data-nombres') || '').toLowerCase();
        const apellidos = (fila.getAttribute('data-apellidos') || '').toLowerCase();
        const coincide = !texto || nombres.includes(texto) || apellidos.includes(texto);
        fila.classList.toggle('filtrado-oculto', !coincide);
    });

    paginaActualUsr = 1;
    aplicarPaginacionUsr();
}

// Abrir modal para crear usuario
function abrirModalCrear() {
    modoEdicion = false;

    document.getElementById('modalTitulo').textContent = 'Crear Usuario';
    document.getElementById('formUsuario').reset();
    document.getElementById('usuarioId').value = '';

    document.getElementById('password').required = true;
    document.getElementById('confirmPassword').required = true;

    document.getElementById('modalUsuario').style.display = 'flex';
    document.body.style.overflow = 'hidden';
}

// Abrir modal para editar usuario
function abrirModalEditar(id) {
    modoEdicion = true;
    document.getElementById('modalTitulo').textContent = 'Editar Usuario';

    fetch(`usuarios?action=obtener&id=${id}`)
        .then(res => res.json())
        .then(usuario => {
            document.getElementById('usuarioId').value = usuario.idUsuario;
            document.getElementById('username').value = usuario.username;
            document.getElementById('rolSistema').value = usuario.rolSistema || '';
            document.getElementById('voluntarioId').value = usuario.idVoluntario || '';

            document.getElementById('password').required = false;
            document.getElementById('confirmPassword').required = false;

            document.getElementById('modalUsuario').style.display = 'flex';
            document.body.style.overflow = 'hidden';
        })
        .catch(err => {
            console.error(err);
            alert('Error al cargar el usuario');
        });
}

// Cerrar modal
function cerrarModal() {
    document.getElementById('modalUsuario').style.display = 'none';
    document.body.style.overflow = 'auto';
}


// Buscar datos por DNI desde API
async function buscarDNI() {
    const dni = document.getElementById('dni')?.value;

    if (!dni) {
        mostrarNotificacion('Ingresa un DNI primero', 'warning');
        return;
    }

    const datos = await buscarDNIEnAPI(dni);

    if (datos) {
        console.log('Datos completos de la API:', datos);
        console.log('Claves disponibles:', Object.keys(datos));

        // Llenar NOMBRES
        let nombreCompleto = '';
        if (datos.nombres) {
            nombreCompleto = datos.nombres;
            document.getElementById('nombres').value = nombreCompleto;
            console.log('✓ Nombres llenado:', nombreCompleto);
        }

        // Llenar APELLIDOS - Intentar múltiples estrategias
        let apellidoCompleto = '';

        // Estrategia 1: Buscar campos específicos de apellido (snake_case y camelCase)
        if ((datos.apellido_paterno && datos.apellido_materno) || (datos.apellidoPaterno && datos.apellidoMaterno)) {
            apellidoCompleto = `${datos.apellido_paterno || datos.apellidoPaterno} ${datos.apellido_materno || datos.apellidoMaterno}`.trim();
            console.log('✓ Apellidos llenado (estrategia 1):', apellidoCompleto);
        }
        // Estrategia 2: Campo apellidos unificado
        else if (datos.apellidos) {
            apellidoCompleto = datos.apellidos;
            console.log('✓ Apellidos llenado (estrategia 2):', apellidoCompleto);
        }
        // Estrategia 3: Campo apellido singular
        else if (datos.apellido) {
            apellidoCompleto = datos.apellido;
            console.log('✓ Apellidos llenado (estrategia 3):', apellidoCompleto);
        }

        if (apellidoCompleto) {
            document.getElementById('apellidos').value = apellidoCompleto;
        }

        // Llenar CORREO - Soportar múltiples claves
        let correo = '';
        if (datos.correo) {
            correo = datos.correo;
        } else if (datos.email) {
            correo = datos.email;
        } else if (datos.mail) {
            correo = datos.mail;
        }

        if (correo) {
            document.getElementById('correo').value = correo;
            console.log('✓ Correo llenado:', correo);
        }

        // Generar username automáticamente si es posible
        const nombres = document.getElementById('nombres').value;
        if (nombres) {
            const usernameGenerado = nombres.toLowerCase().replace(/\s+/g, '_') + '_' + dni.slice(-4);
            document.getElementById('username').value = usernameGenerado;
            console.log('✓ Username generado:', usernameGenerado);
        }

        mostrarNotificacion('DNI ENCONTRADO OK', 'success');
    }
}


function guardarUsuario(event) {
    event.preventDefault();

    // Obtener valores del formulario
    const id = document.getElementById('usuarioId').value;
    const voluntarioId = document.getElementById("voluntarioId").value;
    const username = document.getElementById("username").value;
    const rolSistema = document.getElementById("rolSistema").value;
    const password = document.getElementById("password").value;
    const confirmPassword = document.getElementById("confirmPassword").value;

    // Validaciones
    if (!voluntarioId || voluntarioId === '') {
        alert('Debes seleccionar un voluntario');
        return;
    }

    if (!username || username.trim() === '') {
        alert('El nombre de usuario es requerido');
        return;
    }

    if (!rolSistema || rolSistema.trim() === '') {
        alert('El rol del sistema es requerido');
        return;
    }

    // Validar contraseña solo al crear
    if (!id) {
        if (!password || password.length < 6) {
            alert('La contraseña debe tener al menos 6 caracteres');
            return;
        }
        if (password !== confirmPassword) {
            alert('Las contraseñas no coinciden');
            return;
        }
    } else {
        // Al editar, validar solo si se ingresó nueva contraseña
        if (password && password.length > 0) {
            if (password.length < 6) {
                alert('La contraseña debe tener al menos 6 caracteres');
                return;
            }
            if (password !== confirmPassword) {
                alert('Las contraseñas no coinciden');
                return;
            }
        }
    }

    // Crear parámetros
    const params = new URLSearchParams();
    params.append("action", id ? "editar" : "crear");
    if (id) params.append("id", id);
    params.append("voluntarioId", voluntarioId);
    params.append("username", username);
    params.append("rolSistema", rolSistema);
    if (password) params.append("password", password);

    console.log("► Enviando parámetros:", {
        action: id ? "editar" : "crear",
        voluntarioId: voluntarioId,
        username: username,
        rolSistema: rolSistema
    });

    fetch("usuarios", {
        method: "POST",
        headers: {
            "Content-Type": "application/x-www-form-urlencoded"
        },
        body: params.toString()
    })
        .then(response => response.text())
        .then(text => {
            console.log("RESPUESTA SERVIDOR (guardar):", text);

            if (!text || text.trim() === "") {
                throw new Error("El servidor devolvió vacío.");
            }
            return JSON.parse(text);
        })
        .then(result => {
            if (result.success) {
                cerrarModal();
                cargarUsuarios();
                mostrarNotificacion(result.message, 'success');
            } else {
                mostrarNotificacion(result.message || 'Error desconocido', 'error');
            }
        })
        .catch(error => {
            console.error('Error:', error);
            mostrarNotificacion('Error al guardar el usuario', 'error');
        });
}

// Cambiar estado del usuario
function cambiarEstado(id, nuevoEstado) {
    if (!confirm(`¿Confirmar cambio de estado a ${nuevoEstado}?`)) return;

    const params = new URLSearchParams();
    params.append("action", "cambiar_estado");
    params.append("id", id);
    params.append("estado", nuevoEstado);

    fetch("usuarios", {
        method: "POST",
        headers: {
            "Content-Type": "application/x-www-form-urlencoded"
        },
        body: params.toString()
    })
        .then(response => response.json())
        .then(result => {
            if (result.success) {
                cargarUsuarios();
                mostrarNotificacion(result.message, 'success');
            } else {
                mostrarNotificacion(result.message || 'Error', 'error');
            }
        })
        .catch(error => {
            console.error('Error:', error);
            mostrarNotificacion('Error al cambiar estado', 'error');
        });
}

// Confirmar eliminación (DESHABILITADO) - se usa deshabilitar en su lugar
function confirmarEliminar(id, nombre) {
    mostrarNotificacion('Operación no permitida: eliminar usuarios está desactivado. Usa Deshabilitar.', 'warning');
}

// Eliminar usuario (DESHABILITADO)
function eliminarUsuario(id) {
    mostrarNotificacion('Operación no permitida: eliminar usuarios está desactivado. Usa Deshabilitar.', 'warning');
}

// Cargar usuarios
function cargarUsuarios() {
    location.reload();
}

// === PAGINACIÓN USUARIOS ===
function aplicarPaginacionUsr() {
    const tbody = document.getElementById('usuarios-tbody');
    if (!tbody) return;

    const filas = Array.from(tbody.querySelectorAll('tr.usuario-row:not(.filtrado-oculto)'));
    // Ocultar filas filtradas explícitamente
    tbody.querySelectorAll('tr.usuario-row.filtrado-oculto').forEach(f => f.style.display = 'none');

    const totalRegistros = filas.length;
    const totalPaginas = Math.ceil(totalRegistros / registrosPorPaginaUsr) || 1;

    // Ocultar fila "No hay usuarios" si hay registros
    const sinDatosRow = document.getElementById('sinUsuariosRow');
    if (sinDatosRow) sinDatosRow.style.display = totalRegistros > 0 ? 'none' : '';

    // También ocultar cualquier fila sin clase usuario-row
    tbody.querySelectorAll('tr:not(.usuario-row)').forEach(f => {
        f.style.display = totalRegistros > 0 ? 'none' : '';
    });

    // Mostrar/ocultar paginación
    const paginacionEl = document.getElementById('paginacionUsuarios');
    if (paginacionEl) {
        paginacionEl.style.display = totalRegistros > 0 ? '' : 'none';
    }
    if (totalRegistros === 0) return;

    if (paginaActualUsr > totalPaginas) paginaActualUsr = totalPaginas;
    if (paginaActualUsr < 1) paginaActualUsr = 1;

    const inicio = (paginaActualUsr - 1) * registrosPorPaginaUsr;
    const fin = inicio + registrosPorPaginaUsr;

    filas.forEach((fila, index) => {
        fila.style.display = (index >= inicio && index < fin) ? '' : 'none';
    });

    // Actualizar info
    const infoEl = document.getElementById('paginacionInfoUsr');
    if (infoEl) {
        const desde = inicio + 1;
        const hasta = Math.min(fin, totalRegistros);
        infoEl.innerHTML = 'Mostrando <strong>' + desde + '-' + hasta + '</strong> de <strong>' + totalRegistros + '</strong> usuarios';
    }

    // Botones prev/next
    const btnPrev = document.getElementById('btnPrevUsr');
    const btnNext = document.getElementById('btnNextUsr');
    if (btnPrev) btnPrev.disabled = paginaActualUsr <= 1;
    if (btnNext) btnNext.disabled = paginaActualUsr >= totalPaginas;

    // Números de página
    const pagesContainer = document.getElementById('paginacionPagesUsr');
    if (pagesContainer) {
        pagesContainer.innerHTML = '';
        for (let i = 1; i <= totalPaginas; i++) {
            const btn = document.createElement('button');
            btn.textContent = i;
            btn.style.cssText = 'width:36px; height:36px; border:1px solid #e5e7eb; border-radius:8px; font-size:0.85rem; font-weight:500; cursor:pointer; display:flex; align-items:center; justify-content:center;';
            if (i === paginaActualUsr) {
                btn.style.background = 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)';
                btn.style.color = '#fff';
                btn.style.borderColor = 'transparent';
                btn.style.boxShadow = '0 3px 10px rgba(102,126,234,0.4)';
            } else {
                btn.style.background = '#fff';
                btn.style.color = '#4b5563';
            }
            btn.onclick = () => { paginaActualUsr = i; aplicarPaginacionUsr(); };
            pagesContainer.appendChild(btn);
        }
    }

    // Estilo botones disabled
    if (btnPrev) btnPrev.style.opacity = btnPrev.disabled ? '0.35' : '1';
    if (btnNext) btnNext.style.opacity = btnNext.disabled ? '0.35' : '1';
}

function cambiarPaginaUsr(direccion) {
    paginaActualUsr += direccion;
    aplicarPaginacionUsr();
}

// Inicializar paginación al cargar la página
document.addEventListener('DOMContentLoaded', function() {
    aplicarPaginacionUsr();
});

// Mostrar notificación
function mostrarNotificacion(mensaje, tipo) {
    let notif = document.getElementById('notificacion');

    if (!notif) {
        notif = document.createElement('div');
        notif.id = 'notificacion';
        document.body.appendChild(notif);
    }

    notif.textContent = mensaje;
    notif.className = `notificacion ${tipo} show`;

    setTimeout(() => {
        notif.classList.remove('show');
    }, 3000);
}

// Cerrar modal cuando se presiona Escape
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        cerrarModal();
    }
});

// Cerrar modal al hacer clic fuera
document.addEventListener('click', (e) => {
    const modal = document.getElementById('modalUsuario');
    if (e.target === modal) {
        cerrarModal();
    }
});

function initPermisos() {
    const checkboxes = document.querySelectorAll(".perm");

    checkboxes.forEach(ch => {
        ch.addEventListener("change", () => {
            actualizarContadores();
        });
    });

    const selects = document.querySelectorAll(".select-all");
    selects.forEach(s => {
        s.addEventListener("change", () => {
            let grupo = s.dataset.group;
            let lista = document.querySelectorAll(`.perm[data-group="${grupo}"]`);
            lista.forEach(c => c.checked = s.checked);
            actualizarContadores();
        });
    });
}

function actualizarContadores() {
    const grupos = ["personas", "catalogo", "operaciones", "agendas"];

    let total = 0;

    grupos.forEach(g => {
        let items = document.querySelectorAll(`.perm[data-group="${g}"]`);
        let marcados = document.querySelectorAll(`.perm[data-group="${g}"]:checked`);

        document.getElementById(`count-${g}`).innerText = `${marcados.length}/${items.length}`;

        if (marcados.length === items.length) {
            document.querySelector(`.select-all[data-group="${g}"]`).checked = true;
        } else {
            document.querySelector(`.select-all[data-group="${g}"]`).checked = false;
        }

        total += marcados.length;
    });

    document.getElementById("contadorPermisos").innerText = `${total} permisos seleccionados`;
}

document.addEventListener("DOMContentLoaded", initPermisos);
