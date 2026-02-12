package com.sistemadevoluntariado.util;

import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.crypto.SecretKey;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;



/**
 * Utilidad para generar y validar tokens JWT.
 * Configurado con expiración de 20 minutos (sliding expiration).
 */
public class JwtUtil {

    private static final Logger logger = Logger.getLogger(JwtUtil.class.getName());

    // Clave secreta para firmar los tokens (mínimo 256 bits / 32 caracteres)
    private static final String SECRET_KEY = "S1st3m4V0lunt4r14d0-S3cr3tK3y-2026!@#$%^&*";

    // Tiempo de expiración: 20 minutos en milisegundos
    public static final long EXPIRATION_TIME_MS = 20 * 60 * 1000;
    // Nombre de la cookie
    public static final String COOKIE_NAME = "AUTH_TOKEN";

    // Máxima edad de la cookie en segundos (20 minutos)
    public static final int COOKIE_MAX_AGE_SECONDS = 20 * 60;

    private static final SecretKey KEY = Keys.hmacShaKeyFor(
            SECRET_KEY.getBytes(StandardCharsets.UTF_8));

    /**
     * Genera un token JWT con los datos del usuario.
     */
    public static String generarToken(int idUsuario, String username, String nombres, String apellidos) {
        Date ahora = new Date();
        Date expiracion = new Date(ahora.getTime() + EXPIRATION_TIME_MS);

        return Jwts.builder()
                .subject(String.valueOf(idUsuario))
                .claim("username", username)
                .claim("nombres", nombres)
                .claim("apellidos", apellidos)
                .issuedAt(ahora)
                .expiration(expiracion)
                .signWith(KEY)
                .compact();
    }

    /**
     * Valida el token y retorna los claims si es válido.
     * Retorna null si el token es inválido o ha expirado.
     */
    public static Claims validarToken(String token) {
        try {
            return Jwts.parser()
                    .verifyWith(KEY)
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();
        } catch (ExpiredJwtException e) {
            logger.log(Level.INFO, "Token JWT expirado");
            return null;
        } catch (Exception e) {
            logger.log(Level.WARNING, "Token JWT inválido: " + e.getMessage());
            return null;
        }
    }

    /**
     * Renueva un token existente generando uno nuevo con 20 minutos más.
     * Solo renueva si el token actual es válido.
     */
    public static String renovarToken(String tokenActual) {
        Claims claims = validarToken(tokenActual);
        if (claims == null) {
            return null;
        }

        int idUsuario = Integer.parseInt(claims.getSubject());
        String username = claims.get("username", String.class);
        String nombres = claims.get("nombres", String.class);
        String apellidos = claims.get("apellidos", String.class);

        return generarToken(idUsuario, username, nombres, apellidos);
    }

    /**
     * Obtiene el ID de usuario desde un token válido.
     */
    public static int obtenerIdUsuario(String token) {
        Claims claims = validarToken(token);
        if (claims == null) {
            return -1;
        }
        return Integer.parseInt(claims.getSubject());
    }

    /**
     * Obtiene el username desde un token válido.
     */
    public static String obtenerUsername(String token) {
        Claims claims = validarToken(token);
        if (claims == null) {
            return null;
        }
        return claims.get("username", String.class);
    }
}
