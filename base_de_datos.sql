-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 12-02-2026 a las 18:11:41
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `sistema_voluntariado`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_actividades_por_mes` ()   BEGIN
    SELECT 
        DATE_FORMAT(m.mes, '%Y-%m') AS mes,
        DATE_FORMAT(m.mes, '%b') AS nombre_mes,
        IFNULL(COUNT(a.id_actividad), 0) AS total_actividades
    FROM (
        SELECT DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL n MONTH), '%Y-%m-01') AS mes
        FROM (
            SELECT 0 AS n UNION SELECT 1 UNION SELECT 2 
            UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
        ) nums
    ) m
    LEFT JOIN actividades a 
        ON DATE_FORMAT(a.fecha_inicio, '%Y-%m') = DATE_FORMAT(m.mes, '%Y-%m')
    GROUP BY m.mes
    ORDER BY m.mes ASC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_actualizarDonacion` (IN `p_id_donacion` INT, IN `p_cantidad` DOUBLE, IN `p_descripcion` VARCHAR(150), IN `p_id_tipo_donacion` INT, IN `p_id_actividad` INT)   BEGIN
    UPDATE donacion
    SET cantidad = p_cantidad,
        descripcion = p_descripcion,
        id_tipo_donacion = p_id_tipo_donacion,
        id_actividad = p_id_actividad
    WHERE id_donacion = p_id_donacion;
    
    SELECT ROW_COUNT() AS filas_afectadas;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_actualizarMovimiento` (IN `p_id` INT, IN `p_tipo` VARCHAR(10), IN `p_monto` DECIMAL(12,2), IN `p_descripcion` VARCHAR(255), IN `p_categoria` VARCHAR(60), IN `p_comprobante` VARCHAR(100), IN `p_fecha` DATE, IN `p_id_actividad` INT)   BEGIN
    UPDATE movimiento_financiero
    SET tipo              = p_tipo,
        monto             = p_monto,
        descripcion       = p_descripcion,
        categoria         = p_categoria,
        comprobante       = p_comprobante,
        fecha_movimiento  = p_fecha,
        id_actividad      = NULLIF(p_id_actividad, 0)
    WHERE id_movimiento   = p_id;

    SELECT ROW_COUNT() AS filas_afectadas;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_actualizar_actividad` (IN `p_id` INT, IN `p_nombre` VARCHAR(200), IN `p_descripcion` TEXT, IN `p_fecha_inicio` DATE, IN `p_fecha_fin` DATE, IN `p_ubicacion` VARCHAR(300), IN `p_cupo_maximo` INT)   BEGIN
    UPDATE actividades
    SET nombre       = p_nombre,
        descripcion  = p_descripcion,
        fecha_inicio = p_fecha_inicio,
        fecha_fin    = p_fecha_fin,
        ubicacion    = p_ubicacion,
        cupo_maximo  = p_cupo_maximo
    WHERE id_actividad = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_actualizar_asistencia` (IN `p_id_asistencia` INT, IN `p_hora_entrada` TIME, IN `p_hora_salida` TIME, IN `p_estado` VARCHAR(20), IN `p_observaciones` TEXT)   BEGIN
    DECLARE v_horas DECIMAL(5,2) DEFAULT 0.00;

    IF p_hora_entrada IS NOT NULL AND p_hora_salida IS NOT NULL THEN
        SET v_horas = ROUND(TIMESTAMPDIFF(MINUTE, p_hora_entrada, p_hora_salida) / 60.0, 2);
        IF v_horas < 0 THEN
            SET v_horas = 0.00;
        END IF;
    END IF;

    UPDATE asistencias
    SET hora_entrada = p_hora_entrada,
        hora_salida  = p_hora_salida,
        horas_totales = v_horas,
        estado       = p_estado,
        observaciones = p_observaciones
    WHERE id_asistencia = p_id_asistencia;

    SELECT ROW_COUNT() AS filas_afectadas;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_actualizar_beneficiario` (IN `p_id_beneficiario` INT, IN `p_nombres` VARCHAR(100), IN `p_apellidos` VARCHAR(100), IN `p_dni` VARCHAR(20), IN `p_fecha_nacimiento` DATE, IN `p_telefono` VARCHAR(20), IN `p_direccion` VARCHAR(255), IN `p_distrito` VARCHAR(100), IN `p_tipo_beneficiario` VARCHAR(20), IN `p_necesidad_principal` VARCHAR(30), IN `p_observaciones` TEXT)   BEGIN
    UPDATE beneficiario
    SET nombres             = p_nombres,
        apellidos           = p_apellidos,
        dni                 = p_dni,
        fecha_nacimiento    = p_fecha_nacimiento,
        telefono            = p_telefono,
        direccion           = p_direccion,
        distrito            = p_distrito,
        tipo_beneficiario   = p_tipo_beneficiario,
        necesidad_principal = p_necesidad_principal,
        observaciones       = p_observaciones
    WHERE id_beneficiario   = p_id_beneficiario;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_actualizar_foto_perfil` (IN `p_id_usuario` INT, IN `p_foto_perfil` VARCHAR(255))   BEGIN
    UPDATE usuario
    SET foto_perfil = p_foto_perfil,
        actualizado_en = NOW()
    WHERE id_usuario = p_id_usuario;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_actualizar_usuario` (IN `p_id_usuario` INT, IN `p_nombres` VARCHAR(100), IN `p_apellidos` VARCHAR(100), IN `p_correo` VARCHAR(100), IN `p_username` VARCHAR(60), IN `p_dni` VARCHAR(20))   BEGIN
    UPDATE usuario
    SET nombres = p_nombres,
        apellidos = p_apellidos,
        correo = p_correo,
        username = p_username,
        dni = p_dni,
        actualizado_en = NOW()
    WHERE id_usuario = p_id_usuario;
    
    SELECT ROW_COUNT() AS filas_afectadas;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_actualizar_voluntario` (IN `p_id_voluntario` INT, IN `p_nombres` VARCHAR(100), IN `p_apellidos` VARCHAR(100), IN `p_dni` VARCHAR(20), IN `p_correo` VARCHAR(100), IN `p_telefono` VARCHAR(20), IN `p_carrera` VARCHAR(100))   BEGIN
    UPDATE voluntario
    SET nombres = p_nombres,
        apellidos = p_apellidos,
        dni = p_dni,
        correo = p_correo,
        telefono = p_telefono,
        carrera = p_carrera
    WHERE id_voluntario = p_id_voluntario;
    
    SELECT ROW_COUNT() AS filas_afectadas;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_anular_certificado` (IN `p_id_certificado` INT, IN `p_motivo_anulacion` TEXT)   BEGIN
    UPDATE certificados
    SET 
        estado = 'ANULADO',
        fecha_anulacion = CURDATE(),
        motivo_anulacion = p_motivo_anulacion
    WHERE id_certificado = p_id_certificado;
    
    SELECT ROW_COUNT() AS filas_afectadas;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_cambiar_estado_actividad` (IN `p_id` INT, IN `p_estado` VARCHAR(20))   BEGIN
    UPDATE actividades
    SET estado = p_estado
    WHERE id_actividad = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_cambiar_estado_beneficiario` (IN `p_id_beneficiario` INT, IN `p_estado` VARCHAR(10))   BEGIN
    UPDATE beneficiario
    SET estado = p_estado
    WHERE id_beneficiario = p_id_beneficiario;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_cambiar_estado_usuario` (IN `p_id_usuario` INT, IN `p_estado` VARCHAR(20))   BEGIN
    UPDATE usuario
    SET estado = p_estado,
        actualizado_en = NOW()
    WHERE id_usuario = p_id_usuario;
    
    SELECT ROW_COUNT() AS filas_afectadas;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_cambiar_estado_voluntario` (IN `p_id_voluntario` INT, IN `p_estado` VARCHAR(20))   BEGIN
    UPDATE voluntario
    SET estado = p_estado
    WHERE id_voluntario = p_id_voluntario;
    
    SELECT ROW_COUNT() AS filas_afectadas;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_certificados_por_voluntario` (IN `p_id_voluntario` INT)   BEGIN
    SELECT 
        c.id_certificado,
        c.codigo_certificado,
        c.id_voluntario,
        c.id_actividad,
        c.horas_voluntariado,
        c.fecha_emision,
        c.estado,
        c.observaciones,
        c.id_usuario_emite,
        CONCAT(v.nombres, ' ', v.apellidos) AS nombre_voluntario,
        v.dni AS dni_voluntario,
        a.nombre AS nombre_actividad,
        CONCAT(u.nombres, ' ', u.apellidos) AS usuario_emite
    FROM certificados c
    INNER JOIN voluntario v ON c.id_voluntario = v.id_voluntario
    INNER JOIN actividades a ON c.id_actividad = a.id_actividad
    INNER JOIN usuario u ON c.id_usuario_emite = u.id_usuario
    WHERE c.id_voluntario = p_id_voluntario
    ORDER BY c.fecha_emision DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_contar_notificaciones_no_leidas` (IN `p_id_usuario` INT)   BEGIN
    SELECT COUNT(*) AS total FROM notificaciones
    WHERE id_usuario = p_id_usuario AND leida = 0;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_crear_actividad` (IN `p_nombre` VARCHAR(200), IN `p_descripcion` TEXT, IN `p_fecha_inicio` DATE, IN `p_fecha_fin` DATE, IN `p_ubicacion` VARCHAR(300), IN `p_cupo_maximo` INT, IN `p_id_usuario` INT)   BEGIN
    INSERT INTO actividades (nombre, descripcion, fecha_inicio, fecha_fin, ubicacion, cupo_maximo, id_usuario)
    VALUES (p_nombre, p_descripcion, p_fecha_inicio, p_fecha_fin, p_ubicacion, p_cupo_maximo, p_id_usuario);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_crear_beneficiario` (IN `p_nombres` VARCHAR(100), IN `p_apellidos` VARCHAR(100), IN `p_dni` VARCHAR(20), IN `p_fecha_nacimiento` DATE, IN `p_telefono` VARCHAR(20), IN `p_direccion` VARCHAR(255), IN `p_distrito` VARCHAR(100), IN `p_tipo_beneficiario` VARCHAR(20), IN `p_necesidad_principal` VARCHAR(30), IN `p_observaciones` TEXT, IN `p_id_usuario` INT)   BEGIN
    INSERT INTO beneficiario (nombres, apellidos, dni, fecha_nacimiento, telefono,
                              direccion, distrito, tipo_beneficiario,
                              necesidad_principal, observaciones, id_usuario)
    VALUES (p_nombres, p_apellidos, p_dni, p_fecha_nacimiento, p_telefono,
            p_direccion, p_distrito, p_tipo_beneficiario,
            p_necesidad_principal, p_observaciones, p_id_usuario);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_crear_certificado` (IN `p_codigo_certificado` VARCHAR(50), IN `p_id_voluntario` INT, IN `p_id_actividad` INT, IN `p_horas_voluntariado` INT, IN `p_observaciones` TEXT, IN `p_id_usuario_emite` INT)   BEGIN
    -- Generar código automático si no se proporciona
    DECLARE v_codigo VARCHAR(50);
    DECLARE v_anio INT;
    DECLARE v_secuencia INT;
    
    IF p_codigo_certificado IS NULL OR p_codigo_certificado = '' THEN
        SET v_anio = YEAR(CURDATE());
        
        -- Obtener siguiente secuencia del año
        SELECT IFNULL(MAX(CAST(SUBSTRING_INDEX(codigo_certificado, '-', -1) AS UNSIGNED)), 0) + 1
        INTO v_secuencia
        FROM certificados
        WHERE codigo_certificado LIKE CONCAT('CERT-', v_anio, '-%');
        
        SET v_codigo = CONCAT('CERT-', v_anio, '-', LPAD(v_secuencia, 4, '0'));
    ELSE
        SET v_codigo = p_codigo_certificado;
    END IF;
    
    INSERT INTO certificados (
        codigo_certificado,
        id_voluntario,
        id_actividad,
        horas_voluntariado,
        fecha_emision,
        estado,
        observaciones,
        id_usuario_emite
    ) VALUES (
        v_codigo,
        p_id_voluntario,
        p_id_actividad,
        p_horas_voluntariado,
        CURDATE(),
        'EMITIDO',
        p_observaciones,
        p_id_usuario_emite
    );
    
    SELECT LAST_INSERT_ID() AS id_certificado, v_codigo AS codigo_certificado;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_crear_evento` (IN `p_titulo` VARCHAR(200), IN `p_descripcion` TEXT, IN `p_fecha_inicio` DATE, IN `p_fecha_fin` DATE, IN `p_color` VARCHAR(20), IN `p_id_usuario` INT)   BEGIN
    INSERT INTO eventos_calendario (titulo, descripcion, fecha_inicio, fecha_fin, color, id_usuario)
    VALUES (p_titulo, p_descripcion, p_fecha_inicio, p_fecha_fin, IFNULL(p_color, '#6366f1'), p_id_usuario);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_crear_notificacion` (IN `p_id_usuario` INT, IN `p_tipo` VARCHAR(30), IN `p_titulo` VARCHAR(200), IN `p_mensaje` TEXT, IN `p_icono` VARCHAR(50), IN `p_color` VARCHAR(20), IN `p_referencia_id` INT)   BEGIN
    INSERT INTO notificaciones (id_usuario, tipo, titulo, mensaje, icono, color, referencia_id)
    VALUES (p_id_usuario, p_tipo, p_titulo, p_mensaje, p_icono, p_color, p_referencia_id);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_crear_usuario` (IN `p_nombres` VARCHAR(100), IN `p_apellidos` VARCHAR(100), IN `p_correo` VARCHAR(100), IN `p_username` VARCHAR(60), IN `p_dni` VARCHAR(20), IN `p_password_hash` VARCHAR(255))   BEGIN
    INSERT INTO usuario (nombres, apellidos, correo, username, dni, password_hash, estado, creado_en)
    VALUES (p_nombres, p_apellidos, p_correo, p_username, p_dni, p_password_hash, 'ACTIVO', NOW());
    
    SELECT LAST_INSERT_ID() AS id_usuario;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_crear_voluntario` (IN `p_nombres` VARCHAR(100), IN `p_apellidos` VARCHAR(100), IN `p_dni` VARCHAR(20), IN `p_correo` VARCHAR(100), IN `p_telefono` VARCHAR(20), IN `p_carrera` VARCHAR(100), IN `p_id_usuario` INT)   BEGIN
    INSERT INTO voluntario (nombres, apellidos, dni, correo, telefono, carrera, estado, id_usuario)
    VALUES (p_nombres, p_apellidos, p_dni, p_correo, p_telefono, p_carrera, 'ACTIVO', 
            IF(p_id_usuario > 0, p_id_usuario, NULL));
    
    SELECT LAST_INSERT_ID() AS id_voluntario;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_eliminarDonacion` (IN `p_id_donacion` INT)   BEGIN
    DELETE FROM donacion WHERE id_donacion = p_id_donacion;
    SELECT ROW_COUNT() AS filas_afectadas;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_eliminarMovimiento` (IN `p_id` INT)   BEGIN
    DELETE FROM movimiento_financiero WHERE id_movimiento = p_id;
    SELECT ROW_COUNT() AS filas_afectadas;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_eliminar_actividad` (IN `p_id` INT)   BEGIN
    DELETE FROM actividades WHERE id_actividad = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_eliminar_asistencia` (IN `p_id_asistencia` INT)   BEGIN
    DELETE FROM asistencias WHERE id_asistencia = p_id_asistencia;
    SELECT ROW_COUNT() AS filas_afectadas;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_eliminar_beneficiario` (IN `p_id_beneficiario` INT)   BEGIN
    DELETE FROM beneficiario WHERE id_beneficiario = p_id_beneficiario;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_eliminar_evento` (IN `p_id_evento` INT)   BEGIN
    DELETE FROM eventos_calendario WHERE id_evento = p_id_evento;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_eliminar_usuario` (IN `p_id_usuario` INT)   BEGIN
    DELETE FROM usuario WHERE id_usuario = p_id_usuario;
    SELECT ROW_COUNT() AS filas_afectadas;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_eliminar_voluntario` (IN `p_id_voluntario` INT)   BEGIN
    DELETE FROM voluntario WHERE id_voluntario = p_id_voluntario;
    SELECT ROW_COUNT() AS filas_afectadas;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_estadisticas_asistencias` ()   BEGIN
    SELECT
        COUNT(*) AS total_registros,
        SUM(CASE WHEN estado = 'ASISTIO' THEN 1 ELSE 0 END) AS total_asistieron,
        SUM(CASE WHEN estado = 'FALTA' THEN 1 ELSE 0 END) AS total_faltas,
        SUM(CASE WHEN estado = 'TARDANZA' THEN 1 ELSE 0 END) AS total_tardanzas,
        IFNULL(SUM(horas_totales), 0) AS total_horas,
        COUNT(DISTINCT id_voluntario) AS voluntarios_unicos,
        COUNT(DISTINCT id_actividad) AS actividades_registradas
    FROM asistencias;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_estadisticas_certificados` ()   BEGIN
    SELECT 
        COUNT(*) AS total_certificados,
        SUM(CASE WHEN estado = 'EMITIDO' THEN 1 ELSE 0 END) AS total_emitidos,
        SUM(CASE WHEN estado = 'ANULADO' THEN 1 ELSE 0 END) AS total_anulados,
        SUM(CASE WHEN estado = 'EMITIDO' THEN horas_voluntariado ELSE 0 END) AS total_horas_certificadas,
        COUNT(DISTINCT id_voluntario) AS voluntarios_certificados,
        COUNT(DISTINCT id_actividad) AS actividades_certificadas
    FROM certificados;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_filtrarMovimientos` (IN `p_tipo` VARCHAR(10), IN `p_categoria` VARCHAR(60), IN `p_fecha_ini` DATE, IN `p_fecha_fin` DATE)   BEGIN
    SELECT m.id_movimiento, m.tipo, m.monto, m.descripcion,
           m.categoria, m.comprobante, m.fecha_movimiento,
           IFNULL(a.nombre, '???') AS actividad,
           m.id_actividad,
           CONCAT(u.nombres, ' ', u.apellidos) AS usuario_registro,
           m.creado_en
    FROM movimiento_financiero m
    INNER JOIN usuario u ON m.id_usuario = u.id_usuario
    LEFT JOIN actividades a ON m.id_actividad = a.id_actividad
    WHERE (p_tipo IS NULL      OR p_tipo = ''      OR m.tipo = p_tipo)
      AND (p_categoria IS NULL OR p_categoria = '' OR m.categoria = p_categoria)
      AND (p_fecha_ini IS NULL OR m.fecha_movimiento >= p_fecha_ini)
      AND (p_fecha_fin IS NULL OR m.fecha_movimiento <= p_fecha_fin)
    ORDER BY m.fecha_movimiento DESC, m.creado_en DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_generar_notificaciones_actividades_hoy` (IN `p_id_usuario` INT)   BEGIN
    -- Insertar notificación por cada actividad que inicia hoy
    -- Solo si no existe ya una notificación del mismo tipo y referencia hoy
    INSERT INTO notificaciones (id_usuario, tipo, titulo, mensaje, icono, color, referencia_id)
    SELECT p_id_usuario, 'ACTIVIDAD_HOY',
           CONCAT('📋 Actividad hoy: ', a.nombre),
           CONCAT('La actividad "', a.nombre, '" está programada para hoy en ', IFNULL(a.ubicacion, 'ubicación por definir'), '.'),
           'fa-calendar-check', '#10b981', a.id_actividad
    FROM actividades a
    WHERE DATE(a.fecha_inicio) = CURDATE()
      AND a.estado = 'ACTIVO'
      AND NOT EXISTS (
          SELECT 1 FROM notificaciones n
          WHERE n.id_usuario = p_id_usuario
            AND n.tipo = 'ACTIVIDAD_HOY'
            AND n.referencia_id = a.id_actividad
            AND DATE(n.fecha_creacion) = CURDATE()
      );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_generar_notificaciones_eventos_hoy` (IN `p_id_usuario` INT)   BEGIN
    INSERT INTO notificaciones (id_usuario, titulo, mensaje, tipo, leida, creada_en)
    SELECT 
        p_id_usuario,
        CONCAT('📅 Evento hoy: ', e.titulo),
        CONCAT('Tienes programado "', e.titulo, '" para hoy'),
        'EVENTO',
        0,
        NOW()
    FROM eventos_calendario e
    WHERE e.fecha_inicio = CURDATE()
      AND e.id_usuario = p_id_usuario
      AND NOT EXISTS (
          SELECT 1 FROM notificaciones n
          WHERE n.id_usuario = p_id_usuario
            AND n.tipo = 'EVENTO'
            AND n.titulo = CONCAT('📅 Evento hoy: ', e.titulo)
            AND DATE(n.creada_en) = CURDATE()
      );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_guardarDonacion` (IN `p_cantidad` DOUBLE, IN `p_descripcion` VARCHAR(150), IN `p_id_tipo_donacion` INT, IN `p_id_actividad` INT, IN `p_id_usuario_registro` INT)   BEGIN
    INSERT INTO donacion (cantidad, descripcion, id_tipo_donacion, id_actividad, id_usuario_registro, registrado_en)
    VALUES (p_cantidad, p_descripcion, p_id_tipo_donacion, p_id_actividad, p_id_usuario_registro, NOW());
    
    SELECT LAST_INSERT_ID() AS id_donacion;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_horas_voluntarias_por_actividad` ()   BEGIN
    SELECT 
        act.nombre AS nombre_actividad,
        IFNULL(SUM(a.horas_totales), 0) AS total_horas
    FROM asistencias a
    INNER JOIN actividades act ON a.id_actividad = act.id_actividad
    WHERE a.estado IN ('ASISTIO', 'TARDANZA')
    GROUP BY act.id_actividad, act.nombre
    ORDER BY total_horas DESC
    LIMIT 5;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_limpiar_notificaciones_antiguas` ()   BEGIN
    DELETE FROM notificaciones WHERE fecha_creacion < DATE_SUB(NOW(), INTERVAL 30 DAY);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_listarDonaciones` ()   BEGIN
    SELECT 
        d.id_donacion,
        d.cantidad,
        d.descripcion,
        td.nombre AS tipoDonacion,
        a.nombre AS actividad,
        CONCAT(u.nombres, ' ', u.apellidos) AS usuarioRegistro,
        d.registrado_en,
        d.id_tipo_donacion,
        d.id_actividad
    FROM donacion d
    LEFT JOIN tipo_donacion td ON d.id_tipo_donacion = td.id_tipo_donacion
    LEFT JOIN actividades a ON d.id_actividad = a.id_actividad
    LEFT JOIN usuario u ON d.id_usuario_registro = u.id_usuario
    ORDER BY d.registrado_en DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_listarMovimientos` ()   BEGIN
    SELECT m.id_movimiento, m.tipo, m.monto, m.descripcion,
           m.categoria, m.comprobante, m.fecha_movimiento,
           IFNULL(a.nombre, '???') AS actividad,
           m.id_actividad,
           CONCAT(u.nombres, ' ', u.apellidos) AS usuario_registro,
           m.creado_en
    FROM movimiento_financiero m
    INNER JOIN usuario u ON m.id_usuario = u.id_usuario
    LEFT JOIN actividades a ON m.id_actividad = a.id_actividad
    ORDER BY m.fecha_movimiento DESC, m.creado_en DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_listar_asistencias` ()   BEGIN
    SELECT
        a.id_asistencia,
        a.id_voluntario,
        CONCAT(v.nombres, ' ', v.apellidos) AS nombre_voluntario,
        v.dni AS dni_voluntario,
        a.id_actividad,
        act.nombre AS nombre_actividad,
        a.fecha,
        a.hora_entrada,
        a.hora_salida,
        a.horas_totales,
        a.estado,
        a.observaciones,
        a.id_usuario_registro,
        CONCAT(u.nombres, ' ', u.apellidos) AS usuario_registro,
        a.creado_en
    FROM asistencias a
    INNER JOIN voluntario v   ON a.id_voluntario = v.id_voluntario
    INNER JOIN actividades act ON a.id_actividad  = act.id_actividad
    LEFT JOIN usuario u       ON a.id_usuario_registro = u.id_usuario
    ORDER BY a.fecha DESC, a.creado_en DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_listar_asistencias_por_actividad` (IN `p_id_actividad` INT)   BEGIN
    SELECT
        a.id_asistencia,
        a.id_voluntario,
        CONCAT(v.nombres, ' ', v.apellidos) AS nombre_voluntario,
        v.dni AS dni_voluntario,
        a.id_actividad,
        act.nombre AS nombre_actividad,
        a.fecha,
        a.hora_entrada,
        a.hora_salida,
        a.horas_totales,
        a.estado,
        a.observaciones,
        a.creado_en
    FROM asistencias a
    INNER JOIN voluntario v   ON a.id_voluntario = v.id_voluntario
    INNER JOIN actividades act ON a.id_actividad  = act.id_actividad
    WHERE a.id_actividad = p_id_actividad
    ORDER BY a.fecha DESC, v.apellidos, v.nombres;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_listar_asistencias_por_voluntario` (IN `p_id_voluntario` INT)   BEGIN
    SELECT
        a.id_asistencia,
        a.id_voluntario,
        CONCAT(v.nombres, ' ', v.apellidos) AS nombre_voluntario,
        a.id_actividad,
        act.nombre AS nombre_actividad,
        a.fecha,
        a.hora_entrada,
        a.hora_salida,
        a.horas_totales,
        a.estado,
        a.observaciones,
        a.creado_en
    FROM asistencias a
    INNER JOIN voluntario v   ON a.id_voluntario = v.id_voluntario
    INNER JOIN actividades act ON a.id_actividad  = act.id_actividad
    WHERE a.id_voluntario = p_id_voluntario
    ORDER BY a.fecha DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_listar_certificados` ()   BEGIN
    SELECT 
        c.id_certificado,
        c.codigo_certificado,
        c.id_voluntario,
        c.id_actividad,
        c.horas_voluntariado,
        c.fecha_emision,
        c.estado,
        c.observaciones,
        c.id_usuario_emite,
        CONCAT(v.nombres, ' ', v.apellidos) AS nombre_voluntario,
        v.dni AS dni_voluntario,
        a.nombre AS nombre_actividad,
        CONCAT(u.nombres, ' ', u.apellidos) AS usuario_emite
    FROM certificados c
    INNER JOIN voluntario v ON c.id_voluntario = v.id_voluntario
    INNER JOIN actividades a ON c.id_actividad = a.id_actividad
    INNER JOIN usuario u ON c.id_usuario_emite = u.id_usuario
    ORDER BY c.fecha_emision DESC, c.id_certificado DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_listar_eventos` ()   BEGIN
    SELECT id_evento, titulo, descripcion, fecha_inicio, fecha_fin, color, id_usuario, creado_en
    FROM eventos_calendario
    ORDER BY fecha_inicio DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_listar_notificaciones` (IN `p_id_usuario` INT)   BEGIN
    SELECT id_notificacion, id_usuario, tipo, titulo, mensaje, icono, color,
           leida, referencia_id, fecha_creacion
    FROM notificaciones
    WHERE id_usuario = p_id_usuario
    ORDER BY fecha_creacion DESC
    LIMIT 20;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_marcar_notificacion_leida` (IN `p_id_notificacion` INT)   BEGIN
    UPDATE notificaciones SET leida = 1 WHERE id_notificacion = p_id_notificacion;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_marcar_todas_leidas` (IN `p_id_usuario` INT)   BEGIN
    UPDATE notificaciones SET leida = 1 WHERE id_usuario = p_id_usuario;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_obtenerBalance` ()   BEGIN
    SELECT
        IFNULL(SUM(CASE WHEN tipo = 'INGRESO' THEN monto ELSE 0 END), 0) AS total_ingresos,
        IFNULL(SUM(CASE WHEN tipo = 'GASTO'   THEN monto ELSE 0 END), 0) AS total_gastos,
        IFNULL(SUM(CASE WHEN tipo = 'INGRESO' THEN monto ELSE -monto END), 0) AS saldo
    FROM movimiento_financiero;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_obtenerDonacionPorId` (IN `p_id_donacion` INT)   BEGIN
    SELECT 
        d.id_donacion,
        d.cantidad,
        d.descripcion,
        td.nombre AS tipoDonacion,
        a.nombre AS actividad,
        CONCAT(u.nombres, ' ', u.apellidos) AS usuarioRegistro,
        d.registrado_en,
        d.id_tipo_donacion,
        d.id_actividad
    FROM donacion d
    LEFT JOIN tipo_donacion td ON d.id_tipo_donacion = td.id_tipo_donacion
    LEFT JOIN actividades a ON d.id_actividad = a.id_actividad
    LEFT JOIN usuario u ON d.id_usuario_registro = u.id_usuario
    WHERE d.id_donacion = p_id_donacion;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_obtenerMovimiento` (IN `p_id` INT)   BEGIN
    SELECT m.id_movimiento, m.tipo, m.monto, m.descripcion,
           m.categoria, m.comprobante, m.fecha_movimiento,
           m.id_actividad, m.id_usuario, m.creado_en
    FROM movimiento_financiero m
    WHERE m.id_movimiento = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_obtener_actividad_por_id` (IN `p_id` INT)   BEGIN
    SELECT id_actividad, nombre, descripcion, fecha_inicio, fecha_fin,
           ubicacion, cupo_maximo, inscritos, estado, id_usuario, creado_en
    FROM actividades
    WHERE id_actividad = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_obtener_asistencia_por_id` (IN `p_id_asistencia` INT)   BEGIN
    SELECT
        a.id_asistencia,
        a.id_voluntario,
        CONCAT(v.nombres, ' ', v.apellidos) AS nombre_voluntario,
        v.dni AS dni_voluntario,
        a.id_actividad,
        act.nombre AS nombre_actividad,
        a.fecha,
        a.hora_entrada,
        a.hora_salida,
        a.horas_totales,
        a.estado,
        a.observaciones,
        a.id_usuario_registro,
        CONCAT(u.nombres, ' ', u.apellidos) AS usuario_registro,
        a.creado_en
    FROM asistencias a
    INNER JOIN voluntario v   ON a.id_voluntario = v.id_voluntario
    INNER JOIN actividades act ON a.id_actividad  = act.id_actividad
    LEFT JOIN usuario u       ON a.id_usuario_registro = u.id_usuario
    WHERE a.id_asistencia = p_id_asistencia;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_obtener_beneficiario_por_id` (IN `p_id_beneficiario` INT)   BEGIN
    SELECT * FROM beneficiario WHERE id_beneficiario = p_id_beneficiario;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_obtener_certificado_por_codigo` (IN `p_codigo_certificado` VARCHAR(50))   BEGIN
    SELECT 
        c.id_certificado,
        c.codigo_certificado,
        c.id_voluntario,
        c.id_actividad,
        c.horas_voluntariado,
        c.fecha_emision,
        c.estado,
        c.observaciones,
        c.id_usuario_emite,
        CONCAT(v.nombres, ' ', v.apellidos) AS nombre_voluntario,
        v.dni AS dni_voluntario,
        a.nombre AS nombre_actividad,
        CONCAT(u.nombres, ' ', u.apellidos) AS usuario_emite
    FROM certificados c
    INNER JOIN voluntario v ON c.id_voluntario = v.id_voluntario
    INNER JOIN actividades a ON c.id_actividad = a.id_actividad
    INNER JOIN usuario u ON c.id_usuario_emite = u.id_usuario
    WHERE c.codigo_certificado = p_codigo_certificado;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_obtener_certificado_por_id` (IN `p_id_certificado` INT)   BEGIN
    SELECT 
        c.id_certificado,
        c.codigo_certificado,
        c.id_voluntario,
        c.id_actividad,
        c.horas_voluntariado,
        c.fecha_emision,
        c.estado,
        c.observaciones,
        c.id_usuario_emite,
        CONCAT(v.nombres, ' ', v.apellidos) AS nombre_voluntario,
        v.dni AS dni_voluntario,
        a.nombre AS nombre_actividad,
        CONCAT(u.nombres, ' ', u.apellidos) AS usuario_emite
    FROM certificados c
    INNER JOIN voluntario v ON c.id_voluntario = v.id_voluntario
    INNER JOIN actividades a ON c.id_actividad = a.id_actividad
    INNER JOIN usuario u ON c.id_usuario_emite = u.id_usuario
    WHERE c.id_certificado = p_id_certificado;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_obtener_intentos_restantes` (IN `p_username` VARCHAR(60), IN `p_max_intentos` INT)   BEGIN
    SELECT (p_max_intentos - COALESCE(intentos_fallidos, 0)) AS intentos_restantes
    FROM usuario
    WHERE username = p_username;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_obtener_todas_actividades` ()   BEGIN
    SELECT id_actividad, nombre, descripcion, fecha_inicio, fecha_fin,
           ubicacion, cupo_maximo, inscritos, estado, id_usuario, creado_en
    FROM actividades
    ORDER BY creado_en DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_obtener_todos_beneficiarios` ()   BEGIN
    SELECT * FROM beneficiario ORDER BY creado_en DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_obtener_todos_usuarios` ()   BEGIN
    SELECT id_usuario, nombres, apellidos, correo, username, dni, estado, creado_en, actualizado_en 
    FROM usuario 
    ORDER BY id_usuario DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_obtener_todos_voluntarios` ()   BEGIN
    SELECT id_voluntario, nombres, apellidos, dni, correo, telefono, carrera, estado, id_usuario
    FROM voluntario
    ORDER BY id_voluntario DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_obtener_usuario_por_id` (IN `p_id_usuario` INT)   BEGIN
    SELECT id_usuario, nombres, apellidos, correo, username, dni, estado, creado_en, actualizado_en 
    FROM usuario 
    WHERE id_usuario = p_id_usuario;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_obtener_usuario_por_username` (IN `p_username` VARCHAR(60))   BEGIN
    SELECT id_usuario, nombres, apellidos, correo, username, dni,
           password_hash, foto_perfil, estado, creado_en, actualizado_en
    FROM usuario
    WHERE username = p_username;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_obtener_voluntario_por_id` (IN `p_id_voluntario` INT)   BEGIN
    SELECT id_voluntario, nombres, apellidos, dni, correo, telefono, carrera, estado, id_usuario
    FROM voluntario
    WHERE id_voluntario = p_id_voluntario
    LIMIT 1;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_proxima_actividad` ()   BEGIN
    SELECT 
        id_actividad,
        nombre,
        fecha_inicio,
        ubicacion
    FROM actividades
    WHERE fecha_inicio >= CURDATE()
      AND estado = 'ACTIVO'
    ORDER BY fecha_inicio ASC
    LIMIT 1;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_registrarMovimiento` (IN `p_tipo` VARCHAR(10), IN `p_monto` DECIMAL(12,2), IN `p_descripcion` VARCHAR(255), IN `p_categoria` VARCHAR(60), IN `p_comprobante` VARCHAR(100), IN `p_fecha` DATE, IN `p_id_actividad` INT, IN `p_id_usuario` INT)   BEGIN
    INSERT INTO movimiento_financiero
        (tipo, monto, descripcion, categoria, comprobante,
         fecha_movimiento, id_actividad, id_usuario)
    VALUES
        (p_tipo, p_monto, p_descripcion, p_categoria, p_comprobante,
         p_fecha, NULLIF(p_id_actividad, 0), p_id_usuario);

    SELECT LAST_INSERT_ID() AS id_movimiento;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_registrar_asistencia` (IN `p_id_voluntario` INT, IN `p_id_actividad` INT, IN `p_fecha` DATE, IN `p_hora_entrada` TIME, IN `p_hora_salida` TIME, IN `p_estado` VARCHAR(20), IN `p_observaciones` TEXT, IN `p_id_usuario_registro` INT)   BEGIN
    DECLARE v_horas DECIMAL(5,2) DEFAULT 0.00;

    -- Calcular horas totales si ambas horas están presentes
    IF p_hora_entrada IS NOT NULL AND p_hora_salida IS NOT NULL THEN
        SET v_horas = ROUND(TIMESTAMPDIFF(MINUTE, p_hora_entrada, p_hora_salida) / 60.0, 2);
        IF v_horas < 0 THEN
            SET v_horas = 0.00;
        END IF;
    END IF;

    INSERT INTO asistencias (
        id_voluntario, id_actividad, fecha,
        hora_entrada, hora_salida, horas_totales,
        estado, observaciones, id_usuario_registro
    ) VALUES (
        p_id_voluntario, p_id_actividad, p_fecha,
        p_hora_entrada, p_hora_salida, v_horas,
        p_estado, p_observaciones, p_id_usuario_registro
    );

    SELECT LAST_INSERT_ID() AS id_asistencia;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_registrar_intento_fallido` (IN `p_username` VARCHAR(60), IN `p_max_intentos` INT, IN `p_tiempo_bloqueo_minutos` INT)   BEGIN
    -- Incrementar intentos fallidos
    UPDATE usuario
    SET intentos_fallidos = intentos_fallidos + 1
    WHERE username = p_username;

    -- Si alcanzó el máximo, bloquear la cuenta
    UPDATE usuario
    SET bloqueado_hasta = DATE_ADD(NOW(), INTERVAL p_tiempo_bloqueo_minutos MINUTE)
    WHERE username = p_username
      AND intentos_fallidos >= p_max_intentos;

    -- Retornar intentos actuales
    SELECT intentos_fallidos
    FROM usuario
    WHERE username = p_username;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_resetear_intentos_fallidos` (IN `p_username` VARCHAR(60))   BEGIN
    UPDATE usuario
    SET intentos_fallidos = 0,
        bloqueado_hasta = NULL
    WHERE username = p_username;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_resumenMensual` ()   BEGIN
    SELECT
        DATE_FORMAT(fecha_movimiento, '%Y-%m') AS mes,
        SUM(CASE WHEN tipo = 'INGRESO' THEN monto ELSE 0 END) AS ingresos,
        SUM(CASE WHEN tipo = 'GASTO'   THEN monto ELSE 0 END) AS gastos
    FROM movimiento_financiero
    GROUP BY DATE_FORMAT(fecha_movimiento, '%Y-%m')
    ORDER BY mes DESC
    LIMIT 12;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_resumenPorCategoria` ()   BEGIN
    SELECT categoria, tipo,
           SUM(monto) AS total,
           COUNT(*)   AS cantidad
    FROM movimiento_financiero
    GROUP BY categoria, tipo
    ORDER BY total DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_total_horas_voluntarias` ()   BEGIN
    SELECT IFNULL(SUM(horas_totales), 0) AS total_horas
    FROM asistencias
    WHERE estado IN ('ASISTIO', 'TARDANZA');
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_verificar_bloqueo` (IN `p_username` VARCHAR(60))   BEGIN
    SELECT intentos_fallidos, bloqueado_hasta
    FROM usuario
    WHERE username = p_username;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `actividad`
