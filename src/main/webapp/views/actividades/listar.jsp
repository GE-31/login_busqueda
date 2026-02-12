<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.sistemadevoluntariado.model.Usuario" %>
<%@ page import="com.sistemadevoluntariado.model.Actividad" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>

<%
    HttpSession ses = request.getSession(false);
    Usuario usuario = (Usuario)(request.getAttribute("usuario") != null
        ? request.getAttribute("usuario")
        : (ses != null ? ses.getAttribute("usuarioLogeado") : null));

    if (usuario == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    List<Actividad> actividades = (List<Actividad>) request.getAttribute("actividades");
    if (actividades == null) actividades = new ArrayList<>();
    request.setAttribute("page", "actividades");
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Actividades - Sistema de Voluntariado</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/dashboard.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/actividades.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>

<jsp:include page="/includes/sidebar.jsp" />

<main class="main-content">
    <jsp:include page="/includes/topbar.jsp" />

    <div class="content-body">

        <!-- Header -->
        <div class="actividades-header">
            <div>
                <h1>Gestión de Actividades</h1>
                <p>Administra las actividades y eventos del sistema</p>
            </div>
            <button class="btn btn-primary" onclick="abrirModalCrear()">
                <span>+</span> Nueva Actividad
            </button>
        </div>

        <!-- Barra de búsqueda -->
        <div style="margin-bottom:1rem; display:flex; align-items:center; gap:0.5rem;">
            <div style="position:relative; flex:1; max-width:400px;">
                <svg style="position:absolute; left:12px; top:50%; transform:translateY(-50%); color:#9ca3af;" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                <input type="text" id="buscarActividad" placeholder="Buscar por nombre de actividad..." oninput="filtrarActividades()" style="width:100%; padding:0.6rem 0.75rem 0.6rem 2.5rem; border:1px solid #e5e7eb; border-radius:8px; font-size:0.9rem; font-family:'Inter',sans-serif; outline:none; transition:border-color 0.2s;" onfocus="this.style.borderColor='#10b981'" onblur="this.style.borderColor='#e5e7eb'">
            </div>
        </div>

        <!-- Tabla -->
        <div class="actividades-table">
            <table>
                <thead>
                    <tr>
                        <th>Actividad</th>
                        <th>Fecha Inicio</th>
                        <th>Fecha Fin</th>
                        <th>Ubicación</th>
                        <th>Cupo</th>
                        <th>Estado</th>
                        <th>Acciones</th>
                    </tr>
                </thead>
                <tbody id="actividades-tbody">
                    <% if (!actividades.isEmpty()) {
                        for (Actividad a : actividades) { %>
                        <tr class="actividad-row" data-id="<%= a.getIdActividad() %>"
                            data-nombre="<%= a.getNombre() != null ? a.getNombre() : "" %>">
                            <td>
                                <div class="actividad-nombre">
                                    <strong><%= a.getNombre() %></strong>
                                    <small><%= a.getDescripcion() != null ? a.getDescripcion() : "" %></small>
                                </div>
                            </td>
                            <td><span class="badge-fecha"><%= a.getFechaInicio() %></span></td>
                            <td><span class="badge-fecha"><%= a.getFechaFin() != null ? a.getFechaFin() : "—" %></span></td>
                            <td><%= a.getUbicacion() %></td>
                            <td>
                                <div class="cupo-info">
                                    <span class="cupo-num"><%= a.getInscritos() %>/<%= a.getCupoMaximo() %></span>
                                    <div class="cupo-bar">
                                        <div class="cupo-bar-fill" style="width: <%= a.getCupoMaximo() > 0 ? (a.getInscritos() * 100 / a.getCupoMaximo()) : 0 %>%"></div>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <span class="estado-badge <%= a.getEstado().equals("ACTIVO") ? "activo" : a.getEstado().equals("FINALIZADO") ? "finalizado" : "cancelado" %>">
                                    <%= a.getEstado() %>
                                </span>
                            </td>
                            <td class="acciones-cell">
                                <button class="btn-icon edit" onclick="abrirModalEditar(<%= a.getIdActividad() %>)" title="Editar">✎</button>
                                <% if (a.getEstado().equals("ACTIVO")) { %>
                                    <button class="btn-icon finalizar" onclick="cambiarEstado(<%= a.getIdActividad() %>, 'FINALIZADO')" title="Finalizar">✓</button>
                                    <button class="btn-icon disable" onclick="cambiarEstado(<%= a.getIdActividad() %>, 'CANCELADO')" title="Cancelar">⊘</button>
                                <% } else if (a.getEstado().equals("CANCELADO")) { %>
                                    <button class="btn-icon enable" onclick="cambiarEstado(<%= a.getIdActividad() %>, 'ACTIVO')" title="Reactivar">↻</button>
                                <% } %>
                            </td>
                        </tr>
                    <% } } else { %>
                        <tr id="sinActividadesRow">
                            <td colspan="7" style="text-align:center; padding:2rem; color:#999;">
                                No hay actividades registradas
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        </div>

        <!-- Paginación -->
        <div id="paginacionActividades" style="display:flex; justify-content:flex-end; align-items:center; padding:1rem 1.5rem; background:#fff; border-top:1px solid #f0f0f0; border-radius:0 0 12px 12px; gap:0.5rem; font-family:'Inter',sans-serif;">
            <span id="paginacionInfo" style="margin-right:auto; font-size:0.85rem; color:#6b7280;"></span>
            <button id="btnPrevAct" onclick="cambiarPaginaAct(-1)" disabled style="display:inline-flex; align-items:center; gap:0.4rem; padding:0.5rem 0.9rem; border:1px solid #e5e7eb; background:#fff; color:#4b5563; border-radius:8px; font-size:0.82rem; font-weight:500; cursor:pointer;">
                ← Anterior
            </button>
            <div id="paginacionPages" style="display:flex; gap:0.25rem;"></div>
            <button id="btnNextAct" onclick="cambiarPaginaAct(1)" disabled style="display:inline-flex; align-items:center; gap:0.4rem; padding:0.5rem 0.9rem; border:1px solid #e5e7eb; background:#fff; color:#4b5563; border-radius:8px; font-size:0.82rem; font-weight:500; cursor:pointer;">
                Siguiente →
            </button>
        </div>

    </div>
</main>

<!-- ══════════════════════════════════════════════════
     MODAL CREAR / EDITAR ACTIVIDAD
     ══════════════════════════════════════════════════ -->
<div id="modalActividad" class="modal-overlay">
    <div class="modal-container">
        <div class="modal-card">
            <!-- Header -->
            <div class="modal-header-enhanced">
                <div class="modal-header-content">
                    <h2 id="modalTitulo" class="modal-title">Nueva Actividad</h2>
                    <p class="modal-subtitle">Ingresa la información de la actividad</p>
                </div>
                <button class="modal-close-btn" onclick="cerrarModal()" title="Cerrar">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <line x1="18" y1="6" x2="6" y2="18"></line>
                        <line x1="6" y1="6" x2="18" y2="18"></line>
                    </svg>
                </button>
            </div>

            <!-- Form -->
            <form id="formActividad" onsubmit="guardarActividad(event)" class="modal-form">
                <input type="hidden" id="actividadId">

                <div class="form-grid">
                    <!-- Nombre -->
                    <div class="form-group full-width">
                        <label for="nombre" class="form-label">
                            <span class="label-text">Nombre de la Actividad</span>
                            <span class="required-indicator">*</span>
                        </label>
                        <div class="input-wrapper">
                            <svg class="input-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/>
                            </svg>
                            <input type="text" id="nombre" name="nombre" class="form-input"
                                   placeholder="Ej: Campaña de limpieza del río" required>
                        </div>
                    </div>

                    <!-- Descripción -->
                    <div class="form-group full-width">
                        <label for="descripcion" class="form-label">
                            <span class="label-text">Descripción</span>
                        </label>
                        <textarea id="descripcion" name="descripcion" class="form-textarea"
                                  placeholder="Describe brevemente la actividad..." rows="3"></textarea>
                    </div>

                    <!-- Fecha Inicio -->
                    <div class="form-group">
                        <label for="fechaInicio" class="form-label">
                            <span class="label-text">Fecha de Inicio</span>
                            <span class="required-indicator">*</span>
                        </label>
                        <div class="input-wrapper">
                            <svg class="input-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <rect x="3" y="4" width="18" height="18" rx="2" ry="2"/>
                                <line x1="16" y1="2" x2="16" y2="6"/>
                                <line x1="8" y1="2" x2="8" y2="6"/>
                                <line x1="3" y1="10" x2="21" y2="10"/>
                            </svg>
                            <input type="date" id="fechaInicio" name="fechaInicio" class="form-input" required>
                        </div>
                    </div>

                    <!-- Fecha Fin -->
                    <div class="form-group">
                        <label for="fechaFin" class="form-label">
                            <span class="label-text">Fecha de Fin</span>
                        </label>
                        <div class="input-wrapper">
                            <svg class="input-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <rect x="3" y="4" width="18" height="18" rx="2" ry="2"/>
                                <line x1="16" y1="2" x2="16" y2="6"/>
                                <line x1="8" y1="2" x2="8" y2="6"/>
                                <line x1="3" y1="10" x2="21" y2="10"/>
                            </svg>
                            <input type="date" id="fechaFin" name="fechaFin" class="form-input">
                        </div>
                    </div>

                    <!-- Ubicación -->
                    <div class="form-group">
                        <label for="ubicacion" class="form-label">
                            <span class="label-text">Ubicación</span>
                            <span class="required-indicator">*</span>
                        </label>
                        <div class="input-wrapper">
                            <svg class="input-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/>
                                <circle cx="12" cy="10" r="3"/>
                            </svg>
                            <input type="text" id="ubicacion" name="ubicacion" class="form-input"
                                   placeholder="Ej: Parque Central, Lima" required>
                        </div>
                    </div>

                    <!-- Cupo Máximo -->
                    <div class="form-group">
                        <label for="cupoMaximo" class="form-label">
                            <span class="label-text">Cupo Máximo</span>
                            <span class="required-indicator">*</span>
                        </label>
                        <div class="input-wrapper">
                            <svg class="input-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
                                <circle cx="9" cy="7" r="4"/>
                                <path d="M23 21v-2a4 4 0 0 0-3-3.87"/>
                                <path d="M16 3.13a4 4 0 0 1 0 7.75"/>
                            </svg>
                            <input type="number" id="cupoMaximo" name="cupoMaximo" class="form-input"
                                   placeholder="30" min="1" required>
                        </div>
                    </div>
                </div>

                <!-- Botones -->
                <div class="modal-actions">
                    <button type="button" class="btn btn-secondary" onclick="cerrarModal()">Cancelar</button>
                    <button type="submit" class="btn btn-primary">
                        <span id="btnGuardarTexto">Crear Actividad</span>
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Notificación Toast -->
<div id="toast" class="toast"></div>

<script src="${pageContext.request.contextPath}/js/actividades.js"></script>

</body>
</html>
