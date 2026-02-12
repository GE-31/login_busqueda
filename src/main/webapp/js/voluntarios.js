// Variables globales
let modoEdicion = false;
let paginaActualVol = 1;
const registrosPorPaginaVol = 5;

// === BÚSQUEDA POR NOMBRE/APELLIDO ===
function filtrarVoluntarios() {
    const texto = document.getElementById('buscarVoluntario').value.trim().toLowerCase();
    const tbody = document.getElementById('voluntarios-tbody');
    if (!tbody) return;

    const filas = Array.from(tbody.querySelectorAll('tr.voluntario-row'));

    filas.forEach(fila => {
        const nombres = (fila.getAttribute('data-nombres') || '').toLowerCase();
        const apellidos = (fila.getAttribute('data-apellidos') || '').toLowerCase();
        const coincide = !texto || nombres.includes(texto) || apellidos.includes(texto);
        fila.classList.toggle('filtrado-oculto', !coincide);
    });

    paginaActualVol = 1;
    aplicarPaginacionVol();
}

// Abrir modal para crear voluntario
function abrirModalCrear() {
    modoEdicion = false;
    document.getElementById('modalTitulo').textContent = 'Crear Voluntario';
    document.getElementById('formVoluntario').reset();
    document.getElementById('voluntarioId').value = '';
    document.getElementById('modalVoluntario').style.display = 'flex';
    document.body.style.overflow = 'hidden';
}

// Abrir modal para editar voluntario
function abrirModalEditar(id) {
    modoEdicion = true;
    document.getElementById('modalTitulo').textContent = 'Editar Voluntario';

    fetch(`voluntarios?action=obtener&id=${id}`)
        .then(response => response.text())
        .then(text => {
            console.log("RESPUESTA RAW:", text);

            if (!text || text.trim() === "") {
                throw new Error("El servidor devolvió una respuesta vacía");
            }

            return JSON.parse(text);
        })
        .then(voluntario => {
            document.getElementById('voluntarioId').value = voluntario.idVoluntario;
            document.getElementById('nombres').value = voluntario.nombres;
            document.getElementById('apellidos').value = voluntario.apellidos;
            document.getElementById('dni').value = voluntario.dni || '';
            document.getElementById('correo').value = voluntario.correo;
            document.getElementById('telefono').value = voluntario.telefono;
            document.getElementById('carrera').value = voluntario.carrera;

            document.getElementById('modalVoluntario').style.display = 'flex';
            document.body.style.overflow = 'hidden';
        })
        .catch(error => {
            console.error('Error:', error);
            alert('Error al cargar los datos del voluntario. El servidor no está devolviendo JSON válido.');
        });
}


// Cerrar modal
function cerrarModal() {
    document.body.style.overflow = 'auto';
    document.getElementById('modalVoluntario').style.display = 'none';
}

// Guardar voluntario (crear o editar)
function guardarVoluntario(event) {
    event.preventDefault();

    // Obtener valores correctos del formulario
    const id = document.getElementById('voluntarioId').value;
    const nombres = document.getElementById("nombres").value;
    const apellidos = document.getElementById("apellidos").value;
    const dni = document.getElementById("dni").value;
    const correo = document.getElementById("correo").value;
    const telefono = document.getElementById("telefono").value;
    const carrera = document.getElementById("carrera").value;

    // Crear parámetros URL-encoded en lugar de FormData
    const params = new URLSearchParams();
    params.append("action", id ? "editar" : "crear");
    if (id) params.append("id", id);
    params.append("nombres", nombres);
    params.append("apellidos", apellidos);
    params.append("dni", dni);
    params.append("correo", correo);
    params.append("telefono", telefono);
    params.append("carrera", carrera);

    console.log("► Enviando parámetros:", {
        action: id ? "editar" : "crear",
        nombres: nombres,
        apellidos: apellidos,
        dni: dni
    });

    fetch("voluntarios", {
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
                cargarVoluntarios();
                mostrarNotificacion(result.message, 'success');
            } else {
                mostrarNotificacion(result.message, 'error');
            }
        })
        .catch(error => {
            console.error('Error:', error);
            mostrarNotificacion('Error al guardar el voluntario', 'error');
        });
}