--

CREATE TABLE `actividad` (
  `id_actividad` int(11) NOT NULL,
  `nombre_actividad` varchar(150) DEFAULT NULL,
  `descripcion` varchar(200) DEFAULT NULL,
  `fecha` date DEFAULT NULL,
  `estado` varchar(30) DEFAULT NULL,
  `id_beneficiario` int(11) DEFAULT NULL,
  `id_usuario_creador` int(11) DEFAULT NULL,
  `creado_en` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `actividades`
--

CREATE TABLE `actividades` (
  `id_actividad` int(11) NOT NULL,
  `nombre` varchar(200) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `fecha_inicio` date NOT NULL,
  `fecha_fin` date DEFAULT NULL,
  `ubicacion` varchar(300) NOT NULL,
  `cupo_maximo` int(11) NOT NULL DEFAULT 30,
  `inscritos` int(11) NOT NULL DEFAULT 0,
  `estado` enum('ACTIVO','FINALIZADO','CANCELADO') NOT NULL DEFAULT 'ACTIVO',
  `id_usuario` int(11) DEFAULT NULL COMMENT 'Quién creó la actividad',
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `actividades`
--

INSERT INTO `actividades` (`id_actividad`, `nombre`, `descripcion`, `fecha_inicio`, `fecha_fin`, `ubicacion`, `cupo_maximo`, `inscritos`, `estado`, `id_usuario`, `creado_en`) VALUES
(1, 'Campaña de Limpieza del Río', 'Limpieza del río Rímac con voluntarios de la comunidad', '2026-02-15', '2026-02-15', 'Riberas del Río Rímac, Lima', 50, 32, 'FINALIZADO', NULL, '2026-02-08 03:49:32'),
(2, 'Taller de Primeros Auxilios', 'Capacitación básica en primeros auxilios para voluntarios nuevos', '2026-02-20', '2026-02-21', 'Centro Comunitario San Martín', 40, 28, 'ACTIVO', NULL, '2026-02-08 03:49:32'),
(3, 'Entrega de Alimentos', 'Distribución de alimentos a familias vulnerables del distrito', '2026-01-10', '2026-01-10', 'Parque Central, Chiclayo', 40, 40, 'FINALIZADO', NULL, '2026-02-08 03:49:32'),
(4, 'Reforestación Urbana', 'Plantación de árboles en parques del distrito', '2026-03-01', '2026-03-02', 'Parque Zonal Huiracocha, SJL', 60, 15, 'ACTIVO', NULL, '2026-02-08 03:49:32'),
(5, 'Campaña de Salud Gratuita', 'Chequeos médicos gratuitos para adultos mayores', '2026-02-28', '2026-03-01', 'Posta Médica La Victoria', 25, 0, 'ACTIVO', NULL, '2026-02-08 03:49:32'),
(6, 'Campaña de Limpieza del Río', 'Limpieza del río Rímac con voluntarios de la comunidad', '2026-02-15', '2026-02-15', 'Riberas del Río Rímac, Lima', 50, 32, 'FINALIZADO', NULL, '2026-02-08 04:15:59'),
(7, 'Taller de Primeros Auxilios', 'Capacitación básica en primeros auxilios para voluntarios nuevos', '2026-02-20', '2026-02-21', 'Centro Comunitario San Martín', 30, 28, 'ACTIVO', NULL, '2026-02-08 04:15:59'),
(8, 'Entrega de Alimentos', 'Distribución de alimentos a familias vulnerables del distrito', '2026-01-10', '2026-01-10', 'Parque Central, Comas', 40, 40, 'FINALIZADO', NULL, '2026-02-08 04:15:59'),
(9, 'Reforestación Urbana', 'Plantación de árboles en parques del distrito', '2026-03-01', '2026-03-02', 'Parque Zonal Huiracocha, SJL', 60, 15, 'ACTIVO', NULL, '2026-02-08 04:15:59'),
(10, 'Campaña de Salud Gratuita', 'Chequeos médicos gratuitos para adultos mayores', '2026-02-28', NULL, 'Posta Médica La Victoria', 25, 0, 'ACTIVO', NULL, '2026-02-08 04:15:59'),
(11, 'campaña de donacion de sangre', 'campaña de donacion de sangre', '2026-02-11', '2026-02-12', 'uss', 50, 0, 'ACTIVO', 21, '2026-02-11 21:07:39');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `actividad_lugar`
--

CREATE TABLE `actividad_lugar` (
  `id_actividad_lugar` int(11) NOT NULL,
  `id_actividad` int(11) DEFAULT NULL,
  `id_lugar` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `actividad_recurso`
--

CREATE TABLE `actividad_recurso` (
  `id_actividad_recurso` int(11) NOT NULL,
  `id_actividad` int(11) DEFAULT NULL,
  `id_recurso` int(11) DEFAULT NULL,
  `cantidad_requerida` decimal(10,2) DEFAULT NULL,
  `cantidad_conseguida` decimal(10,2) DEFAULT NULL,
  `prioridad` varchar(20) DEFAULT NULL,
  `observacion` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `asistencias`
--

CREATE TABLE `asistencias` (
  `id_asistencia` int(11) NOT NULL,
  `id_voluntario` int(11) NOT NULL,
  `id_actividad` int(11) NOT NULL,
  `fecha` date NOT NULL,
  `hora_entrada` time DEFAULT NULL,
  `hora_salida` time DEFAULT NULL,
  `horas_totales` decimal(5,2) DEFAULT 0.00,
  `estado` enum('ASISTIO','FALTA','TARDANZA') NOT NULL DEFAULT 'FALTA',
  `observaciones` text DEFAULT NULL,
  `id_usuario_registro` int(11) DEFAULT NULL COMMENT 'Usuario que registró la asistencia',
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `asistencias`
--

INSERT INTO `asistencias` (`id_asistencia`, `id_voluntario`, `id_actividad`, `fecha`, `hora_entrada`, `hora_salida`, `horas_totales`, `estado`, `observaciones`, `id_usuario_registro`, `creado_en`, `actualizado_en`) VALUES
(1, 14, 11, '2026-02-12', '07:00:00', '17:00:00', 10.00, 'ASISTIO', NULL, 21, '2026-02-12 03:20:15', '2026-02-12 03:20:15');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `beneficiario`
--

CREATE TABLE `beneficiario` (
  `id_beneficiario` int(11) NOT NULL,
  `nombre` varchar(150) DEFAULT NULL,
  `descripcion` varchar(200) DEFAULT NULL,
  `estado` varchar(30) DEFAULT NULL,
  `id_tipo_beneficiario` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `certificados`
--

CREATE TABLE `certificados` (
  `id_certificado` int(11) NOT NULL,
  `codigo_certificado` varchar(50) NOT NULL,
  `id_voluntario` int(11) NOT NULL,
  `id_actividad` int(11) NOT NULL,
  `horas_voluntariado` int(11) NOT NULL,
  `fecha_emision` date NOT NULL,
  `estado` enum('EMITIDO','ANULADO') DEFAULT 'EMITIDO',
  `observaciones` text DEFAULT NULL,
  `id_usuario_emite` int(11) NOT NULL,
  `fecha_anulacion` date DEFAULT NULL,
  `motivo_anulacion` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `certificados`
--

INSERT INTO `certificados` (`id_certificado`, `codigo_certificado`, `id_voluntario`, `id_actividad`, `horas_voluntariado`, `fecha_emision`, `estado`, `observaciones`, `id_usuario_emite`, `fecha_anulacion`, `motivo_anulacion`, `created_at`, `updated_at`) VALUES
(1, 'CERT-2026-0001', 14, 6, 10, '2026-02-11', 'EMITIDO', 'campaña de limpieza', 21, NULL, NULL, '2026-02-11 20:41:43', '2026-02-11 20:41:43'),
(2, 'CERT-2026-0002', 13, 6, 10, '2026-02-12', 'EMITIDO', '', 21, NULL, NULL, '2026-02-12 13:40:15', '2026-02-12 13:40:15'),
(3, 'CERT-2026-0003', 15, 8, 15, '2026-02-12', 'EMITIDO', 'entrega de alimentos', 24, NULL, NULL, '2026-02-12 15:52:55', '2026-02-12 15:52:55');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `donacion`
--

CREATE TABLE `donacion` (
  `id_donacion` int(11) NOT NULL,
  `cantidad` int(11) DEFAULT NULL,
  `descripcion` varchar(150) DEFAULT NULL,
  `id_tipo_donacion` int(11) DEFAULT NULL,
  `id_actividad` int(11) DEFAULT NULL,
  `id_usuario_registro` int(11) DEFAULT NULL,
  `registrado_en` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `donacion`
--

INSERT INTO `donacion` (`id_donacion`, `cantidad`, `descripcion`, `id_tipo_donacion`, `id_actividad`, `id_usuario_registro`, `registrado_en`) VALUES
(1, 250, 'se dono 250 a la limpieza del rio', 1, 6, 21, '2026-02-11 15:09:55');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `donacion_donante`
--

CREATE TABLE `donacion_donante` (
  `id_donacion_donante` int(11) NOT NULL,
  `id_donacion` int(11) DEFAULT NULL,
  `id_donante` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `donante`
--

CREATE TABLE `donante` (
  `id_donante` int(11) NOT NULL,
  `tipo` enum('Persona','Empresa','Grupo') DEFAULT NULL,
  `nombre` varchar(150) DEFAULT NULL,
  `correo` varchar(100) DEFAULT NULL,
  `telefono` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `eventos_calendario`
--

CREATE TABLE `eventos_calendario` (
  `id_evento` int(11) NOT NULL,
  `titulo` varchar(200) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `fecha_inicio` date NOT NULL,
  `fecha_fin` date DEFAULT NULL,
  `color` varchar(20) DEFAULT '#6366f1',
  `id_usuario` int(11) DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `eventos_calendario`
--

INSERT INTO `eventos_calendario` (`id_evento`, `titulo`, `descripcion`, `fecha_inicio`, `fecha_fin`, `color`, `id_usuario`, `creado_en`) VALUES
(1, 'cumpleños', 'de luis', '2026-02-12', '2026-02-12', '#eab308', 21, '2026-02-12 03:21:53');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `lugar`
--

CREATE TABLE `lugar` (
  `id_lugar` int(11) NOT NULL,
  `departamento` varchar(100) DEFAULT NULL,
  `provincia` varchar(100) DEFAULT NULL,
  `distrito` varchar(100) DEFAULT NULL,
  `direccion_referencia` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `movimiento_financiero`
--

CREATE TABLE `movimiento_financiero` (
  `id_movimiento` int(11) NOT NULL,
  `tipo` enum('INGRESO','GASTO') NOT NULL,
  `monto` decimal(12,2) NOT NULL,
  `descripcion` varchar(255) NOT NULL,
  `categoria` varchar(60) NOT NULL,
  `comprobante` varchar(100) DEFAULT NULL,
  `fecha_movimiento` date NOT NULL,
  `id_actividad` int(11) DEFAULT NULL,
  `id_usuario` int(11) NOT NULL,
  `creado_en` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `movimiento_financiero`
--

INSERT INTO `movimiento_financiero` (`id_movimiento`, `tipo`, `monto`, `descripcion`, `categoria`, `comprobante`, `fecha_movimiento`, `id_actividad`, `id_usuario`, `creado_en`) VALUES
(1, 'GASTO', 200.00, 'pasajes', 'Transporte', '002', '2026-02-12', 11, 21, '2026-02-12 09:58:55');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `notificaciones`
--

CREATE TABLE `notificaciones` (
  `id_notificacion` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `tipo` varchar(30) NOT NULL COMMENT 'ACTIVIDAD_HOY, BIENVENIDA, EVENTO_CALENDARIO',
  `titulo` varchar(200) NOT NULL,
  `mensaje` text DEFAULT NULL,
  `icono` varchar(50) DEFAULT 'fa-bell',
  `color` varchar(20) DEFAULT '#6366f1',
  `leida` tinyint(1) DEFAULT 0,
  `referencia_id` int(11) DEFAULT NULL COMMENT 'ID de actividad, evento, etc.',
  `fecha_creacion` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `notificaciones`
--

INSERT INTO `notificaciones` (`id_notificacion`, `id_usuario`, `tipo`, `titulo`, `mensaje`, `icono`, `color`, `leida`, `referencia_id`, `fecha_creacion`) VALUES
(3, 21, 'ACTIVIDAD_HOY', '📋 Actividad hoy: campaña de donacion de sangre', 'La actividad \"campaña de donacion de sangre\" está programada para hoy en uss.', 'fa-calendar-check', '#10b981', 1, 11, '2026-02-11 16:07:46');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `participacion`
--

CREATE TABLE `participacion` (
  `id_participacion` int(11) NOT NULL,
  `id_voluntario` int(11) DEFAULT NULL,
  `id_actividad` int(11) DEFAULT NULL,
  `id_rol_actividad` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `permiso`
--

CREATE TABLE `permiso` (
  `id_permiso` int(11) NOT NULL,
  `nombre_permiso` varchar(80) DEFAULT NULL,
  `descripcion` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `permiso`
--

INSERT INTO `permiso` (`id_permiso`, `nombre_permiso`, `descripcion`) VALUES
(1, 'Ver Dashboard', 'Acceso a la página principal'),
(2, 'Gestionar Usuarios', 'Crear, editar y eliminar usuarios'),
(3, 'Gestionar Voluntarios', 'Administrar voluntarios'),
(4, 'Gestionar Actividades', 'Crear y modificar actividades'),
(5, 'Gestionar Donaciones', 'Administrar donaciones'),
(6, 'Ver Reportes', 'Acceso a reportes del sistema'),
(7, 'Cerrar Sesión', 'Permitir cerrar sesión'),
(8, 'Ver Dashboard', 'Acceso a la página principal'),
(9, 'Gestionar Usuarios', 'Crear, editar y eliminar usuarios'),
(10, 'Gestionar Voluntarios', 'Administrar voluntarios'),
(11, 'Gestionar Actividades', 'Crear y modificar actividades'),
(12, 'Gestionar Donaciones', 'Administrar donaciones'),
(13, 'Ver Reportes', 'Acceso a reportes del sistema'),
(14, 'Cerrar Sesión', 'Permitir cerrar sesión');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `programacion_donacion`
--

CREATE TABLE `programacion_donacion` (
  `id_programacion` int(11) NOT NULL,
  `fecha_programada` date DEFAULT NULL,
  `estado` varchar(30) DEFAULT NULL,
  `id_donacion` int(11) DEFAULT NULL,
  `id_voluntario` int(11) DEFAULT NULL,
  `id_usuario_registro` int(11) DEFAULT NULL,
  `id_beneficiario` int(11) DEFAULT NULL,
  `id_lugar` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `recurso`
--

CREATE TABLE `recurso` (
  `id_recurso` int(11) NOT NULL,
  `nombre` varchar(120) DEFAULT NULL,
  `unidad_medida` varchar(30) DEFAULT NULL,
  `tipo_recurso` varchar(30) DEFAULT NULL,
  `descripcion` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `responsable_beneficiario`
--

CREATE TABLE `responsable_beneficiario` (
  `id_responsable` int(11) NOT NULL,
  `nombres` varchar(100) DEFAULT NULL,
  `apellidos` varchar(100) DEFAULT NULL,
  `cargo` varchar(100) DEFAULT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `correo` varchar(100) DEFAULT NULL,
  `id_beneficiario` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `rol_actividad`
--

CREATE TABLE `rol_actividad` (
  `id_rol_actividad` int(11) NOT NULL,
  `nombre_rol` varchar(50) DEFAULT NULL,
  `descripcion` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `rol_actividad`
--

INSERT INTO `rol_actividad` (`id_rol_actividad`, `nombre_rol`, `descripcion`) VALUES
(1, 'Coordinador de Actividad', 'Dirige la actividad'),
(2, 'Voluntario Operativo', 'Participa en la actividad'),
(3, 'Responsable Logística', 'Coordina recursos'),
(4, 'Responsable Reporte', 'Documenta la actividad'),
(5, 'Coordinador de Actividad', 'Dirige la actividad'),
(6, 'Voluntario Operativo', 'Participa en la actividad'),
(7, 'Responsable Logística', 'Coordina recursos'),
(8, 'Responsable Reporte', 'Documenta la actividad'),
(9, 'Voluntario', 'Participante en actividades de voluntariado'),
(10, 'Líder de Equipo', 'Lidera y coordina equipos de voluntarios'),
(11, 'Encargado de Logística', 'Gestiona recursos y logística de actividades'),
(12, 'Coordinador de Proyecto', 'Coordina y supervisa proyectos completos'),
(13, 'Administrador del Sistema', 'Acceso completo al sistema de voluntariado');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `rol_permiso`
--

CREATE TABLE `rol_permiso` (
  `id_rol_permiso` int(11) NOT NULL,
  `id_rol_sistema` int(11) DEFAULT NULL,
  `id_permiso` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `rol_permiso`
--

INSERT INTO `rol_permiso` (`id_rol_permiso`, `id_rol_sistema`, `id_permiso`) VALUES
(1, 1, 1),
(2, 1, 2),
(3, 1, 3),
(12, 1, 3),
(14, 1, 4),
(16, 1, 5),
(18, 1, 6),
(20, 1, 7),
(22, 1, 8),
(24, 1, 9),
(26, 1, 10),
(28, 1, 11),
(30, 1, 12),
(32, 1, 13),
(34, 1, 14);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `rol_sistema`
--

CREATE TABLE `rol_sistema` (
  `id_rol_sistema` int(11) NOT NULL,
  `nombre_rol` varchar(50) DEFAULT NULL,
  `descripcion` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `rol_sistema`
--

INSERT INTO `rol_sistema` (`id_rol_sistema`, `nombre_rol`, `descripcion`) VALUES
(1, 'Administrador', 'Acceso completo al sistema'),
(2, 'Coordinador', 'Coordina voluntarios y actividades'),
(3, 'Voluntario', 'Participante en actividades de voluntariado');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipo_beneficiario`
--

CREATE TABLE `tipo_beneficiario` (
  `id_tipo_beneficiario` int(11) NOT NULL,
  `nombre` varchar(100) DEFAULT NULL,
  `descripcion` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `tipo_beneficiario`
--

INSERT INTO `tipo_beneficiario` (`id_tipo_beneficiario`, `nombre`, `descripcion`) VALUES
(1, 'Orfanato', 'Centro de atención a menores sin familia'),
(2, 'Asilo', 'Centro para personas adultas mayores'),
(3, 'Comunidad Indígena', 'Comunidades originarias'),
(4, 'Zona Rural', 'Área rural necesitada'),
(5, 'Orfanato', 'Centro de atención a menores sin familia'),
(6, 'Asilo', 'Centro para personas adultas mayores'),
(7, 'Comunidad Indígena', 'Comunidades originarias'),
(8, 'Zona Rural', 'Área rural necesitada');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipo_donacion`
--

CREATE TABLE `tipo_donacion` (
  `id_tipo_donacion` int(11) NOT NULL,
  `nombre` varchar(100) DEFAULT NULL,
  `descripcion` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `tipo_donacion`
--

INSERT INTO `tipo_donacion` (`id_tipo_donacion`, `nombre`, `descripcion`) VALUES
(1, 'DINERO', 'Donación monetaria'),
(2, 'OBJETO', 'Donación de objetos o materiales');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `id_usuario` int(11) NOT NULL,
  `nombres` varchar(100) DEFAULT NULL,
  `apellidos` varchar(100) DEFAULT NULL,
  `correo` varchar(100) DEFAULT NULL,
  `username` varchar(60) DEFAULT NULL,
  `dni` varchar(20) DEFAULT NULL,
  `password_hash` varchar(255) DEFAULT NULL,
  `foto_perfil` varchar(255) DEFAULT NULL,
  `estado` varchar(20) DEFAULT NULL,
  `creado_en` datetime DEFAULT NULL,
  `actualizado_en` datetime DEFAULT NULL,
  `intentos_fallidos` int(11) NOT NULL DEFAULT 0,
  `bloqueado_hasta` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`id_usuario`, `nombres`, `apellidos`, `correo`, `username`, `dni`, `password_hash`, `foto_perfil`, `estado`, `creado_en`, `actualizado_en`, `intentos_fallidos`, `bloqueado_hasta`) VALUES
(21, 'luis', 'goerdy', 'tchi@gamil.com', 'geordy', NULL, '$2a$10$9sFidnqNMVPkbeapPM8mAe3YXUIYZTU0IavN4t2dU/l5C298l7j.C', 'img/perfil_21.webp', 'ACTIVO', '2026-02-04 01:41:12', '2026-02-12 00:26:32', 0, NULL),
(23, 'LEDGARD DANILO', 'CALVAY MARQUINA', 'ledgard@gmail.com', 'ledgard', '71852010', '$2a$10$KAuMs9UeiBVrIHm9GBj4OeEKAGZ40ewp2xC17IX7.xhChYqc12.WC', NULL, 'ACTIVO', '2026-02-05 11:02:16', NULL, 0, NULL),
(24, 'ELSA MARINA', 'RIOS ROJAS', 'elsa@gmail.com', 'elsa', '16719716', '$2a$10$WHy7Ito37f1oEi0eBixDauuyijuK2RIM14DhQdKaInLON6Rr/6Ls.', NULL, 'ACTIVO', '2026-02-05 11:26:00', '2026-02-05 11:33:43', 0, NULL),
(25, 'Luis', 'chinchay', 'jeslyn@gmail.com', 'luis_geordy_2009', '71852009', '$2a$10$5A1pMcxhkDceaMq6JrtB1O.nfJqFIEsGtPtHDfurtw/p82bUhebAi', NULL, 'ACTIVO', '2026-02-05 11:34:22', '2026-02-05 11:35:01', 0, NULL),
(26, 'ORDOÑEZ ARMANDO', 'SANTA CRUZ', 'armado@gmail.com', 'armado', '16401585', '$2a$10$VT368knFUSG8QzSKMGA/meWBzlBEhbcTxb2ItVv3Ojlt1r5psUlrq', NULL, 'Activo', '2026-02-05 16:08:34', '2026-02-05 16:08:34', 0, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario_rol`
--

CREATE TABLE `usuario_rol` (
  `id_usuario_rol` int(11) NOT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `id_rol_sistema` int(11) DEFAULT NULL,
  `asignado_en` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `voluntario`
--

CREATE TABLE `voluntario` (
  `id_voluntario` int(11) NOT NULL,
  `nombres` varchar(100) DEFAULT NULL,
  `apellidos` varchar(100) DEFAULT NULL,
  `dni` varchar(20) DEFAULT NULL,
  `correo` varchar(100) DEFAULT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `carrera` varchar(100) DEFAULT NULL,
  `cargo` varchar(50) DEFAULT 'Voluntario',
  `estado` varchar(20) DEFAULT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `id_rol_actividad` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `voluntario`
--

INSERT INTO `voluntario` (`id_voluntario`, `nombres`, `apellidos`, `dni`, `correo`, `telefono`, `carrera`, `cargo`, `estado`, `id_usuario`, `id_rol_actividad`) VALUES
(10, 'Luis', 'chinchay', '71852009', 'Geordy_31_71@hotmail.com', '967271494', 'sistemas', 'Voluntario', 'ACTIVO', 21, NULL),
(12, 'ADAN', 'VILCHEZ DELGADO', '16401917', 'adan@gmail.com', '984521456', 'contador', 'Voluntario', 'ACTIVO', 21, NULL),
(13, 'VANNIA LIZBETH', 'TANTALEAN CHINCHAY', '71852011', 'vania@gmail.com', '987456328', 'sistemas', 'Voluntario', 'ACTIVO', 24, NULL),
(14, 'ORDOÑEZ ARMANDO', 'SANTA CRUZ', '16401585', 'armado@gmail.com', '987456654', 'sistemas', 'Voluntario', 'ACTIVO', 26, NULL),
(15, 'JOSUE SEBASTIAN', 'NIÑO SILVA', '72324800', 'jose@gmail.com', '965741145', 'ingeneria de sistemas', 'Voluntario', 'ACTIVO', 24, NULL);

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `actividad`
--
ALTER TABLE `actividad`
  ADD PRIMARY KEY (`id_actividad`),
  ADD KEY `id_beneficiario` (`id_beneficiario`),
  ADD KEY `id_usuario_creador` (`id_usuario_creador`);

--
-- Indices de la tabla `actividades`
--
ALTER TABLE `actividades`
  ADD PRIMARY KEY (`id_actividad`),
  ADD KEY `fk_actividad_usuario` (`id_usuario`);

--
-- Indices de la tabla `actividad_lugar`
--
ALTER TABLE `actividad_lugar`
  ADD PRIMARY KEY (`id_actividad_lugar`),
  ADD KEY `id_actividad` (`id_actividad`),
  ADD KEY `id_lugar` (`id_lugar`);

--
-- Indices de la tabla `actividad_recurso`
--
ALTER TABLE `actividad_recurso`
  ADD PRIMARY KEY (`id_actividad_recurso`),
  ADD KEY `id_actividad` (`id_actividad`),
  ADD KEY `id_recurso` (`id_recurso`);

--
-- Indices de la tabla `asistencias`
--
ALTER TABLE `asistencias`
  ADD PRIMARY KEY (`id_asistencia`),
  ADD UNIQUE KEY `uk_asistencia_voluntario_actividad_fecha` (`id_voluntario`,`id_actividad`,`fecha`),
  ADD KEY `idx_asistencia_voluntario` (`id_voluntario`),
  ADD KEY `idx_asistencia_actividad` (`id_actividad`),
  ADD KEY `idx_asistencia_fecha` (`fecha`),
  ADD KEY `idx_asistencia_estado` (`estado`),
  ADD KEY `fk_asistencia_usuario` (`id_usuario_registro`);

--
-- Indices de la tabla `beneficiario`
--
ALTER TABLE `beneficiario`
  ADD PRIMARY KEY (`id_beneficiario`),
  ADD KEY `id_tipo_beneficiario` (`id_tipo_beneficiario`);

--
-- Indices de la tabla `certificados`
--
ALTER TABLE `certificados`
  ADD PRIMARY KEY (`id_certificado`),
  ADD UNIQUE KEY `codigo_certificado` (`codigo_certificado`),
  ADD KEY `idx_codigo` (`codigo_certificado`),
  ADD KEY `idx_voluntario` (`id_voluntario`),
  ADD KEY `idx_actividad` (`id_actividad`),
  ADD KEY `idx_estado` (`estado`),
  ADD KEY `fk_cert_usuario` (`id_usuario_emite`);

--
-- Indices de la tabla `donacion`
--
ALTER TABLE `donacion`
  ADD PRIMARY KEY (`id_donacion`),
  ADD KEY `id_tipo_donacion` (`id_tipo_donacion`),
  ADD KEY `id_actividad` (`id_actividad`),
  ADD KEY `id_usuario_registro` (`id_usuario_registro`);

--
-- Indices de la tabla `donacion_donante`
--
ALTER TABLE `donacion_donante`
  ADD PRIMARY KEY (`id_donacion_donante`),
  ADD KEY `id_donacion` (`id_donacion`),
  ADD KEY `id_donante` (`id_donante`);

--
-- Indices de la tabla `donante`
--
ALTER TABLE `donante`
  ADD PRIMARY KEY (`id_donante`);

--
-- Indices de la tabla `eventos_calendario`
--
ALTER TABLE `eventos_calendario`
  ADD PRIMARY KEY (`id_evento`),
  ADD KEY `fk_evento_usuario` (`id_usuario`);

--
-- Indices de la tabla `lugar`
--
ALTER TABLE `lugar`
  ADD PRIMARY KEY (`id_lugar`);

--
-- Indices de la tabla `movimiento_financiero`
--
ALTER TABLE `movimiento_financiero`
  ADD PRIMARY KEY (`id_movimiento`),
  ADD KEY `fk_mov_actividad` (`id_actividad`),
  ADD KEY `fk_mov_usuario` (`id_usuario`);

--
-- Indices de la tabla `notificaciones`
--
ALTER TABLE `notificaciones`
  ADD PRIMARY KEY (`id_notificacion`),
  ADD KEY `id_usuario` (`id_usuario`);

--
-- Indices de la tabla `participacion`
--
ALTER TABLE `participacion`
  ADD PRIMARY KEY (`id_participacion`),
  ADD KEY `id_voluntario` (`id_voluntario`),
  ADD KEY `id_actividad` (`id_actividad`),
  ADD KEY `id_rol_actividad` (`id_rol_actividad`);

--
-- Indices de la tabla `permiso`
--
ALTER TABLE `permiso`
  ADD PRIMARY KEY (`id_permiso`);

--
-- Indices de la tabla `programacion_donacion`
--
ALTER TABLE `programacion_donacion`
  ADD PRIMARY KEY (`id_programacion`),
  ADD KEY `id_donacion` (`id_donacion`),
  ADD KEY `id_voluntario` (`id_voluntario`),
  ADD KEY `id_usuario_registro` (`id_usuario_registro`),
  ADD KEY `id_beneficiario` (`id_beneficiario`),
  ADD KEY `id_lugar` (`id_lugar`);

--
-- Indices de la tabla `recurso`
--
ALTER TABLE `recurso`
  ADD PRIMARY KEY (`id_recurso`);

--
-- Indices de la tabla `responsable_beneficiario`
--
ALTER TABLE `responsable_beneficiario`
  ADD PRIMARY KEY (`id_responsable`),
  ADD KEY `id_beneficiario` (`id_beneficiario`);

--
-- Indices de la tabla `rol_actividad`
--
ALTER TABLE `rol_actividad`
  ADD PRIMARY KEY (`id_rol_actividad`);

--
-- Indices de la tabla `rol_permiso`
--
ALTER TABLE `rol_permiso`
  ADD PRIMARY KEY (`id_rol_permiso`),
  ADD KEY `id_rol_sistema` (`id_rol_sistema`),
  ADD KEY `id_permiso` (`id_permiso`);

--
-- Indices de la tabla `rol_sistema`
--
ALTER TABLE `rol_sistema`
  ADD PRIMARY KEY (`id_rol_sistema`);

--
-- Indices de la tabla `tipo_beneficiario`
--
ALTER TABLE `tipo_beneficiario`
  ADD PRIMARY KEY (`id_tipo_beneficiario`);

--
-- Indices de la tabla `tipo_donacion`
--
ALTER TABLE `tipo_donacion`
  ADD PRIMARY KEY (`id_tipo_donacion`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`id_usuario`);

--
-- Indices de la tabla `usuario_rol`
--
ALTER TABLE `usuario_rol`
  ADD PRIMARY KEY (`id_usuario_rol`),
  ADD KEY `id_usuario` (`id_usuario`),
  ADD KEY `id_rol_sistema` (`id_rol_sistema`);

--
-- Indices de la tabla `voluntario`
--
ALTER TABLE `voluntario`
  ADD PRIMARY KEY (`id_voluntario`),
  ADD KEY `id_usuario` (`id_usuario`),
  ADD KEY `fk_voluntario_rol` (`id_rol_actividad`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `actividad`
--
ALTER TABLE `actividad`
  MODIFY `id_actividad` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `actividades`
--
ALTER TABLE `actividades`
  MODIFY `id_actividad` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT de la tabla `actividad_lugar`
--
ALTER TABLE `actividad_lugar`
  MODIFY `id_actividad_lugar` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `actividad_recurso`
--
ALTER TABLE `actividad_recurso`
  MODIFY `id_actividad_recurso` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `asistencias`
--
ALTER TABLE `asistencias`
  MODIFY `id_asistencia` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `beneficiario`
--
ALTER TABLE `beneficiario`
  MODIFY `id_beneficiario` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `certificados`
--
ALTER TABLE `certificados`
  MODIFY `id_certificado` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `donacion`
--
ALTER TABLE `donacion`
  MODIFY `id_donacion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `donacion_donante`
--
ALTER TABLE `donacion_donante`
  MODIFY `id_donacion_donante` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `donante`
--
ALTER TABLE `donante`
  MODIFY `id_donante` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `eventos_calendario`
--
ALTER TABLE `eventos_calendario`
  MODIFY `id_evento` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `lugar`
--
ALTER TABLE `lugar`
  MODIFY `id_lugar` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `movimiento_financiero`
--
ALTER TABLE `movimiento_financiero`
  MODIFY `id_movimiento` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `notificaciones`
--
ALTER TABLE `notificaciones`
  MODIFY `id_notificacion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `participacion`
--
ALTER TABLE `participacion`
  MODIFY `id_participacion` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `permiso`
--
ALTER TABLE `permiso`
  MODIFY `id_permiso` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT de la tabla `programacion_donacion`
--
ALTER TABLE `programacion_donacion`
  MODIFY `id_programacion` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `recurso`
--
ALTER TABLE `recurso`
  MODIFY `id_recurso` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `responsable_beneficiario`
--
ALTER TABLE `responsable_beneficiario`
  MODIFY `id_responsable` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `rol_actividad`
--
ALTER TABLE `rol_actividad`
  MODIFY `id_rol_actividad` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT de la tabla `rol_permiso`
--
ALTER TABLE `rol_permiso`
  MODIFY `id_rol_permiso` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=36;

--
-- AUTO_INCREMENT de la tabla `rol_sistema`
--
ALTER TABLE `rol_sistema`
  MODIFY `id_rol_sistema` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `tipo_beneficiario`
--
ALTER TABLE `tipo_beneficiario`
  MODIFY `id_tipo_beneficiario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `tipo_donacion`
--
ALTER TABLE `tipo_donacion`
  MODIFY `id_tipo_donacion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `id_usuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT de la tabla `usuario_rol`
--
ALTER TABLE `usuario_rol`
  MODIFY `id_usuario_rol` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT de la tabla `voluntario`
--
ALTER TABLE `voluntario`
  MODIFY `id_voluntario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `actividad`
--
ALTER TABLE `actividad`
  ADD CONSTRAINT `actividad_ibfk_1` FOREIGN KEY (`id_beneficiario`) REFERENCES `beneficiario` (`id_beneficiario`),
  ADD CONSTRAINT `actividad_ibfk_2` FOREIGN KEY (`id_usuario_creador`) REFERENCES `usuario` (`id_usuario`);

--
-- Filtros para la tabla `actividades`
--
ALTER TABLE `actividades`
  ADD CONSTRAINT `fk_actividad_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Filtros para la tabla `actividad_lugar`
--
ALTER TABLE `actividad_lugar`
  ADD CONSTRAINT `actividad_lugar_ibfk_1` FOREIGN KEY (`id_actividad`) REFERENCES `actividad` (`id_actividad`),
  ADD CONSTRAINT `actividad_lugar_ibfk_2` FOREIGN KEY (`id_lugar`) REFERENCES `lugar` (`id_lugar`);

--
-- Filtros para la tabla `actividad_recurso`
--
ALTER TABLE `actividad_recurso`
  ADD CONSTRAINT `actividad_recurso_ibfk_1` FOREIGN KEY (`id_actividad`) REFERENCES `actividad` (`id_actividad`),
  ADD CONSTRAINT `actividad_recurso_ibfk_2` FOREIGN KEY (`id_recurso`) REFERENCES `recurso` (`id_recurso`);

--
-- Filtros para la tabla `asistencias`
--
ALTER TABLE `asistencias`
  ADD CONSTRAINT `fk_asistencia_actividad` FOREIGN KEY (`id_actividad`) REFERENCES `actividades` (`id_actividad`),
  ADD CONSTRAINT `fk_asistencia_usuario` FOREIGN KEY (`id_usuario_registro`) REFERENCES `usuario` (`id_usuario`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_asistencia_voluntario` FOREIGN KEY (`id_voluntario`) REFERENCES `voluntario` (`id_voluntario`);

--
-- Filtros para la tabla `beneficiario`
--
ALTER TABLE `beneficiario`
  ADD CONSTRAINT `beneficiario_ibfk_1` FOREIGN KEY (`id_tipo_beneficiario`) REFERENCES `tipo_beneficiario` (`id_tipo_beneficiario`);

--
-- Filtros para la tabla `certificados`
--
ALTER TABLE `certificados`
  ADD CONSTRAINT `fk_cert_actividad` FOREIGN KEY (`id_actividad`) REFERENCES `actividades` (`id_actividad`),
  ADD CONSTRAINT `fk_cert_usuario` FOREIGN KEY (`id_usuario_emite`) REFERENCES `usuario` (`id_usuario`),
  ADD CONSTRAINT `fk_cert_voluntario` FOREIGN KEY (`id_voluntario`) REFERENCES `voluntario` (`id_voluntario`);

--
-- Filtros para la tabla `donacion`
--
ALTER TABLE `donacion`
  ADD CONSTRAINT `donacion_fk_actividades` FOREIGN KEY (`id_actividad`) REFERENCES `actividades` (`id_actividad`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `donacion_ibfk_1` FOREIGN KEY (`id_tipo_donacion`) REFERENCES `tipo_donacion` (`id_tipo_donacion`),
  ADD CONSTRAINT `donacion_ibfk_3` FOREIGN KEY (`id_usuario_registro`) REFERENCES `usuario` (`id_usuario`);

--
-- Filtros para la tabla `donacion_donante`
--
ALTER TABLE `donacion_donante`
  ADD CONSTRAINT `donacion_donante_ibfk_1` FOREIGN KEY (`id_donacion`) REFERENCES `donacion` (`id_donacion`),
  ADD CONSTRAINT `donacion_donante_ibfk_2` FOREIGN KEY (`id_donante`) REFERENCES `donante` (`id_donante`);

--
-- Filtros para la tabla `eventos_calendario`
--
ALTER TABLE `eventos_calendario`
  ADD CONSTRAINT `fk_evento_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE SET NULL;

--
-- Filtros para la tabla `movimiento_financiero`
--
ALTER TABLE `movimiento_financiero`
  ADD CONSTRAINT `fk_mov_actividad` FOREIGN KEY (`id_actividad`) REFERENCES `actividades` (`id_actividad`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_mov_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`);

--
-- Filtros para la tabla `notificaciones`
--
ALTER TABLE `notificaciones`
  ADD CONSTRAINT `notificaciones_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE CASCADE;

--
-- Filtros para la tabla `participacion`
--
ALTER TABLE `participacion`
  ADD CONSTRAINT `participacion_ibfk_1` FOREIGN KEY (`id_voluntario`) REFERENCES `voluntario` (`id_voluntario`),
  ADD CONSTRAINT `participacion_ibfk_2` FOREIGN KEY (`id_actividad`) REFERENCES `actividad` (`id_actividad`),
  ADD CONSTRAINT `participacion_ibfk_3` FOREIGN KEY (`id_rol_actividad`) REFERENCES `rol_actividad` (`id_rol_actividad`);

--
-- Filtros para la tabla `programacion_donacion`
--
ALTER TABLE `programacion_donacion`
  ADD CONSTRAINT `programacion_donacion_ibfk_1` FOREIGN KEY (`id_donacion`) REFERENCES `donacion` (`id_donacion`),
  ADD CONSTRAINT `programacion_donacion_ibfk_2` FOREIGN KEY (`id_voluntario`) REFERENCES `voluntario` (`id_voluntario`),
  ADD CONSTRAINT `programacion_donacion_ibfk_3` FOREIGN KEY (`id_usuario_registro`) REFERENCES `usuario` (`id_usuario`),
  ADD CONSTRAINT `programacion_donacion_ibfk_4` FOREIGN KEY (`id_beneficiario`) REFERENCES `beneficiario` (`id_beneficiario`),
  ADD CONSTRAINT `programacion_donacion_ibfk_5` FOREIGN KEY (`id_lugar`) REFERENCES `lugar` (`id_lugar`);

--
-- Filtros para la tabla `responsable_beneficiario`
--
ALTER TABLE `responsable_beneficiario`
  ADD CONSTRAINT `responsable_beneficiario_ibfk_1` FOREIGN KEY (`id_beneficiario`) REFERENCES `beneficiario` (`id_beneficiario`);

--
-- Filtros para la tabla `rol_permiso`
--
ALTER TABLE `rol_permiso`
  ADD CONSTRAINT `rol_permiso_ibfk_1` FOREIGN KEY (`id_rol_sistema`) REFERENCES `rol_sistema` (`id_rol_sistema`),
  ADD CONSTRAINT `rol_permiso_ibfk_2` FOREIGN KEY (`id_permiso`) REFERENCES `permiso` (`id_permiso`);

--
-- Filtros para la tabla `usuario_rol`
--
ALTER TABLE `usuario_rol`
  ADD CONSTRAINT `usuario_rol_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`),
  ADD CONSTRAINT `usuario_rol_ibfk_2` FOREIGN KEY (`id_rol_sistema`) REFERENCES `rol_sistema` (`id_rol_sistema`);

--
-- Filtros para la tabla `voluntario`
--
ALTER TABLE `voluntario`
  ADD CONSTRAINT `fk_voluntario_rol` FOREIGN KEY (`id_rol_actividad`) REFERENCES `rol_actividad` (`id_rol_actividad`),
  ADD CONSTRAINT `voluntario_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
