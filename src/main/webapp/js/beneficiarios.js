// ══════════════════════════════════════════════════
//  BENEFICIARIOS — JS
// ══════════════════════════════════════════════════

let modoEdicion = false;
let paginaActualBen = 1;
const registrosPorPaginaBen = 6;

// === BÚSQUEDA POR NOMBRE/APELLIDO ===
function filtrarBeneficiarios() {
    const texto = document.getElementById('buscarBeneficiario').value.trim().toLowerCase();
    const tbody = document.getElementById('beneficiarios-tbody');
    if (!tbody) return;

    const filas = Array.from(tbody.querySelectorAll('tr.beneficiario-row'));
    filas.forEach(fila => {
        const nombres = (fila.getAttribute('data-nombres') || '').toLowerCase();
        const apellidos = (fila.getAttribute('data-apellidos') || '').toLowerCase();
        const coincide = !texto || nombres.includes(texto) || apellidos.includes(texto);
        fila.classList.toggle('filtrado-oculto', !coincide);
    });

    paginaActualBen = 1;
    aplicarPaginacionBen();
}

// ── ABRIR MODAL CREAR ──────────────────────────
function abrirModalCrear() {
    modoEdicion = false;
    document.getElementById('modalTitulo').textContent = 'Nuevo Beneficiario';
    document.getElementById('btnGuardarTexto').textContent = 'Registrar Beneficiario';
    document.getElementById('formBeneficiario').reset();
    document.getElementById('beneficiarioId').value = '';
    document.getElementById('modalBeneficiario').style.display = 'flex';
    document.body.style.overflow = 'hidden';
}

// ── ABRIR MODAL EDITAR ─────────────────────────
function abrirModalEditar(id) {
    modoEdicion = true;
    document.getElementById('modalTitulo').textContent = 'Editar Beneficiario';
    document.getElementById('btnGuardarTexto').textContent = 'Guardar Cambios';

    fetch(`beneficiarios?action=obtener&id=${id}`)
        .then(r => r.text())
        .then(text => {
            if (!text || text.trim() === '') throw new Error('Respuesta vacía');
            return JSON.parse(text);
        })
        .then(b => {
            document.getElementById('beneficiarioId').value     = b.idBeneficiario;
            document.getElementById('nombres').value             = b.nombres || '';
            document.getElementById('apellidos').value           = b.apellidos || '';
            document.getElementById('dni').value                 = b.dni || '';
            document.getElementById('fechaNacimiento').value     = b.fechaNacimiento || '';
            document.getElementById('telefono').value            = b.telefono || '';
            document.getElementById('direccion').value           = b.direccion || '';
            document.getElementById('distrito').value            = b.distrito || '';
            document.getElementById('tipoBeneficiario').value    = b.tipoBeneficiario || 'INDIVIDUAL';
            document.getElementById('necesidadPrincipal').value  = b.necesidadPrincipal || 'OTRO';
            document.getElementById('observaciones').value       = b.observaciones || '';

            document.getElementById('modalBeneficiario').style.display = 'flex';
            document.body.style.overflow = 'hidden';
        })
        .catch(err => {
            console.error(err);
            mostrarNotificacion('Error al cargar el beneficiario', 'error');
        });
}

// ── CERRAR MODAL ───────────────────────────────
function cerrarModal() {
    document.body.style.overflow = 'auto';
    document.getElementById('modalBeneficiario').style.display = 'none';
}

// ── CERRAR MODAL DETALLE ───────────────────────
function cerrarModalDetalle() {
    document.body.style.overflow = 'auto';
    document.getElementById('modalDetalle').style.display = 'none';
}

