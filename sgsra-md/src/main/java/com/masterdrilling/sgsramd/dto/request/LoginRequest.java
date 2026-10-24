package com.masterdrilling.sgsramd.dto.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

// Carga util para autenticacion mediante correo corporativo y contrasena (RF01)
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LoginRequest {

    @NotBlank(message = "El correo corporativo es obligatorio")
    @Email(message = "Formato de correo institucional no valido")
    private String correoCorporativo;

    @NotBlank(message = "La contrasena es obligatoria")
    private String contrasena;
}