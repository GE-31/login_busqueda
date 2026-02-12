<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page import="com.sistemadevoluntariado.model.Usuario" %>
        <%@ page import="com.sistemadevoluntariado.model.Voluntario" %>
            <%@ page import="java.util.List" %>
                <%@ page import="java.util.ArrayList" %>

                    <% HttpSession ses=request.getSession(false); Usuario usuario=(Usuario)
                        (request.getAttribute("usuario") !=null ? request.getAttribute("usuario") : (ses !=null ?
                        ses.getAttribute("usuarioLogeado") : null)); if (usuario==null) {
                        response.sendRedirect(request.getContextPath() + "/login" ); return; } List<Voluntario>
                        voluntarios = (List<Voluntario>) request.getAttribute("voluntarios");
                            if (voluntarios == null) voluntarios = new ArrayList<>();
                                request.setAttribute("page", "voluntarios");
                                %>

                                <!DOCTYPE html>
                                <html lang="es">

                                <head>
                                    <meta charset="UTF-8">
                                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                                    <title>Voluntarios - Sistema de Voluntariado</title>

                                    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/dashboard.css">
                                    <link rel="stylesheet"
                                        href="${pageContext.request.contextPath}/css/voluntarios.css">
                                    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css">

                                    <link
                                        href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap"
                                        rel="stylesheet">

                                </head>

                                <body>
                                    <jsp:include page="/includes/sidebar.jsp" />



                                    <main class="main-content">
                                        <jsp:include page="/includes/topbar.jsp" />

                                        <div class="content-body">

                                            <div class="voluntarios-header">
                                                <div>
                                                    <h1>Gestión de Voluntarios</h1>
                                                    <p>Administra los voluntarios del sistema</p>
                                                </div>
                                                <button class="btn btn-primary" onclick="abrirModalCrear()">
                                                    <span>+</span> Crear Voluntario
                                                </button>
                                            </div>

                                            <!-- Barra de búsqueda -->
                                            <div style="margin-bottom:1rem; display:flex; align-items:center; gap:0.5rem;">
                                                <div style="position:relative; flex:1; max-width:400px;">
                                                    <svg style="position:absolute; left:12px; top:50%; transform:translateY(-50%); color:#9ca3af;" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                                                    <input type="text" id="buscarVoluntario" placeholder="Buscar por nombre o apellido..." oninput="filtrarVoluntarios()" style="width:100%; padding:0.6rem 0.75rem 0.6rem 2.5rem; border:1px solid #e5e7eb; border-radius:8px; font-size:0.9rem; font-family:'Inter',sans-serif; outline:none; transition:border-color 0.2s;" onfocus="this.style.borderColor='#667eea'" onblur="this.style.borderColor='#e5e7eb'">
                                                </div>
                                            </div>

                                            <div class="voluntarios-table">
                                                <table>
                                                    <thead>
                                                        <tr>
                                                            <th>Nombre</th>
                                                            <th>DNI</th>
                                                            <th>Correo</th>
                                                            <th>Teléfono</th>
                                                            <th>Carrera</th>
                                                            <th>Estado</th>
                                                            <th>Acciones</th>
                                                        </tr>
                                                    </thead>

                                                    <tbody id="voluntarios-tbody">

                                                        <% if (!voluntarios.isEmpty()) { for (Voluntario v :
                                                            voluntarios) { %>

                                                            <tr class="voluntario-row"
                                                                data-id="<%= v.getIdVoluntario() %>"
                                                                data-nombres="<%= v.getNombres() != null ? v.getNombres() : "" %>"
                                                                data-apellidos="<%= v.getApellidos() != null ? v.getApellidos() : "" %>">
                                                                <td><strong>
                                                                        <%= v.getNombres() %>
                                                                            <%= v.getApellidos() %>
                                                                    </strong></td>
                                                                <td><span class="badge-dni">
                                                                        <%= v.getDni() %>
                                                                    </span></td>
                                                                <td>
                                                                    <%= v.getCorreo() %>
                                                                </td>
                                                                <td>
                                                                    <%= v.getTelefono() %>
                                                                </td>
                                                                <td>
                                                                    <%= v.getCarrera() %>
                                                                </td>

                                                                <td>
                                                                    <span class="estado-badge 
                                    <%= v.getEstado().equals(" ACTIVO") ? "activo" : "inactivo" %>">
                                                                        <%= v.getEstado() %>
                                                                    </span>
                                                                </td>


                                                                <td class="acciones-cell">
                                                                    <button class="btn-icon edit"
                                                                        onclick="abrirModalEditar(<%= v.getIdVoluntario() %>)"
                                                                        title="Editar">✎</button>

                                                                    <% if (v.getEstado().equals("ACTIVO")) { %>
                                                                        <button class="btn-icon disable"
                                                                            onclick="cambiarEstado(<%= v.getIdVoluntario() %>, 'INACTIVO')"
                                                                            title="Deshabilitar">⊘</button>
                                                                        <% } else { %>
                                                                            <button class="btn-icon enable"
                                                                                onclick="cambiarEstado(<%= v.getIdVoluntario() %>, 'ACTIVO')"
                                                                                title="Habilitar">✓</button>
                                                                            <% } %>


                                                                </td>
                                                            </tr>

                                                            <% } /* FIN FOR */ } else { %>

                                                                <tr id="sinVoluntariosRow">
                                                                    <td colspan="7" style="text-align:center; padding:2rem; color:#999;">No hay
                                                                        voluntarios registrados</td>
                                                                </tr>

                                                                <% } %>

                                                    </tbody>
                                                </table>
                                            </div>

                                            <!-- Paginación -->
                                            <div id="paginacionVoluntarios" style="display:flex; justify-content:flex-end; align-items:center; padding:1rem 1.5rem; background:#fff; border-top:1px solid #f0f0f0; border-radius:0 0 12px 12px; gap:0.5rem; font-family:'Inter',sans-serif;">
                                                <span id="paginacionInfo" style="margin-right:auto; font-size:0.85rem; color:#6b7280;"></span>
                                                <button id="btnPrevVol" onclick="cambiarPaginaVol(-1)" disabled style="display:inline-flex; align-items:center; gap:0.4rem; padding:0.5rem 0.9rem; border:1px solid #e5e7eb; background:#fff; color:#4b5563; border-radius:8px; font-size:0.82rem; font-weight:500; cursor:pointer;">
                                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
                                                    Anterior
                                                </button>
                                                <div id="paginacionPages" style="display:flex; gap:0.25rem;"></div>
                                                <button id="btnNextVol" onclick="cambiarPaginaVol(1)" disabled style="display:inline-flex; align-items:center; gap:0.4rem; padding:0.5rem 0.9rem; border:1px solid #e5e7eb; background:#fff; color:#4b5563; border-radius:8px; font-size:0.82rem; font-weight:500; cursor:pointer;">
                                                    Siguiente
                                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
                                                </button>
                                            </div>

                                        </div>
                                    </main>
 
                                    <!-- MODAL CREAR/EDITAR -->
                                    <div id="modalVoluntario" class="modal-overlay">
                                        <div class="modal-container">
                                            <div class="modal-card">
                                                <!-- Header -->
                                                <div class="modal-header-enhanced">
                                                    <div class="modal-header-content">
                                                        <h2 id="modalTitulo" class="modal-title">Crear Voluntario</h2>
                                                        <p class="modal-subtitle">Ingresa la información del nuevo
                                                            voluntario</p>
                                                    </div>
                                                    <button class="modal-close-btn" onclick="cerrarModal()"
                                                        title="Cerrar">
                                                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none"
                                                            stroke="currentColor" stroke-width="2">
                                                            <line x1="18" y1="6" x2="6" y2="18"></line>
                                                            <line x1="6" y1="6" x2="18" y2="18"></line>
                                                        </svg>
                                                    </button>
                                                </div>

                                                <!-- Form Body -->
                                                <form id="formVoluntario" onsubmit="guardarVoluntario(event)"
                                                    class="modal-form">
                                                    <input type="hidden" id="voluntarioId">

                                                    <div class="form-grid">
                                                        <!-- DNI -->
                                                        <div class="form-group">
                                                            <label for="dni" class="form-label">
                                                                <span class="label-text">DNI</span>
                                                                <span class="required-indicator">*</span>
                                                            </label>
                                                            <div class="input-wrapper"
                                                                style="display: flex; gap: 0.5rem;">
                                                                <svg class="input-icon" width="18" height="18"
                                                                    viewBox="0 0 24 24" fill="none"
                                                                    stroke="currentColor" stroke-width="2">
                                                                    <rect x="2" y="4" width="20" height="16" rx="2"
                                                                        ry="2"></rect>
                                                                    <rect x="2" y="4" width="20" height="8"></rect>
                                                                </svg>
                                                                <input type="text" id="dni" name="dni"
                                                                    class="form-input" placeholder="12345678"
                                                                    maxlength="20" required style="flex: 1;">
                                                                <button type="button" class="btn-search-dni"
                                                                    onclick="buscarYLlenarDatos()"
                                                                    title="Buscar datos en API"
                                                                    style="padding: 0.5rem 0.8rem; background: #667eea; color: white; border: none; border-radius: 6px; cursor: pointer; font-size: 0.9rem; white-space: nowrap;">🔍
                                                                    Buscar</button>
                                                            </div>
                                                        </div>
                                                        <!-- Nombres -->
                                                        <div class="form-group">
                                                            <label for="nombres" class="form-label">
                                                                <span class="label-text">Nombres</span>
                                                                <span class="required-indicator">*</span>
                                                            </label>
                                                            <div class="input-wrapper">
                                                                <svg class="input-icon" width="18" height="18"
                                                                    viewBox="0 0 24 24" fill="none"
                                                                    stroke="currentColor" stroke-width="2">
                                                                    <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2">
                                                                    </path>
                                                                    <circle cx="12" cy="7" r="4"></circle>
                                                                </svg>
                                                                <input type="text" id="nombres" name="nombres"
                                                                    class="form-input" placeholder="Juan" required>
                                                            </div>
                                                        </div>

                                                        <!-- Apellidos -->
                                                        <div class="form-group">
                                                            <label for="apellidos" class="form-label">
                                                                <span class="label-text">Apellidos</span>
                                                                <span class="required-indicator">*</span>
                                                            </label>
                                                            <div class="input-wrapper">
                                                                <svg class="input-icon" width="18" height="18"
                                                                    viewBox="0 0 24 24" fill="none"
                                                                    stroke="currentColor" stroke-width="2">
                                                                    <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2">
                                                                    </path>
                                                                    <circle cx="12" cy="7" r="4"></circle>
                                                                </svg>
                                                                <input type="text" id="apellidos" name="apellidos"
                                                                    class="form-input" placeholder="Pérez" required>
                                                            </div>
                                                        </div>



                                                        <!-- Correo -->
                                                        <div class="form-group">
                                                            <label for="correo" class="form-label">
                                                                <span class="label-text">Correo Electrónico</span>
                                                                <span class="required-indicator">*</span>
                                                            </label>
                                                            <div class="input-wrapper">
                                                                <svg class="input-icon" width="18" height="18"
                                                                    viewBox="0 0 24 24" fill="none"
                                                                    stroke="currentColor" stroke-width="2">
                                                                    <rect x="2" y="4" width="20" height="16" rx="2">
                                                                    </rect>
                                                                    <path d="m22 7-8.97 5.7a1.94 1.94 0 0 1-2.06 0L2 7">
                                                                    </path>
                                                                </svg>
                                                                <input type="email" id="correo" name="correo"
                                                                    class="form-input" placeholder="juan@example.com"
                                                                    required>
                                                            </div>
                                                        </div>

                                                        <!-- Teléfono -->
                                                        <div class="form-group">
                                                            <label for="telefono" class="form-label">
                                                                <span class="label-text">Teléfono</span>
                                                                <span class="required-indicator">*</span>
                                                            </label>
                                                            <div class="input-wrapper">
                                                                <svg class="input-icon" width="18" height="18"
                                                                    viewBox="0 0 24 24" fill="none"
                                                                    stroke="currentColor" stroke-width="2">
                                                                    <path
                                                                        d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z">
                                                                    </path>
                                                                </svg>
                                                                <input type="tel" id="telefono" name="telefono"
                                                                    class="form-input" placeholder=" 923 456 789"
                                                                    required>
                                                            </div>
                                                        </div>

                                                        <!-- Carrera -->
                                                        <div class="form-group full-width">
                                                            <label for="carrera" class="form-label">
                                                                <span class="label-text">Carrera / Especialidad</span>
                                                                <span class="required-indicator">*</span>
                                                            </label>
                                                            <div class="input-wrapper">
                                                                <svg class="input-icon" width="18" height="18"
                                                                    viewBox="0 0 24 24" fill="none"
                                                                    stroke="currentColor" stroke-width="2">
                                                                    <path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path>
                                                                    <path
                                                                        d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z">
                                                                    </path>
                                                                </svg>
                                                                <input type="text" id="carrera" name="carrera"
                                                                    class="form-input"
                                                                    placeholder="Ingeniería en Sistemas" required>
                                                            </div>
                                                        </div>

                                                        <!-- Cargo -->
                                                        <div class="form-group full-width">
                                                            <label for="cargo" class="form-label">
                                                                <span class="label-text">Cargo</span>
                                                                <span class="required-indicator">*</span>
                                                            </label>
                                                            <div class="input-wrapper">
                                                                <svg class="input-icon" width="18" height="18"
                                                                    viewBox="0 0 24 24" fill="none"
                                                                    stroke="currentColor" stroke-width="2">
                                                                    <path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2">
                                                                    </path>
                                                                    <circle cx="8.5" cy="7" r="4"></circle>
                                                                    <polyline points="17 11 19 13 23 9"></polyline>
                                                                </svg>
                                                                <select id="cargo" name="cargo" class="form-input"
                                                                    required>
                                                                    <option value="">Seleccione un cargo</option>
                                                                    <option value="Voluntario">Voluntario</option>
                                                                    <option value="Líder de Equipo">Líder de Equipo
                                                                    </option>
                                                                    <option value="Encargado de Logística">Encargado de
                                                                        Logística</option>
                                                                    <option value="Coordinador de Proyecto">Coordinador
                                                                        de Proyecto</option>
                                                                    <option value="Administrador del Sistema">
                                                                        Administrador del Sistema</option>
                                                                </select>
                                                            </div>
                                                        </div>
                                                    </div>

                                                    <!-- Footer -->
                                                    <div class="modal-footer-enhanced">
                                                        <button type="button" class="btn-cancel"
                                                            onclick="cerrarModal()">
                                                            <span>Cancelar</span>
                                                        </button>
                                                        <button type="submit" class="btn-submit">
                                                            <span>Guardar Voluntario</span>
                                                        </button>
                                                    </div>
                                                </form>
                                            </div>
                                        </div>
                                    </div>

                                    <script src="${pageContext.request.contextPath}/js/dni-api.js"></script>
                                    <script src="${pageContext.request.contextPath}/js/voluntarios.js"></script>

                                </body>

                                </html>