// ── VER DETALLE ────────────────────────────────
function verDetalle(id) {
    fetch(`beneficiarios?action=obtener&id=${id}`)
        .then(r => r.text())
        .then(text => {
            if (!text || text.trim() === '') throw new Error('Respuesta vacía');
            return JSON.parse(text);
        })
        .then(b => {
            document.getElementById('detalleSubtitulo').textContent =
                (b.nombres || '') + ' ' + (b.apellidos || '');

            const body = document.getElementById('detalleBody');
            body.innerHTML = `
                <div class="detalle-grid">
                    <div class="detalle-item">
                        <span class="detalle-label">Nombres</span>
                        <span class="detalle-valor">${b.nombres || '—'}</span>
                    </div>
                    <div class="detalle-item">
                        <span class="detalle-label">Apellidos</span>
                        <span class="detalle-valor">${b.apellidos || '—'}</span>
                    </div>
                    <div class="detalle-item">
                        <span class="detalle-label">DNI</span>
                        <span class="detalle-valor">${b.dni || '—'}</span>
                    </div>
                    <div class="detalle-item">
                        <span class="detalle-label">Fecha de Nacimiento</span>
                        <span class="detalle-valor">${b.fechaNacimiento || '—'}</span>
                    </div>
                    <div class="detalle-item">
                        <span class="detalle-label">Teléfono</span>
                        <span class="detalle-valor">${b.telefono || '—'}</span>
                    </div>
                    <div class="detalle-item">
                        <span class="detalle-label">Distrito</span>
                        <span class="detalle-valor">${b.distrito || '—'}</span>
                    </div>
                    <div class="detalle-item full-width">
                        <span class="detalle-label">Dirección</span>
                        <span class="detalle-valor">${b.direccion || '—'}</span>
                    </div>
                    <div class="detalle-item">
                        <span class="detalle-label">Tipo</span>
                        <span class="detalle-valor">${b.tipoBeneficiario || '—'}</span>
                    </div>
                    <div class="detalle-item">
                        <span class="detalle-label">Necesidad Principal</span>
                        <span class="detalle-valor">${b.necesidadPrincipal || '—'}</span>
                    </div>
                    <div class="detalle-item">
                        <span class="detalle-label">Estado</span>
                        <span class="detalle-valor">
                            <span class="estado-badge ${b.estado === 'ACTIVO' ? 'activo' : 'inactivo'}">${b.estado}</span>
                        </span>
                    </div>
                    <div class="detalle-item">
                        <span class="detalle-label">Registrado</span>
                        <span class="detalle-valor">${b.creadoEn || '—'}</span>
                    </div>
                    <div class="detalle-item full-width">
                        <span class="detalle-label">Observaciones</span>
                        <span class="detalle-valor">${b.observaciones || 'Sin observaciones'}</span>
                    </div>
                </div>
            `;

            document.getElementById('modalDetalle').style.display = 'flex';
            document.body.style.overflow = 'hidden';
        })
        .catch(err => {
            console.error(err);
            mostrarNotificacion('Error al cargar el detalle', 'error');
        });
}

// ── GUARDAR (CREAR / EDITAR) ───────────────────
function guardarBeneficiario(event) {
    event.preventDefault();

    const id                = document.getElementById('beneficiarioId').value;
    const nombres           = document.getElementById('nombres').value;
    const apellidos         = document.getElementById('apellidos').value;
    const dni               = document.getElementById('dni').value;
    const fechaNacimiento   = document.getElementById('fechaNacimiento').value;
    const telefono          = document.getElementById('telefono').value;
    const direccion         = document.getElementById('direccion').value;
    const distrito          = document.getElementById('distrito').value;
    const tipoBeneficiario  = document.getElementById('tipoBeneficiario').value;
    const necesidadPrincipal = document.getElementById('necesidadPrincipal').value;
    const observaciones     = document.getElementById('observaciones').value;

    const params = new URLSearchParams();
    params.append('action', id ? 'editar' : 'crear');
    if (id) params.append('id', id);
    params.append('nombres', nombres);
    params.append('apellidos', apellidos);
    params.append('dni', dni);
    params.append('fechaNacimiento', fechaNacimiento);
    params.append('telefono', telefono);
    params.append('direccion', direccion);
    params.append('distrito', distrito);
    params.append('tipoBeneficiario', tipoBeneficiario);
    params.append('necesidadPrincipal', necesidadPrincipal);
    params.append('observaciones', observaciones);

    fetch('beneficiarios', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: params.toString()
    })
    .then(r => r.text())
    .then(text => {
        if (!text || !text.trim()) throw new Error('Respuesta vacía');
        return JSON.parse(text);
    })
    .then(result => {
        if (result.success) {
            cerrarModal();
            cargarBeneficiarios();
            mostrarNotificacion(result.message, 'success');
        } else {
            mostrarNotificacion(result.message, 'error');
        }
    })
    .catch(err => {
        console.error(err);
        mostrarNotificacion('Error al guardar el beneficiario', 'error');
    });
}

