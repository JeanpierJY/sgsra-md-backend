package com.masterdrilling.sgsramd.dto.response;

import com.masterdrilling.sgsramd.model.enums.RolUsuario;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

// Respuesta de inicio de sesion con token JWT y perfil operativo (RF01, RF02)
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LoginResponse {

    private String tokenJwt;
    private String tipoToken;
    private Long idUsuario;
    private String dni;
    private String nombre;
    private String correoCorporativo;
    private RolUsuario rol;
}