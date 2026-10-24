package com.masterdrilling.sgsramd.util;

import com.masterdrilling.sgsramd.model.enums.RolUsuario;
import org.springframework.stereotype.Component;

import java.util.Base64;
import java.util.UUID;

// Utilidad provisional y ligera para emision y desempaquetado de tokens de sesion (RF01)
@Component
public class JwtTokenUtil {

    public String generarToken(String correo, RolUsuario rol) {
        String payload = correo + ":" + rol.name() + ":" + UUID.randomUUID() + ":" + System.currentTimeMillis();
        return Base64.getUrlEncoder().withoutPadding().encodeToString(payload.getBytes());
    }

    public String extraerCorreo(String token) {
        String decoded = new String(Base64.getUrlDecoder().decode(token));
        return decoded.split(":")[0];
    }
}