// ── CAMBIAR ESTADO ─────────────────────────────
function cambiarEstado(id, nuevoEstado) {
    const textos = {
        ACTIVO:   '¿Activar este beneficiario?',
        INACTIVO: '¿Desactivar este beneficiario?'
    };
    if (!confirm(textos[nuevoEstado] || '¿Cambiar estado?')) return;

    const params = new URLSearchParams();
    params.append('action', 'cambiarEstado');
    params.append('id', id);
    params.append('estado', nuevoEstado);

    fetch('beneficiarios', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: params.toString()
    })
    .then(r => r.text())
    .then(text => {
        if (!text.trim()) throw new Error('Respuesta vacía');
        return JSON.parse(text);
    })
    .then(result => {
        if (result.success) {
            cargarBeneficiarios();
            mostrarNotificacion(result.message, 'success');
        } else {
            mostrarNotificacion(result.message, 'error');
        }
    })
    .catch(err => {
        console.error(err);
        mostrarNotificacion('Error al cambiar el estado', 'error');
    });
}

// ── ELIMINAR ───────────────────────────────────
function eliminarBeneficiario(id) {
    if (!confirm('¿Estás seguro de eliminar este beneficiario? Esta acción no se puede deshacer.')) return;

    const params = new URLSearchParams();
    params.append('action', 'eliminar');
    params.append('id', id);

    fetch('beneficiarios', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: params.toString()
    })
    .then(r => r.text())
    .then(text => {
        if (!text.trim()) throw new Error('Respuesta vacía');
        return JSON.parse(text);
    })
    .then(result => {
        if (result.success) {
            cargarBeneficiarios();
            mostrarNotificacion(result.message, 'success');
        } else {
            mostrarNotificacion(result.message, 'error');
        }
    })
    .catch(err => {
        console.error(err);
        mostrarNotificacion('Error al eliminar el beneficiario', 'error');
    });
}

// ── CARGAR BENEFICIARIOS (AJAX) ────────────────
function cargarBeneficiarios() {
    fetch('beneficiarios?action=listar')
        .then(r => r.json())
        .then(beneficiarios => {
            const tbody = document.getElementById('beneficiarios-tbody');
            tbody.innerHTML = '';

            if (beneficiarios && beneficiarios.length > 0) {
                beneficiarios.forEach(b => {
                    const estadoClass = b.estado === 'ACTIVO' ? 'activo' : 'inactivo';
                    const tipoClass = (b.tipoBeneficiario || 'individual').toLowerCase();

                    const obs = b.observaciones
                        ? (b.observaciones.length > 40 ? b.observaciones.substring(0, 40) + '...' : b.observaciones)
                        : '';

                    let botonesEstado = '';
                    if (b.estado === 'ACTIVO') {
                        botonesEstado = `<button class="btn-icon disable" onclick="cambiarEstado(${b.idBeneficiario},'INACTIVO')" title="Desactivar">⊘</button>`;
                    } else {
                        botonesEstado = `<button class="btn-icon enable" onclick="cambiarEstado(${b.idBeneficiario},'ACTIVO')" title="Activar">✓</button>`;
                    }

                    const fila = document.createElement('tr');
                    fila.className = 'beneficiario-row';
                    fila.dataset.id = b.idBeneficiario;
                    fila.innerHTML = `
                        <td>
                            <div class="beneficiario-nombre">
                                <strong>${b.nombres} ${b.apellidos}</strong>
                                <small>${obs}</small>
                            </div>
                        </td>
                        <td><span class="badge-dni">${b.dni}</span></td>
                        <td>${b.telefono || '—'}</td>
                        <td>${b.distrito || '—'}</td>
                        <td><span class="badge-tipo ${tipoClass}">${b.tipoBeneficiario}</span></td>
                        <td><span class="badge-necesidad">${b.necesidadPrincipal}</span></td>
                        <td><span class="estado-badge ${estadoClass}">${b.estado}</span></td>
                        <td class="acciones-cell">
                            <button class="btn-icon ver" onclick="verDetalle(${b.idBeneficiario})" title="Ver detalle">👁</button>
                            <button class="btn-icon edit" onclick="abrirModalEditar(${b.idBeneficiario})" title="Editar">✎</button>
                            ${botonesEstado}
                            <button class="btn-icon delete" onclick="eliminarBeneficiario(${b.idBeneficiario})" title="Eliminar">✕</button>
                        </td>`;
                    tbody.appendChild(fila);
                });
            } else {
                tbody.innerHTML = '<tr><td colspan="8" style="text-align:center;padding:2rem;color:#999;">No hay beneficiarios registrados</td></tr>';
            }

            paginaActualBen = 1;
            aplicarPaginacionBen();
        })
        .catch(err => {
            console.error(err);
            mostrarNotificacion('Error al cargar beneficiarios', 'error');
        });
}

