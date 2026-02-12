/* ============================================================
   DONACIONES.JS - Dashboard PRO
   ============================================================ */

let modal = document.getElementById("modalDonacion");
let form = document.getElementById("formDonacion");
let editingId = null;

// === BÚSQUEDA POR DESCRIPCIÓN/ACTIVIDAD ===
function filtrarDonaciones() {
    const texto = document.getElementById('buscarDonacion').value.trim().toLowerCase();
    const tbody = document.getElementById('tbodyDonaciones');
    if (!tbody) return;

    const filas = Array.from(tbody.querySelectorAll('tr'));
    filas.forEach(fila => {
        const celdas = fila.querySelectorAll('td');
        if (celdas.length < 4) return; // skip no-data row
        const textoFila = Array.from(celdas).map(td => td.textContent.toLowerCase()).join(' ');
        const coincide = !texto || textoFila.includes(texto);
        fila.style.display = coincide ? '' : 'none';
    });
}

// ====================== CARGAR ACTIVIDADES ======================
async function cargarActividades() {
    try {
        const resp = await fetch("actividades?action=listar");
        const actividades = await resp.json();
        
        const select = document.getElementById("actividad");
        // Limpiar opciones existentes excepto la primera
        select.innerHTML = '<option value="">Seleccione actividad</option>';
        
        actividades.forEach(act => {
            const option = document.createElement("option");
            option.value = act.idActividad;
            option.textContent = act.nombre;
            select.appendChild(option);
        });
    } catch (error) {
        console.error("Error al cargar actividades:", error);
    }
}

// ====================== MODAL CONTROL ======================
function abrirModal() {
    modal.style.display = "flex";
    form.reset();
    editingId = null;
    document.getElementById("tituloModal").innerText = "Registrar Donación";
    cargarActividades();
}

function cerrarModal() {
    modal.style.display = "none";
}

// ====================== GUARDAR O EDITAR ======================
async function guardarDonacion(event) {
    event.preventDefault();

    const data = {
        idDonacion: editingId,
        tipoDonacion: document.getElementById("tipoDonacion").value,
        cantidad: document.getElementById("cantidad").value,
        descripcion: document.getElementById("descripcion").value,
        actividad: document.getElementById("actividad").value
    };

    const url = editingId
        ? "donaciones?accion=actualizar"
        : "donaciones?accion=registrar";

    const resp = await fetch(url, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(data)
    });

    if (resp.ok) {
        cargarDonaciones();
        cerrarModal();
    }
}

// ====================== EDITAR ======================
async function editarDonacion(id) {
    abrirModal();
    editingId = id;

    // Esperar a que las actividades se carguen
    await cargarActividades();

    const resp = await fetch("donaciones?accion=obtener&id=" + id);
    const d = await resp.json();

    document.getElementById("tipoDonacion").value = d.tipoDonacion;
    document.getElementById("cantidad").value = d.cantidad;
    document.getElementById("descripcion").value = d.descripcion;
    document.getElementById("actividad").value = d.idActividad || d.actividad;

    document.getElementById("tituloModal").innerText = "Editar Donación";
}

// ====================== ELIMINAR ======================
async function eliminarDonacion(id) {
    if (!confirm("¿Eliminar esta donación?")) return;

    const resp = await fetch("donaciones?accion=eliminar&id=" + id);

    if (resp.ok) {
        cargarDonaciones();
    }
}

// ====================== ACTUALIZAR TABLA ======================
async function cargarDonaciones() {
    const resp = await fetch("donaciones?accion=listar");
    const data = await resp.json();

    const tbody = document.getElementById("tbodyDonaciones");
    tbody.innerHTML = "";

    data.forEach(d => {
        tbody.innerHTML += `
            <tr>
                <td>${d.descripcion}</td>
                <td>${d.cantidad}</td>
                <td>
                    <span class="tipo-badge ${d.tipoDonacion === 'DINERO' ? 'tipo-dinero' : 'tipo-objeto'}">
                        ${d.tipoDonacion}
                    </span>
                </td>
                <td>${d.actividad}</td>
                <td style="text-align:right;">
                    <button class="btn-icon btn-edit" onclick="editarDonacion(${d.idDonacion})">
                        <i class="fas fa-edit"></i>
                    </button>
                    <button class="btn-icon btn-delete" onclick="eliminarDonacion(${d.idDonacion})">
                        <i class="fas fa-trash"></i>
                    </button>
                </td>
            </tr>
        `;
    });
}

document.addEventListener("DOMContentLoaded", cargarDonaciones);
