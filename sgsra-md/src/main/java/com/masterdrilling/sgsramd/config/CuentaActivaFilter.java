package com.masterdrilling.sgsramd.config;

import com.masterdrilling.sgsramd.DAO.Usuario_DAO;
import com.masterdrilling.sgsramd.model.entity.Usuario;
import com.masterdrilling.sgsramd.model.enums.EstadoCuenta;
import com.masterdrilling.sgsramd.util.JwtTokenUtil;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.Optional;

// [H-GEN-08] Si el administrador desactiva una cuenta, cualquier peticion posterior con su token
// responde 401 (codigo CUENTA_INACTIVA) y la app movil cierra la sesion automaticamente.
@Component
@RequiredArgsConstructor
public class CuentaActivaFilter extends OncePerRequestFilter {

    public static final String CODIGO_CUENTA_INACTIVA = "CUENTA_INACTIVA";

    private final Usuario_DAO usuarioRepository;
    private final JwtTokenUtil jwtTokenUtil;

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        String uri = request.getRequestURI();
        // Endpoints publicos: login y recuperacion de clave pueden llegar con un token antiguo
        return !uri.startsWith("/api/v1/")
                || uri.startsWith("/api/v1/auth/login")
                || uri.startsWith("/api/v1/auth/recuperar-clave")
                || "OPTIONS".equalsIgnoreCase(request.getMethod());
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws ServletException, IOException {
        String header = request.getHeader("Authorization");
        if (header != null && header.startsWith("Bearer ")) {
            String correo = extraerCorreo(header.substring(7).trim());
            if (correo != null) {
                Optional<Usuario> usuario = usuarioRepository.findByCorreoCorporativo(correo);
                if (usuario.isEmpty() || usuario.get().getEstadoCuenta() == EstadoCuenta.INACTIVO) {
                    rechazar(response);
                    return;
                }
            }
        }
        chain.doFilter(request, response);
    }

    private String extraerCorreo(String token) {
        try {
            String correo = jwtTokenUtil.extraerCorreo(token);
            return correo != null && correo.contains("@") ? correo : null;
        } catch (Exception e) {
            return null; // Token ilegible: se deja pasar como peticion anonima
        }
    }

    private void rechazar(HttpServletResponse response) throws IOException {
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        response.setCharacterEncoding(StandardCharsets.UTF_8.name());
        response.getWriter().write("{\"exito\":false,\"codigo\":\"" + CODIGO_CUENTA_INACTIVA
                + "\",\"mensaje\":\"Su cuenta fue desactivada por el administrador. La sesion se cerro.\"}");
    }
}
