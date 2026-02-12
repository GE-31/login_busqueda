// ══════════════════════════════════════════════════
//  ACTIVIDADES — JS
// ══════════════════════════════════════════════════

let modoEdicion = false;
let paginaActualAct = 1;
const registrosPorPaginaAct = 6;

// === BÚSQUEDA POR NOMBRE DE ACTIVIDAD ===
function filtrarActividades() {
    const texto = document.getElementById('buscarActividad').value.trim().toLowerCase();
    const tbody = document.getElementById('actividades-tbody');
    if (!tbody) return;

    const filas = Array.from(tbody.querySelectorAll('tr.actividad-row'));
    filas.forEach(fila => {
        const nombre = (fila.getAttribute('data-nombre') || '').toLowerCase();
        const coincide = !texto || nombre.includes(texto);
        fila.classList.toggle('filtrado-oculto', !coincide);
    });

    paginaActualAct = 1;
    aplicarPaginacionAct();
}

// ── ABRIR MODAL CREAR ──────────────────────────
function abrirModalCrear() {
    modoEdicion = false;
    document.getElementById('modalTitulo').textContent = 'Nueva Actividad';
    document.getElementById('btnGuardarTexto').textContent = 'Crear Actividad';
    document.getElementById('formActividad').reset();
    document.getElementById('actividadId').value = '';
    document.getElementById('modalActividad').style.display = 'flex';
    document.body.style.overflow = 'hidden';
}

// ── ABRIR MODAL EDITAR ─────────────────────────
function abrirModalEditar(id) {
    modoEdicion = true;
    document.getElementById('modalTitulo').textContent = 'Editar Actividad';
    document.getElementById('btnGuardarTexto').textContent = 'Guardar Cambios';

    fetch(`actividades?action=obtener&id=${id}`)
        .then(r => r.text())
        .then(text => {
            if (!text || text.trim() === '') throw new Error('Respuesta vacía');
            return JSON.parse(text);
        })
        .then(a => {
            document.getElementById('actividadId').value  = a.idActividad;
            document.getElementById('nombre').value       = a.nombre;
            document.getElementById('descripcion').value  = a.descripcion || '';
            document.getElementById('fechaInicio').value  = a.fechaInicio || '';
            document.getElementById('fechaFin').value     = a.fechaFin || '';
            document.getElementById('ubicacion').value    = a.ubicacion;
            document.getElementById('cupoMaximo').value   = a.cupoMaximo;

            document.getElementById('modalActividad').style.display = 'flex';
            document.body.style.overflow = 'hidden';
        })
        .catch(err => {
            console.error(err);
            mostrarNotificacion('Error al cargar la actividad', 'error');
        });
}

// ── CERRAR MODAL ───────────────────────────────
function cerrarModal() {
    document.body.style.overflow = 'auto';
    document.getElementById('modalActividad').style.display = 'none';
}

// ── GUARDAR (CREAR / EDITAR) ───────────────────
function guardarActividad(event) {
    event.preventDefault();

    const id          = document.getElementById('actividadId').value;
    const nombre      = document.getElementById('nombre').value;
    const descripcion = document.getElementById('descripcion').value;
    const fechaInicio = document.getElementById('fechaInicio').value;
    const fechaFin    = document.getElementById('fechaFin').value;
    const ubicacion   = document.getElementById('ubicacion').value;
    const cupoMaximo  = document.getElementById('cupoMaximo').value;

    const params = new URLSearchParams();
    params.append('action', id ? 'editar' : 'crear');
    if (id) params.append('id', id);
    params.append('nombre', nombre);
    params.append('descripcion', descripcion);
    params.append('fechaInicio', fechaInicio);
    params.append('fechaFin', fechaFin);
    params.append('ubicacion', ubicacion);
    params.append('cupoMaximo', cupoMaximo);

    fetch('actividades', {
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
            cargarActividades();
            mostrarNotificacion(result.message, 'success');
        } else {
            mostrarNotificacion(result.message, 'error');
        }
    })
    .catch(err => {
        console.error(err);
        mostrarNotificacion('Error al guardar la actividad', 'error');
    });
}