// Cambiar estado del voluntario
function cambiarEstado(id, nuevoEstado) {
    const mensaje = nuevoEstado === 'ACTIVO'
        ? '¿Habilitar este voluntario?'
        : '¿Deshabilitar este voluntario?';

    if (!confirm(mensaje)) return;

    const params = new URLSearchParams();
    params.append('action', 'cambiarEstado');
    params.append('id', id);
    params.append('estado', nuevoEstado);

    fetch('voluntarios', {
        method: 'POST',
        headers: {
            "Content-Type": "application/x-www-form-urlencoded"
        },
        body: params.toString()
    })
        .then(response => response.text())
        .then(text => {
            console.log("RESPUESTA RAW (estado):", text);
            if (!text.trim()) throw new Error("Respuesta vacía");
            return JSON.parse(text);
        })
        .then(result => {
            if (result.success) {
                cargarVoluntarios();
                mostrarNotificacion(result.message, 'success');
            } else {
                mostrarNotificacion(result.message, 'error');
            }
        })
        .catch(error => {
            console.error('Error:', error);
            mostrarNotificacion('Error al cambiar el estado', 'error');
        });
}

// Eliminar voluntario
function eliminarVoluntario(id) {
    if (!confirm('¿Está seguro de que desea eliminar este voluntario?')) return;

    const params = new URLSearchParams();
    params.append('action', 'eliminar');
    params.append('id', id);

    fetch('voluntarios', {
        method: 'POST',
        headers: {
            "Content-Type": "application/x-www-form-urlencoded"
        },
        body: params.toString()
    })
        .then(response => response.text())
        .then(text => {
            console.log("RESPUESTA RAW (eliminar):", text);
            if (!text.trim()) throw new Error("Respuesta vacía");
            return JSON.parse(text);
        })
        .then(result => {
            if (result.success) {
                cargarVoluntarios();
                mostrarNotificacion(result.message, 'success');
            } else {
                mostrarNotificacion(result.message, 'error');
            }
        })
        .catch(error => {
            console.error('Error:', error);
            mostrarNotificacion('Error al eliminar el voluntario', 'error');
        });
}


// Cargar voluntarios de la BD
function cargarVoluntarios() {
    fetch('voluntarios?action=listar')
        .then(response => response.json())
        .then(voluntarios => {
            const tbody = document.getElementById('voluntarios-tbody');
            tbody.innerHTML = '';

            if (voluntarios && voluntarios.length > 0) {
                voluntarios.forEach(v => {
                    const estadoClass = v.estado === 'ACTIVO' ? 'activo' : 'inactivo';
                    const botones = v.estado === 'ACTIVO'
                        ? `<button class="btn-icon disable" onclick="cambiarEstado(${v.idVoluntario}, 'INACTIVO')" title="Deshabilitar">⊘</button>`
                        : `<button class="btn-icon enable" onclick="cambiarEstado(${v.idVoluntario}, 'ACTIVO')" title="Habilitar">✓</button>`;

                    const fila = document.createElement('tr');
                    fila.className = 'voluntario-row';
                    fila.dataset.id = v.idVoluntario;
                    fila.innerHTML = `
                        <td class="nombre-cell"><strong>${v.nombres} ${v.apellidos}</strong></td>
                        <td><span class="badge-dni">${v.dni || 'N/A'}</span></td>
                        <td>${v.correo}</td>
                        <td>${v.telefono}</td>
                        <td>${v.carrera}</td>
                        <td><span class="estado-badge ${estadoClass}">${v.estado}</span></td>
                        <td class="acciones-cell">
                            <button class="btn-icon edit" onclick="abrirModalEditar(${v.idVoluntario})" title="Editar">✎</button>
                            ${botones}
                        </td>
                    `;
                    tbody.appendChild(fila);
                });
            } else {
                const fila = document.createElement('tr');
                fila.innerHTML = '<td colspan="8" class="text-center">No hay voluntarios registrados</td>';
                tbody.appendChild(fila);
            }

            // Aplicar paginación después de cargar
            paginaActualVol = 1;
            aplicarPaginacionVol();
        })
        .catch(error => {
            console.error('Error:', error);
            mostrarNotificacion('Error al cargar los voluntarios', 'error');
        });
}