// ══════════════════════════════════════
//  PAGINACIÓN
// ══════════════════════════════════════
function aplicarPaginacionBen() {
    const tbody = document.getElementById('beneficiarios-tbody');
    if (!tbody) return;

    const filas = Array.from(tbody.querySelectorAll('tr.beneficiario-row:not(.filtrado-oculto)'));
    tbody.querySelectorAll('tr.beneficiario-row.filtrado-oculto').forEach(f => f.style.display = 'none');

    const total = filas.length;
    const totalPaginas = Math.ceil(total / registrosPorPaginaBen) || 1;

    const sinDatos = document.getElementById('sinBeneficiariosRow');
    if (sinDatos) sinDatos.style.display = total > 0 ? 'none' : '';

    const paginacionEl = document.getElementById('paginacionBeneficiarios');
    if (paginacionEl) paginacionEl.style.display = total > 0 ? '' : 'none';
    if (total === 0) return;

    if (paginaActualBen > totalPaginas) paginaActualBen = totalPaginas;
    if (paginaActualBen < 1) paginaActualBen = 1;

    const inicio = (paginaActualBen - 1) * registrosPorPaginaBen;
    const fin    = inicio + registrosPorPaginaBen;

    filas.forEach((f, i) => { f.style.display = (i >= inicio && i < fin) ? '' : 'none'; });

    // Info
    const infoEl = document.getElementById('paginacionInfo');
    if (infoEl) {
        infoEl.innerHTML = `Mostrando <strong>${inicio+1}-${Math.min(fin, total)}</strong> de <strong>${total}</strong> beneficiarios`;
    }

    // Botones
    const btnPrev = document.getElementById('btnPrevBen');
    const btnNext = document.getElementById('btnNextBen');
    if (btnPrev) btnPrev.disabled = paginaActualBen <= 1;
    if (btnNext) btnNext.disabled = paginaActualBen >= totalPaginas;

    // Números de página
    const pages = document.getElementById('paginacionPages');
    if (pages) {
        pages.innerHTML = '';
        for (let i = 1; i <= totalPaginas; i++) {
            const btn = document.createElement('button');
            btn.textContent = i;
            btn.style.cssText = 'width:36px;height:36px;border:1px solid #e5e7eb;border-radius:8px;font-size:0.85rem;font-weight:500;cursor:pointer;display:flex;align-items:center;justify-content:center;';
            if (i === paginaActualBen) {
                btn.style.background = '#e85d75';
                btn.style.color = '#fff';
                btn.style.borderColor = '#e85d75';
            } else {
                btn.style.background = '#fff';
                btn.style.color = '#4b5563';
            }
            btn.onclick = () => { paginaActualBen = i; aplicarPaginacionBen(); };
            pages.appendChild(btn);
        }
    }
}

function cambiarPaginaBen(delta) {
    paginaActualBen += delta;
    aplicarPaginacionBen();
}

// ── Inicializar paginación al cargar ───────────
document.addEventListener('DOMContentLoaded', () => {
    aplicarPaginacionBen();
});

// ══════════════════════════════════════
//  NOTIFICACIÓN TOAST
// ══════════════════════════════════════
function mostrarNotificacion(mensaje, tipo) {
    const toast = document.getElementById('toast');
    if (!toast) return;
    toast.textContent = mensaje;
    toast.className = 'toast ' + tipo + ' show';
    setTimeout(() => { toast.classList.remove('show'); }, 3500);
}

// ── Cerrar modales con Escape ──────────────────
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        cerrarModal();
        cerrarModalDetalle();
    }
});

// ── Cerrar modales clickeando fuera ────────────
document.addEventListener('click', (e) => {
    if (e.target === document.getElementById('modalBeneficiario')) cerrarModal();
    if (e.target === document.getElementById('modalDetalle')) cerrarModalDetalle();
});