// ── CAMBIAR ESTADO ─────────────────────────────
function cambiarEstado(id, nuevoEstado) {
    const textos = {
        FINALIZADO: '¿Marcar esta actividad como finalizada?',
        CANCELADO:  '¿Cancelar esta actividad?',
        ACTIVO:     '¿Reactivar esta actividad?'
    };
    if (!confirm(textos[nuevoEstado] || '¿Cambiar estado?')) return;

    const params = new URLSearchParams();
    params.append('action', 'cambiarEstado');
    params.append('id', id);
    params.append('estado', nuevoEstado);

    fetch('actividades', {
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
            cargarActividades();
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

// ── CARGAR ACTIVIDADES (AJAX) ──────────────────
function cargarActividades() {
    fetch('actividades?action=listar')
        .then(r => r.json())
        .then(actividades => {
            const tbody = document.getElementById('actividades-tbody');
            tbody.innerHTML = '';

            if (actividades && actividades.length > 0) {
                actividades.forEach(a => {
                    const estadoClass = a.estado === 'ACTIVO' ? 'activo'
                                      : a.estado === 'FINALIZADO' ? 'finalizado' : 'cancelado';

                    let botonesExtra = '';
                    if (a.estado === 'ACTIVO') {
                        botonesExtra = `
                            <button class="btn-icon finalizar" onclick="cambiarEstado(${a.idActividad},'FINALIZADO')" title="Finalizar">✓</button>
                            <button class="btn-icon disable" onclick="cambiarEstado(${a.idActividad},'CANCELADO')" title="Cancelar">⊘</button>`;
                    } else if (a.estado === 'CANCELADO') {
                        botonesExtra = `
                            <button class="btn-icon enable" onclick="cambiarEstado(${a.idActividad},'ACTIVO')" title="Reactivar">↻</button>`;
                    }

                    const pct = a.cupoMaximo > 0 ? Math.round(a.inscritos * 100 / a.cupoMaximo) : 0;

                    const fila = document.createElement('tr');
                    fila.className = 'actividad-row';
                    fila.dataset.id = a.idActividad;
                    fila.dataset.nombre = a.nombre || '';
                    fila.innerHTML = `
                        <td>
                            <div class="actividad-nombre">
                                <strong>${a.nombre}</strong>
                                <small>${a.descripcion || ''}</small>
                            </div>
                        </td>
                        <td><span class="badge-fecha">${a.fechaInicio}</span></td>
                        <td><span class="badge-fecha">${a.fechaFin || '—'}</span></td>
                        <td>${a.ubicacion}</td>
                        <td>
                            <div class="cupo-info">
                                <span class="cupo-num">${a.inscritos}/${a.cupoMaximo}</span>
                                <div class="cupo-bar"><div class="cupo-bar-fill" style="width:${pct}%"></div></div>
                            </div>
                        </td>
                        <td><span class="estado-badge ${estadoClass}">${a.estado}</span></td>
                        <td class="acciones-cell">
                            <button class="btn-icon edit" onclick="abrirModalEditar(${a.idActividad})" title="Editar">✎</button>
                            ${botonesExtra}
                        </td>`;
                    tbody.appendChild(fila);
                });
            } else {
                tbody.innerHTML = '<tr><td colspan="7" style="text-align:center;padding:2rem;color:#999;">No hay actividades registradas</td></tr>';
            }

            paginaActualAct = 1;
            aplicarPaginacionAct();
        })
        .catch(err => {
            console.error(err);
            mostrarNotificacion('Error al cargar actividades', 'error');
        });
}

// ══════════════════════════════════════
//  PAGINACIÓN
// ══════════════════════════════════════
function aplicarPaginacionAct() {
    const tbody = document.getElementById('actividades-tbody');
    if (!tbody) return;

    const filas = Array.from(tbody.querySelectorAll('tr.actividad-row:not(.filtrado-oculto)'));
    tbody.querySelectorAll('tr.actividad-row.filtrado-oculto').forEach(f => f.style.display = 'none');

    const total = filas.length;
    const totalPaginas = Math.ceil(total / registrosPorPaginaAct) || 1;

    const sinDatos = document.getElementById('sinActividadesRow');
    if (sinDatos) sinDatos.style.display = total > 0 ? 'none' : '';

    const paginacionEl = document.getElementById('paginacionActividades');
    if (paginacionEl) paginacionEl.style.display = total > 0 ? '' : 'none';
    if (total === 0) return;

    if (paginaActualAct > totalPaginas) paginaActualAct = totalPaginas;
    if (paginaActualAct < 1) paginaActualAct = 1;

    const inicio = (paginaActualAct - 1) * registrosPorPaginaAct;
    const fin    = inicio + registrosPorPaginaAct;

    filas.forEach((f, i) => { f.style.display = (i >= inicio && i < fin) ? '' : 'none'; });

    // Info
    const infoEl = document.getElementById('paginacionInfo');
    if (infoEl) {
        infoEl.innerHTML = `Mostrando <strong>${inicio+1}-${Math.min(fin, total)}</strong> de <strong>${total}</strong> actividades`;
    }

    // Botones
    const btnPrev = document.getElementById('btnPrevAct');
    const btnNext = document.getElementById('btnNextAct');
    if (btnPrev) btnPrev.disabled = paginaActualAct <= 1;
    if (btnNext) btnNext.disabled = paginaActualAct >= totalPaginas;

    // Números
    const pages = document.getElementById('paginacionPages');
    if (pages) {
        pages.innerHTML = '';
        for (let i = 1; i <= totalPaginas; i++) {
            const btn = document.createElement('button');
            btn.textContent = i;
            btn.style.cssText = 'width:36px;height:36px;border:1px solid #e5e7eb;border-radius:8px;font-size:0.85rem;font-weight:500;cursor:pointer;display:flex;align-items:center;justify-content:center;';
            if (i === paginaActualAct) {
                btn.style.background = '#10b981';
                btn.style.color = '#fff';
                btn.style.borderColor = '#10b981';
            } else {
                btn.style.background = '#fff';
                btn.style.color = '#4b5563';
            }
            btn.onclick = () => { paginaActualAct = i; aplicarPaginacionAct(); };
            pages.appendChild(btn);
        }
    }
}

function cambiarPaginaAct(delta) {
    paginaActualAct += delta;
    aplicarPaginacionAct();
}

// ── Inicializar paginación al cargar ───────────
document.addEventListener('DOMContentLoaded', () => {
    aplicarPaginacionAct();
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

// ── Cerrar modal con Escape ────────────────────
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') cerrarModal();
});

// ── Cerrar modal clickeando fuera ──────────────
document.addEventListener('click', (e) => {
    const modal = document.getElementById('modalActividad');
    if (e.target === modal) cerrarModal();
});
