<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page import="com.sistemadevoluntariado.model.Usuario" %>
        <%@ page import="com.sistemadevoluntariado.model.Voluntario" %>
            <%@ page import="com.sistemadevoluntariado.model.RolSistema" %>
                <%@ page import="java.util.List" %>
                    <%@ page import="java.util.ArrayList" %>

                        <% HttpSession ses=request.getSession(false); Usuario usuario=(Usuario)
                            (request.getAttribute("usuario") !=null ? request.getAttribute("usuario") : (ses !=null ?
                            ses.getAttribute("usuarioLogeado") : null)); if (usuario==null) {
                            response.sendRedirect(request.getContextPath() + "/login" ); return; } List<Usuario>
                            usuarios = (List<Usuario>) request.getAttribute("usuarios");
                                if (usuarios == null) usuarios = new ArrayList<>();

                                    List<Voluntario> voluntarios = (List<Voluntario>)
                                            request.getAttribute("voluntarios");
                                            if (voluntarios == null) voluntarios = new ArrayList<>();

                                                List<RolSistema> roles = (List<RolSistema>)
                                                        request.getAttribute("roles");
                                                        if (roles == null) roles = new ArrayList<>();

                                                            request.setAttribute("page", "usuarios");
                                                        
                                                            %>
                                                            <!DOCTYPE html>
                                                            <html lang="es">

                                                            <head>
                                                                <meta charset="UTF-8">
                                                                <meta name="viewport"
                                                                    content="width=device-width, initial-scale=1.0">
                                                                <title>Usuarios - Sistema de Voluntariado</title>

                                                                <link rel="stylesheet"
                                                                    href="${pageContext.request.contextPath}/css/dashboard.css">
                                                                <link rel="stylesheet"
                                                                    href="${pageContext.request.contextPath}/css/usuarios.css">
                                                                <link rel="stylesheet"
                                                                    href="${pageContext.request.contextPath}/css/sidebar.css">

                                                                <link
                                                                    href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap"
                                                                    rel="stylesheet">

                                            
                                                            </head>

                                                            <body>
                                                                <jsp:include page="/includes/sidebar.jsp" />

                                                                <main class="main-content">
                                                                    <jsp:include page="/includes/topbar.jsp" />

                                                                    <div class="content-body">

                                                                        <div class="usuarios-header">
                                                                            <div>
                                                                                <h1>Gestión de Usuarios</h1>
                                                                                <p>Administra los usuarios del sistema
                                                                                </p>
                                                                            </div>
                                                                            <button class="btn btn-primary"
                                                                                onclick="abrirModalCrear()">
                                                                                <span>+</span> Crear Usuario
                                                                            </button>
                                                                        </div>

                                                                        <!-- Barra de búsqueda -->
                                                                        <div style="margin-bottom:1rem; display:flex; align-items:center; gap:0.5rem;">
                                                                            <div style="position:relative; flex:1; max-width:400px;">
                                                                                <svg style="position:absolute; left:12px; top:50%; transform:translateY(-50%); color:#9ca3af;" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                                                                                <input type="text" id="buscarUsuario" placeholder="Buscar por nombre o apellido..." oninput="filtrarUsuarios()" style="width:100%; padding:0.6rem 0.75rem 0.6rem 2.5rem; border:1px solid #e5e7eb; border-radius:8px; font-size:0.9rem; font-family:'Inter',sans-serif; outline:none; transition:border-color 0.2s;" onfocus="this.style.borderColor='#667eea'" onblur="this.style.borderColor='#e5e7eb'">
                                                                            </div>
                                                                        </div>

                                                                        <div class="usuarios-table">
                                                                            <table>
                                                                                <thead>
                                                                                    <tr>
                                                                                        <th>Usuario</th>
                                                                                        <th>Correo</th>
                                                                                        <th>Estado</th>
                                                                                        <th>Creado</th>
                                                                                        <th>Acciones</th>
                                                                                    </tr>
                                                                                </thead>

                                                                                <tbody id="usuarios-tbody">

                                                                                    <% if (!usuarios.isEmpty()) { for
                                                                                        (Usuario u : usuarios) { %>

                                                                                        <tr class="usuario-row"
                                                                                            data-id="<%= u.getIdUsuario() %>"
                                                                                            data-nombres="<%= u.getNombres() != null ? u.getNombres() : "" %>"
                                                                                            data-apellidos="<%= u.getApellidos() != null ? u.getApellidos() : "" %>">
                                                                                            <td><span
                                                                                                    class="badge-username">@
                                                                                                    <%= u.getUsername()
                                                                                                        %>
                                                                                                </span></td>
                                                                                            <td>
                                                                                                <%= u.getCorreo() !=null
                                                                                                    ? u.getCorreo()
                                                                                                    : "N/A" %>
                                                                                            </td>

                                                                                            <td>
                                                                                                <span class="estado-badge 
                                    <%= u.getEstado() != null && u.getEstado().equals(" ACTIVO") ? "activo"
                                                                                                    : "inactivo" %>">
                                                                                                    <%= u.getEstado() %>
                                                                                                </span>
                                                                                            </td>

                                                                                            <td class="fecha">
                                                                                                <small>
                                                                                                    <%= u.getCreadoEn()
                                                                                                        !=null ?
                                                                                                        u.getCreadoEn()
                                                                                                        : "N/A" %>
                                                                                                </small>
                                                                                            </td>

                                                                                            <td class="acciones-cell">
                                                                                                <button
                                                                                                    class="btn-icon edit"
                                                                                                    onclick="abrirModalEditar(<%= u.getIdUsuario() %>)"
                                                                                                    title="Editar">✎</button>

                                                                                                <% if (u.getEstado()
                                                                                                    !=null &&
                                                                                                    u.getEstado().equals("ACTIVO"))
                                                                                                    { %>
                                                                                                    <button
                                                                                                        class="btn-icon disable"
                                                                                                        onclick="cambiarEstado(<%= u.getIdUsuario() %>, 'INACTIVO')"
                                                                                                        title="Deshabilitar">⊘</button>
                                                                                                    <% } else { %>
                                                                                                        <button
                                                                                                            class="btn-icon enable"
                                                                                                            onclick="cambiarEstado(<%= u.getIdUsuario() %>, 'ACTIVO')"
                                                                                                            title="Habilitar">✓</button>
                                                                                                        <% } %>


                                                                                            </td>
                                                                                        </tr>

                                                                                        <% } /* FIN FOR */ } else { %>

                                                                                            <tr id="sinUsuariosRow">
                                                                                                <td colspan="5" style="text-align:center; padding:2rem; color:#999;">No hay usuarios registrados</td>
                                                                                            </tr>

                                                                                            <% } %>

                                                                                </tbody>
                                                                            </table>
                                                                        </div>

                                                                        <!-- Paginación -->
                                                                        <div id="paginacionUsuarios" style="display:flex; justify-content:flex-end; align-items:center; padding:1rem 1.5rem; background:#fff; border-top:1px solid #f0f0f0; border-radius:0 0 12px 12px; gap:0.5rem; font-family:'Inter',sans-serif;">
                                                                            <span id="paginacionInfoUsr" style="margin-right:auto; font-size:0.85rem; color:#6b7280;"></span>
                                                                            <button id="btnPrevUsr" onclick="cambiarPaginaUsr(-1)" disabled style="display:inline-flex; align-items:center; gap:0.4rem; padding:0.5rem 0.9rem; border:1px solid #e5e7eb; background:#fff; color:#4b5563; border-radius:8px; font-size:0.82rem; font-weight:500; cursor:pointer;">
                                                                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
                                                                                Anterior
                                                                            </button>
                                                                            <div id="paginacionPagesUsr" style="display:flex; gap:0.25rem;"></div>
                                                                            <button id="btnNextUsr" onclick="cambiarPaginaUsr(1)" disabled style="display:inline-flex; align-items:center; gap:0.4rem; padding:0.5rem 0.9rem; border:1px solid #e5e7eb; background:#fff; color:#4b5563; border-radius:8px; font-size:0.82rem; font-weight:500; cursor:pointer;">
                                                                                Siguiente
                                                                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
                                                                            </button>
                                                                        </div>

                                                                    </div>
                                                                </main>

                                                                <!-- MODAL CREAR/EDITAR -->
                                                                <div id="modalUsuario" class="modal-overlay">
                                                                    <div class="modal-container">
                                                                        <div class="modal-card">
                                                                            <!-- Header -->
                                                                            <div class="modal-header-enhanced">
                                                                                <div class="modal-header-content">
                                                                                    <h2 id="modalTitulo"
                                                                                        class="modal-title">Crear
                                                                                        Usuario</h2>
                                                                                    <p class="modal-subtitle">Ingresa la
                                                                                        información del nuevo usuario
                                                                                    </p>
                                                                                </div>
                                                                                <button class="modal-close-btn"
                                                                                    onclick="cerrarModal()"
                                                                                    title="Cerrar">
                                                                                    <svg width="24" height="24"
                                                                                        viewBox="0 0 24 24" fill="none"
                                                                                        stroke="currentColor"
                                                                                        stroke-width="2">
                                                                                        <line x1="18" y1="6" x2="6"
                                                                                            y2="18"></line>
                                                                                        <line x1="6" y1="6" x2="18"
                                                                                            y2="18"></line>
                                                                                    </svg>
                                                                                </button>
                                                                            </div>

                                                                            <!-- Form Body -->
                                                                            <form id="formUsuario"
                                                                                onsubmit="guardarUsuario(event)"
                                                                                class="modal-form">
                                                                                <input type="hidden" id="usuarioId">

                                                                                <div class="form-grid">
                                                                                    <!-- Voluntario -->
                                                                                    <div class="form-group full-width">
                                                                                        <label for="voluntarioId"
                                                                                            class="form-label">
                                                                                            <span
                                                                                                class="label-text">Seleccionar
                                                                                                Voluntario</span>
                                                                                            <span
                                                                                                class="required-indicator">*</span>
                                                                                        </label>
                                                                                        <div class="input-wrapper">
                                                                                            <svg class="input-icon"
                                                                                                width="18" height="18"
                                                                                                viewBox="0 0 24 24"
                                                                                                fill="none"
                                                                                                stroke="currentColor"
                                                                                                stroke-width="2">
                                                                                                <path
                                                                                                    d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2">
                                                                                                </path>
                                                                                                <circle cx="12" cy="7"
                                                                                                    r="4">
                                                                                                </circle>
                                                                                            </svg>
                                                                                            <select id="voluntarioId"
                                                                                                name="voluntarioId"
                                                                                                class="form-input"
                                                                                                required>
                                                                                                <option value="">
                                                                                                    Seleccione un
                                                                                                    voluntario</option>
                                                                                                <% for (Voluntario vol :
                                                                                                    voluntarios) { %>
                                                                                                    <option
                                                                                                        value="<%= vol.getIdVoluntario() %>">
                                                                                                        <%= vol.getNombres()
                                                                                                            %>
                                                                                                            <%= vol.getApellidos()
                                                                                                                %> -
                                                                                                                DNI: <%=
                                                                                                                    vol.getDni()
                                                                                                                    %>
                                                                                                    </option>
                                                                                                    <% } %>
                                                                                            </select>
                                                                                        </div>
                                                                                    </div>

                                                                                    <!-- Nombre de Usuario -->
                                                                                    <div class="form-group">
                                                                                        <label for="username"
                                                                                            class="form-label">
                                                                                            <span
                                                                                                class="label-text">Nombre
                                                                                                de Usuario</span>
                                                                                            <span
                                                                                                class="required-indicator">*</span>
                                                                                        </label>
                                                                                        <div class="input-wrapper">
                                                                                            <svg class="input-icon"
                                                                                                width="18" height="18"
                                                                                                viewBox="0 0 24 24"
                                                                                                fill="none"
                                                                                                stroke="currentColor"
                                                                                                stroke-width="2">
                                                                                                <rect x="3" y="11"
                                                                                                    width="18"
                                                                                                    height="11" rx="2"
                                                                                                    ry="2">
                                                                                                </rect>
                                                                                                <path
                                                                                                    d="M7 11V7a5 5 0 0 1 10 0v4">
                                                                                                </path>
                                                                                            </svg>
                                                                                            <input type="text"
                                                                                                id="username"
                                                                                                name="username"
                                                                                                class="form-input"
                                                                                                placeholder="usuario_sistema"
                                                                                                required>
                                                                                        </div>
                                                                                    </div>

                                                                                    <!-- Rol del Sistema -->
                                                                                    <div class="form-group">
                                                                                        <label for="rolSistema"
                                                                                            class="form-label">
                                                                                            <span class="label-text">Rol
                                                                                                del Sistema</span>
                                                                                            <span
                                                                                                class="required-indicator">*</span>
                                                                                        </label>
                                                                                        <div class="input-wrapper">
                                                                                            <svg class="input-icon"
                                                                                                width="18" height="18"
                                                                                                viewBox="0 0 24 24"
                                                                                                fill="none"
                                                                                                stroke="currentColor"
                                                                                                stroke-width="2">
                                                                                                <path
                                                                                                    d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2">
                                                                                                </path>
                                                                                                <circle cx="8.5" cy="7"
                                                                                                    r="4">
                                                                                                </circle>
                                                                                                <polyline
                                                                                                    points="17 11 19 13 23 9">
                                                                                                </polyline>
                                                                                            </svg>
                                                                                            <select id="rolSistema"
                                                                                                name="rolSistema"
                                                                                                class="form-input"
                                                                                                required>
                                                                                                <option value="">
                                                                                                    Seleccione un rol
                                                                                                </option>
                                                                                                <% for (RolSistema rol :
                                                                                                    roles) { %>
                                                                                                    <option
                                                                                                        value="<%= rol.getIdRolSistema() %>">
                                                                                                        <%= rol.getNombreRol()
                                                                                                            %>
                                                                                                    </option>
                                                                                                    <% } %>
                                                                                            </select>
                                                                                        </div>
                                                                                    </div>

                                                                                    <!-- Contraseña -->
                                                                                    <div class="form-group">
                                                                                        <label for="password"
                                                                                            class="form-label">
                                                                                            <span
                                                                                                class="label-text">Contraseña</span>
                                                                                            <span
                                                                                                class="required-indicator"
                                                                                                id="passwordRequired">*</span>
                                                                                        </label>
                                                                                        <div class="input-wrapper">
                                                                                            <svg class="input-icon"
                                                                                                width="18" height="18"
                                                                                                viewBox="0 0 24 24"
                                                                                                fill="none"
                                                                                                stroke="currentColor"
                                                                                                stroke-width="2">
                                                                                                <rect x="3" y="11"
                                                                                                    width="18"
                                                                                                    height="11" rx="2"
                                                                                                    ry="2">
                                                                                                </rect>
                                                                                                <path
                                                                                                    d="M7 11V7a5 5 0 0 1 10 0v4">
                                                                                                </path>
                                                                                            </svg>
                                                                                            <input type="password"
                                                                                                id="password"
                                                                                                name="password"
                                                                                                class="form-input"
                                                                                                placeholder="••••••••"
                                                                                                minlength="6">
                                                                                        </div>
                                                                                        <small class="help-text">Mínimo
                                                                                            6 caracteres</small>
                                                                                    </div>

                                                                                    <!-- Confirmar Contraseña -->
                                                                                    <div class="form-group">
                                                                                        <label for="confirmPassword"
                                                                                            class="form-label">
                                                                                            <span
                                                                                                class="label-text">Confirmar
                                                                                                Contraseña</span>
                                                                                            <span
                                                                                                class="required-indicator"
                                                                                                id="confirmPasswordRequired">*</span>
                                                                                        </label>
                                                                                        <div class="input-wrapper">
                                                                                            <svg class="input-icon"
                                                                                                width="18" height="18"
                                                                                                viewBox="0 0 24 24"
                                                                                                fill="none"
                                                                                                stroke="currentColor"
                                                                                                stroke-width="2">
                                                                                                <rect x="3" y="11"
                                                                                                    width="18"
                                                                                                    height="11" rx="2"
                                                                                                    ry="2">
                                                                                                </rect>
                                                                                                <path
                                                                                                    d="M7 11V7a5 5 0 0 1 10 0v4">
                                                                                                </path>
                                                                                            </svg>
                                                                                            <input type="password"
                                                                                                id="confirmPassword"
                                                                                                name="confirmPassword"
                                                                                                class="form-input"
                                                                                                placeholder="••••••••"
                                                                                                minlength="6">
                                                                                        </div>
                                                                                        <small class="help-text">Debe
                                                                                            coincidir con la
                                                                                            contraseña</small>
                                                                                    </div>
                                                                                </div>
 
                                                            

                                                                                <!-- PERMISOS DEL USUARIO -->
                                                                                <div class="user-permissions-section">

                                                                                    <div class="permissions-header">
                                                                                        <div class="perm-title">
                                                                                            <svg width="22" height="22" fill="none" stroke="currentColor" stroke-width="2">
                                                                                                <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zM4 20v-1a7 7 0 0 1 14 0v1" />
                                                                                            </svg>
                                                                                            <h3>Permisos del usuario</h3>
                                                                                        </div>

                                                                                        <span id="contadorPermisos" class="perm-count">0 permisos seleccionados</span>
                                                                                    </div>

                                                                                    <div class="permissions-list">

                                                                                        <!-- SECCIÓN: PERSONAS -->
                                                                                        <div class="perm-group">
                                                                                            <div class="perm-group-header">
                                                                                                <div class="group-info">
                                                                                                    <svg width="20" height="20" fill="none" stroke="currentColor" stroke-width="2">
                                                                                                        <circle cx="9" cy="7" r="4"></circle>
                                                                                                        <path d="M17 11l2 2 4-4"/>
                                                                                                        <path d="M3 21v-2a4 4 0 0 1 4-4h4"/>
                                                                                                    </svg>
                                                                                                    <span class="group-title">Personas</span>
                                                                                                    <span class="group-count" id="count-personas">0/8</span>
                                                                                                </div>
                                                                                                <div>
                                                                                                    <input type="checkbox" class="select-all" data-group="personas">
                                                                                                    <label>Seleccionar todo</label>
                                                                                                </div>
                                                                                            </div>

                                                                                            <div class="perm-items">
                                                                                                <!-- EJEMPLO DE PERMISOS (CAMBIA POR LOS TUYOS DE BD) -->
                                                                                                <label class="perm-item">
                                                                                                    <input type="checkbox" class="perm" data-group="personas" value="1">
                                                                                                    Ver personas
                                                                                                </label>
                                                                                                <label class="perm-item">
                                                                                                    <input type="checkbox" class="perm" data-group="personas" value="2">
                                                                                                    Crear personas
                                                                                                </label>
                                                                                                <label class="perm-item">
                                                                                                    <input type="checkbox" class="perm" data-group="personas" value="3">
                                                                                                    Editar personas
                                                                                                </label>
                                                                                                <label class="perm-item">
                                                                                                    <input type="checkbox" class="perm" data-group="personas" value="4">
                                                                                                    Eliminar personas
                                                                                                </label>
                                                                                            </div>
                                                                                        </div>

                                                                                        <!-- SECCIÓN: CATÁLOGO -->
                                                                                        <div class="perm-group">
                                                                                            <div class="perm-group-header">
                                                                                                <div class="group-info">
                                                                                                    <svg width="20" height="20" fill="none" stroke="currentColor" stroke-width="2">
                                                                                                        <rect x="3" y="4" width="18" height="14" rx="2"/>
                                                                                                    </svg>
                                                                                                    <span class="group-title">Catálogo</span>
                                                                                                    <span class="group-count" id="count-catalogo">0/5</span>
                                                                                                </div>
                                                                                                <div>
                                                                                                    <input type="checkbox" class="select-all" data-group="catalogo">
                                                                                                    <label>Seleccionar todo</label>
                                                                                                </div>
                                                                                            </div>

                                                                                            <div class="perm-items">
                                                                                                <label class="perm-item"><input type="checkbox" class="perm" data-group="catalogo" value="5">Ver catálogo</label>
                                                                                                <label class="perm-item"><input type="checkbox" class="perm" data-group="catalogo" value="6">Agregar items</label>
                                                                                                <label class="perm-item"><input type="checkbox" class="perm" data-group="catalogo" value="7">Editar items</label>
                                                                                                <label class="perm-item"><input type="checkbox" class="perm" data-group="catalogo" value="8">Eliminar items</label>
                                                                                            </div>
                                                                                        </div>

                                                                                        <!-- SECCIÓN: OPERACIONES -->
                                                                                        <div class="perm-group">
                                                                                            <div class="perm-group-header">
                                                                                                <div class="group-info">
                                                                                                    <svg width="20" height="20" fill="none" stroke="currentColor">
                                                                                                        <path d="M3 3h18v18H3zM3 9h18"/>
                                                                                                    </svg>
                                                                                                    <span class="group-title">Operaciones</span>
                                                                                                    <span class="group-count" id="count-operaciones">0/8</span>
                                                                                                </div>
                                                                                                <div>
                                                                                                    <input type="checkbox" class="select-all" data-group="operaciones">
                                                                                                    <label>Seleccionar todo</label>
                                                                                                </div>
                                                                                            </div>

                                                                                            <div class="perm-items">
                                                                                                <label class="perm-item"><input type="checkbox" class="perm" data-group="operaciones" value="9">Ver operaciones</label>
                                                                                                <label class="perm-item"><input type="checkbox" class="perm" data-group="operaciones" value="10">Registrar operación</label>
                                                                                            </div>
                                                                                        </div>

                                                                                        <!-- SECCIÓN: AGENDAS -->
                                                                                        <div class="perm-group">
                                                                                            <div class="perm-group-header">
                                                                                                <div class="group-info">
                                                                                                    <svg width="20" height="20" stroke="currentColor" fill="none">
                                                                                                        <rect x="3" y="4" width="18" height="14" rx="2"/>
                                                                                                        <line x1="3" y1="10" x2="21" y2="10"/>
                                                                                                    </svg>
                                                                                                    <span class="group-title">Agendas</span>
                                                                                                    <span class="group-count" id="count-agendas">0/4</span>
                                                                                                </div>
                                                                                                <div>
                                                                                                    <input type="checkbox" class="select-all" data-group="agendas">
                                                                                                    <label>Seleccionar todo</label>
                                                                                                </div>
                                                                                            </div>

                                                                                            <div class="perm-items">
                                                                                                <label class="perm-item"><input type="checkbox" class="perm" data-group="agendas" value="11">Ver agenda</label>
                                                                                                <label class="perm-item"><input type="checkbox" class="perm" data-group="agendas" value="12">Crear evento</label>
                                                                                            </div>
                                                                                        </div>

                                                                                    </div>
                                                                                </div>


                                                                                <!-- Footer -->
                                                                                <div class="modal-footer-enhanced">
                                                                                    <button type="button"
                                                                                        class="btn-cancel"
                                                                                        onclick="cerrarModal()">
                                                                                        <span>Cancelar</span>
                                                                                    </button>
                                                                                    <button type="submit"
                                                                                        class="btn-submit">
                                                                                        <span>Guardar Usuario</span>
                                                                                    </button>
                                                                                </div>
                                                                            </form>
                                                                        </div>
                                                                    </div>
                                                                </div>

                                                                <script
                                                                    src="${pageContext.request.contextPath}/js/dni-api.js"></script>
                                                                <script
                                                                    src="${pageContext.request.contextPath}/js/usuarios.js"></script>

                                                            </body>

                                                            </html>