// === PAGINACIÓN VOLUNTARIOS ===
function aplicarPaginacionVol() {
    const tbody = document.getElementById('voluntarios-tbody');
    if (!tbody) return;

    const filas = Array.from(tbody.querySelectorAll('tr.voluntario-row:not(.filtrado-oculto)'));
    // Ocultar filas filtradas explícitamente
    tbody.querySelectorAll('tr.voluntario-row.filtrado-oculto').forEach(f => f.style.display = 'none');

    const totalRegistros = filas.length;
    const totalPaginas = Math.ceil(totalRegistros / registrosPorPaginaVol) || 1;

    // Ocultar fila "No hay voluntarios" si hay registros
    const sinDatosRow = document.getElementById('sinVoluntariosRow');
    if (sinDatosRow) sinDatosRow.style.display = totalRegistros > 0 ? 'none' : '';

    // También ocultar cualquier fila sin clase voluntario-row
    tbody.querySelectorAll('tr:not(.voluntario-row)').forEach(f => {
        f.style.display = totalRegistros > 0 ? 'none' : '';
    });

    // Mostrar/ocultar paginación
    const paginacionEl = document.getElementById('paginacionVoluntarios');
    if (paginacionEl) {
        paginacionEl.style.display = totalRegistros > 0 ? '' : 'none';
    }
    if (totalRegistros === 0) return;

    if (paginaActualVol > totalPaginas) paginaActualVol = totalPaginas;
    if (paginaActualVol < 1) paginaActualVol = 1;

    const inicio = (paginaActualVol - 1) * registrosPorPaginaVol;
    const fin = inicio + registrosPorPaginaVol;

    filas.forEach((fila, index) => {
        fila.style.display = (index >= inicio && index < fin) ? '' : 'none';
    });

    // Actualizar info
    const infoEl = document.getElementById('paginacionInfo');
    if (infoEl) {
        const desde = inicio + 1;
        const hasta = Math.min(fin, totalRegistros);
        infoEl.innerHTML = 'Mostrando <strong>' + desde + '-' + hasta + '</strong> de <strong>' + totalRegistros + '</strong> voluntarios';
    }

    // Botones prev/next
    const btnPrev = document.getElementById('btnPrevVol');
    const btnNext = document.getElementById('btnNextVol');
    if (btnPrev) btnPrev.disabled = paginaActualVol <= 1;
    if (btnNext) btnNext.disabled = paginaActualVol >= totalPaginas;

    // Números de página
    const pagesContainer = document.getElementById('paginacionPages');
    if (pagesContainer) {
        pagesContainer.innerHTML = '';
        for (let i = 1; i <= totalPaginas; i++) {
            const btn = document.createElement('button');
            btn.textContent = i;
            btn.style.cssText = 'width:36px; height:36px; border:1px solid #e5e7eb; border-radius:8px; font-size:0.85rem; font-weight:500; cursor:pointer; display:flex; align-items:center; justify-content:center;';
            if (i === paginaActualVol) {
                btn.style.background = 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)';
                btn.style.color = '#fff';
                btn.style.borderColor = 'transparent';
                btn.style.boxShadow = '0 3px 10px rgba(102,126,234,0.4)';
            } else {
                btn.style.background = '#fff';
                btn.style.color = '#4b5563';
            }
            btn.onclick = () => { paginaActualVol = i; aplicarPaginacionVol(); };
            pagesContainer.appendChild(btn);
        }
    }

    // Estilo botones disabled
    if (btnPrev) btnPrev.style.opacity = btnPrev.disabled ? '0.35' : '1';
    if (btnNext) btnNext.style.opacity = btnNext.disabled ? '0.35' : '1';
}

function cambiarPaginaVol(direccion) {
    paginaActualVol += direccion;
    aplicarPaginacionVol();
}

// Inicializar paginación al cargar la página
document.addEventListener('DOMContentLoaded', function() {
    aplicarPaginacionVol();
});

// Mostrar notificación
function mostrarNotificacion(mensaje, tipo) {
    const notificacion = document.createElement('div');
    notificacion.className = `notificacion ${tipo}`;
    notificacion.textContent = mensaje;

    document.body.appendChild(notificacion);

    setTimeout(() => {
        notificacion.classList.add('show');
    }, 10);

    setTimeout(() => {
        notificacion.classList.remove('show');
        setTimeout(() => {
            document.body.removeChild(notificacion);
        }, 300);
    }, 3000);
}

// Cerrar modal al hacer clic fuera del contenido
window.onclick = function (event) {
    const modal = document.getElementById('modalVoluntario');
    if (event.target === modal) {
        cerrarModal();
    }
}
