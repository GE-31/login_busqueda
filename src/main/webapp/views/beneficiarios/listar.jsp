<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.sistemadevoluntariado.model.Usuario" %>
<%@ page import="com.sistemadevoluntariado.model.Beneficiario" %>
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

    List<Beneficiario> beneficiarios = (List<Beneficiario>) request.getAttribute("beneficiarios");
    if (beneficiarios == null) beneficiarios = new ArrayList<>();
    request.setAttribute("page", "beneficiarios");
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Beneficiarios - Sistema de Voluntariado</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/dashboard.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/beneficiarios.css">
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
        <div class="beneficiarios-header">
            <div>
                <h1>Gestión de Beneficiarios</h1>
                <p>Administra los beneficiarios del sistema de voluntariado</p>
            </div>
            <button class="btn btn-primary" onclick="abrirModalCrear()">
                <span>+</span> Nuevo Beneficiario
            </button>
        </div>

        <!-- Barra de búsqueda -->
        <div style="margin-bottom:1rem; display:flex; align-items:center; gap:0.5rem;">
            <div style="position:relative; flex:1; max-width:400px;">
                <svg style="position:absolute; left:12px; top:50%; transform:translateY(-50%); color:#9ca3af;" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                <input type="text" id="buscarBeneficiario" placeholder="Buscar por nombre o apellido..." oninput="filtrarBeneficiarios()" style="width:100%; padding:0.6rem 0.75rem 0.6rem 2.5rem; border:1px solid #e5e7eb; border-radius:8px; font-size:0.9rem; font-family:'Inter',sans-serif; outline:none; transition:border-color 0.2s;" onfocus="this.style.borderColor='#e85d75'" onblur="this.style.borderColor='#e5e7eb'">
            </div>
        </div>

        <!-- Tabla -->
        <div class="beneficiarios-table">
            <table>
                <thead>
                    <tr>
                        <th>Beneficiario</th>
                        <th>DNI</th>
                        <th>Teléfono</th>
                        <th>Distrito</th>
                        <th>Tipo</th>
                        <th>Necesidad</th>
                        <th>Estado</th>
                        <th>Acciones</th>
                    </tr>
                </thead>
                <tbody id="beneficiarios-tbody">
                    <% if (!beneficiarios.isEmpty()) {
                        for (Beneficiario b : beneficiarios) { %>
                        <tr class="beneficiario-row" data-id="<%= b.getIdBeneficiario() %>"
                            data-nombres="<%= b.getNombres() != null ? b.getNombres() : "" %>"
                            data-apellidos="<%= b.getApellidos() != null ? b.getApellidos() : "" %>">
                            <td>
                                <div class="beneficiario-nombre">
                                    <strong><%= b.getNombres() %> <%= b.getApellidos() %></strong>
                                    <small><%= b.getObservaciones() != null && b.getObservaciones().length() > 40
                                        ? b.getObservaciones().substring(0, 40) + "..."
                                        : (b.getObservaciones() != null ? b.getObservaciones() : "") %></small>
                                </div>
                            </td>
                            <td><span class="badge-dni"><%= b.getDni() %></span></td>
                            <td><%= b.getTelefono() != null ? b.getTelefono() : "—" %></td>
                            <td><%= b.getDistrito() != null ? b.getDistrito() : "—" %></td>
                            <td><span class="badge-tipo <%= b.getTipoBeneficiario().toLowerCase() %>"><%= b.getTipoBeneficiario() %></span></td>
                            <td><span class="badge-necesidad"><%= b.getNecesidadPrincipal() %></span></td>
                            <td>
                                <span class="estado-badge <%= b.getEstado().equals("ACTIVO") ? "activo" : "inactivo" %>">
                                    <%= b.getEstado() %>
                                </span>
                            </td>
                            <td class="acciones-cell">
                                <button class="btn-icon ver" onclick="verDetalle(<%= b.getIdBeneficiario() %>)" title="Ver detalle">👁</button>
                                <button class="btn-icon edit" onclick="abrirModalEditar(<%= b.getIdBeneficiario() %>)" title="Editar">✎</button>
                                <% if (b.getEstado().equals("ACTIVO")) { %>
                                    <button class="btn-icon disable" onclick="cambiarEstado(<%= b.getIdBeneficiario() %>, 'INACTIVO')" title="Desactivar">⊘</button>
                                <% } else { %>
                                    <button class="btn-icon enable" onclick="cambiarEstado(<%= b.getIdBeneficiario() %>, 'ACTIVO')" title="Activar">✓</button>
                                <% } %>
                                <button class="btn-icon delete" onclick="eliminarBeneficiario(<%= b.getIdBeneficiario() %>)" title="Eliminar">✕</button>
                            </td>
                        </tr>
                    <% } } else { %>
                        <tr id="sinBeneficiariosRow">
                            <td colspan="8" style="text-align:center; padding:2rem; color:#999;">
                                No hay beneficiarios registrados
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        </div>

        <!-- Paginación -->
        <div id="paginacionBeneficiarios" style="display:flex; justify-content:flex-end; align-items:center; padding:1rem 1.5rem; background:#fff; border-top:1px solid #f0f0f0; border-radius:0 0 12px 12px; gap:0.5rem; font-family:'Inter',sans-serif;">
            <span id="paginacionInfo" style="margin-right:auto; font-size:0.85rem; color:#6b7280;"></span>
            <button id="btnPrevBen" onclick="cambiarPaginaBen(-1)" disabled style="display:inline-flex; align-items:center; gap:0.4rem; padding:0.5rem 0.9rem; border:1px solid #e5e7eb; background:#fff; color:#4b5563; border-radius:8px; font-size:0.82rem; font-weight:500; cursor:pointer;">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
                Anterior
            </button>
            <div id="paginacionPages" style="display:flex; gap:0.25rem;"></div>
            <button id="btnNextBen" onclick="cambiarPaginaBen(1)" disabled style="display:inline-flex; align-items:center; gap:0.4rem; padding:0.5rem 0.9rem; border:1px solid #e5e7eb; background:#fff; color:#4b5563; border-radius:8px; font-size:0.82rem; font-weight:500; cursor:pointer;">
                Siguiente
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
            </button>
        </div>

    </div>
</main>

<!-- ══════════════════════════════════════════════════
     MODAL CREAR / EDITAR BENEFICIARIO
     ══════════════════════════════════════════════════ -->
<div id="modalBeneficiario" class="modal-overlay">
    <div class="modal-container">
        <div class="modal-card">
            <!-- Header -->
            <div class="modal-header-enhanced">
                <div class="modal-header-content">
                    <h2 id="modalTitulo" class="modal-title">Nuevo Beneficiario</h2>
                    <p class="modal-subtitle">Ingresa la información del beneficiario</p>
                </div>
                <button class="modal-close-btn" onclick="cerrarModal()" title="Cerrar">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <line x1="18" y1="6" x2="6" y2="18"></line>
                        <line x1="6" y1="6" x2="18" y2="18"></line>
                    </svg>
                </button>
            </div>

            <!-- Form -->
            <form id="formBeneficiario" onsubmit="guardarBeneficiario(event)" class="modal-form">
                <input type="hidden" id="beneficiarioId">

                <div class="form-grid">
                    <!-- DNI -->
                    <div class="form-group">
                        <label for="dni" class="form-label">
                            <span class="label-text">DNI</span>
                            <span class="required-indicator">*</span>
                        </label>
                        <div class="input-wrapper" style="display:flex; gap:0.5rem;">
                            <svg class="input-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <rect x="2" y="4" width="20" height="16" rx="2" ry="2"></rect>
                                <rect x="2" y="4" width="20" height="8"></rect>
                            </svg>
                            <input type="text" id="dni" name="dni" class="form-input" placeholder="12345678" maxlength="20" required style="flex:1;">
                            <button type="button" class="btn-search-dni" onclick="buscarYLlenarDatos()" title="Buscar datos en API"
                                style="padding:0.5rem 0.8rem; background:#e85d75; color:white; border:none; border-radius:6px; cursor:pointer; font-size:0.9rem; white-space:nowrap;">
                                🔍 Buscar
                            </button>
                        </div>
                    </div>

                    <!-- Nombres -->
                    <div class="form-group">
                        <label for="nombres" class="form-label">
                            <span class="label-text">Nombres</span>
                            <span class="required-indicator">*</span>
                        </label>
                        <div class="input-wrapper">
                            <svg class="input-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                                <circle cx="12" cy="7" r="4"></circle>
                            </svg>
                            <input type="text" id="nombres" name="nombres" class="form-input" placeholder="María" required>
                        </div>
                    </div>

                    <!-- Apellidos -->
                    <div class="form-group">
                        <label for="apellidos" class="form-label">
                            <span class="label-text">Apellidos</span>
                            <span class="required-indicator">*</span>
                        </label>
                        <div class="input-wrapper">
                            <svg class="input-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                                <circle cx="12" cy="7" r="4"></circle>
                            </svg>
                            <input type="text" id="apellidos" name="apellidos" class="form-input" placeholder="López García" required>
                        </div>
                    </div>

                    <!-- Fecha Nacimiento -->
                    <div class="form-group">
                        <label for="fechaNacimiento" class="form-label">
                            <span class="label-text">Fecha de Nacimiento</span>
                        </label>
                        <div class="input-wrapper">
                            <svg class="input-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <rect x="3" y="4" width="18" height="18" rx="2" ry="2"/>
                                <line x1="16" y1="2" x2="16" y2="6"/>
                                <line x1="8" y1="2" x2="8" y2="6"/>
                                <line x1="3" y1="10" x2="21" y2="10"/>
                            </svg>
                            <input type="date" id="fechaNacimiento" name="fechaNacimiento" class="form-input">
                        </div>
                    </div>

                    <!-- Teléfono -->
                    <div class="form-group">
                        <label for="telefono" class="form-label">
                            <span class="label-text">Teléfono</span>
                        </label>
                        <div class="input-wrapper">
                            <svg class="input-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"></path>
                            </svg>
                            <input type="tel" id="telefono" name="telefono" class="form-input" placeholder="987 654 321">
                        </div>
                    </div>

                    <!-- Dirección -->
                    <div class="form-group full-width">
                        <label for="direccion" class="form-label">
                            <span class="label-text">Dirección</span>
                        </label>
                        <div class="input-wrapper">
                            <svg class="input-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/>
                                <circle cx="12" cy="10" r="3"/>
                            </svg>
                            <input type="text" id="direccion" name="direccion" class="form-input" placeholder="Av. Los Olivos 456">
                        </div>
                    </div>

                    <!-- Distrito -->
                    <div class="form-group">
                        <label for="distrito" class="form-label">
                            <span class="label-text">Distrito</span>
                        </label>
                        <div class="input-wrapper">
                            <svg class="input-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <circle cx="12" cy="12" r="10"/>
                                <line x1="2" y1="12" x2="22" y2="12"/>
                                <path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/>
                            </svg>
                            <input type="text" id="distrito" name="distrito" class="form-input" placeholder="Los Olivos">
                        </div>
                    </div>

                    <!-- Tipo Beneficiario -->
                    <div class="form-group">
                        <label for="tipoBeneficiario" class="form-label">
                            <span class="label-text">Tipo</span>
                            <span class="required-indicator">*</span>
                        </label>
                        <div class="input-wrapper">
                            <svg class="input-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
                                <circle cx="9" cy="7" r="4"/>
                                <path d="M23 21v-2a4 4 0 0 0-3-3.87"/>
                                <path d="M16 3.13a4 4 0 0 1 0 7.75"/>
                            </svg>
                            <select id="tipoBeneficiario" name="tipoBeneficiario" class="form-input" required>
                                <option value="INDIVIDUAL">Individual</option>
                                <option value="FAMILIA">Familia</option>
                                <option value="COMUNIDAD">Comunidad</option>
                            </select>
                        </div>
                    </div>

                    <!-- Necesidad Principal -->
                    <div class="form-group">
                        <label for="necesidadPrincipal" class="form-label">
                            <span class="label-text">Necesidad Principal</span>
                            <span class="required-indicator">*</span>
                        </label>
                        <div class="input-wrapper">
                            <svg class="input-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/>
                            </svg>
                            <select id="necesidadPrincipal" name="necesidadPrincipal" class="form-input" required>
                                <option value="ALIMENTACIÓN">Alimentación</option>
                                <option value="SALUD">Salud</option>
                                <option value="EDUCACIÓN">Educación</option>
                                <option value="VIVIENDA">Vivienda</option>
                                <option value="OTRO">Otro</option>
                            </select>
                        </div>
                    </div>

                    <!-- Observaciones -->
                    <div class="form-group full-width">
                        <label for="observaciones" class="form-label">
                            <span class="label-text">Observaciones</span>
                        </label>
                        <textarea id="observaciones" name="observaciones" class="form-textarea"
                                  placeholder="Información adicional sobre el beneficiario..." rows="2"></textarea>
                    </div>
                </div>

                <!-- Footer -->
                <div class="modal-footer-enhanced">
                    <button type="button" class="btn-cancel" onclick="cerrarModal()">
                        <span>Cancelar</span>
                    </button>
                    <button type="submit" class="btn-submit">
                        <span id="btnGuardarTexto">Registrar Beneficiario</span>
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- ══════════════════════════════════════════════════
     MODAL VER DETALLE
     ══════════════════════════════════════════════════ -->
<div id="modalDetalle" class="modal-overlay">
    <div class="modal-container">
        <div class="modal-card detalle-card">
            <!-- Header -->
            <div class="modal-header-enhanced detalle-header">
                <div class="modal-header-content">
                    <h2 class="modal-title">Detalle del Beneficiario</h2>
                    <p class="modal-subtitle" id="detalleSubtitulo">Información completa</p>
                </div>
                <button class="modal-close-btn" onclick="cerrarModalDetalle()" title="Cerrar">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <line x1="18" y1="6" x2="6" y2="18"></line>
                        <line x1="6" y1="6" x2="18" y2="18"></line>
                    </svg>
                </button>
            </div>

            <!-- Cuerpo detalle -->
            <div class="detalle-body" id="detalleBody">
                <!-- Se llena via JS -->
            </div>

            <div class="detalle-footer">
                <button type="button" class="btn btn-secondary" onclick="cerrarModalDetalle()">Cerrar</button>
            </div>
        </div>
    </div>
</div>

<!-- Notificación Toast -->
<div id="toast" class="toast"></div>

<script src="${pageContext.request.contextPath}/js/dni-api.js"></script>
<script src="${pageContext.request.contextPath}/js/beneficiarios.js"></script>

</body>
</html>
