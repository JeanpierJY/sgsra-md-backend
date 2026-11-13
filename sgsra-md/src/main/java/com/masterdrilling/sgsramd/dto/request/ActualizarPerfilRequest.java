package com.masterdrilling.sgsramd.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

// Actualizacion de datos basicos de contacto del trabajador (RF07)
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ActualizarPerfilRequest {

    private String nombre;

    @NotBlank(message = "El telefono movil es obligatorio")
    @Pattern(regexp = "^[0-9]{9}$", message = "El telefono debe contener exactamente 9 digitos numericos")
    private String telefono;

    @Size(min = 6, message = "La nueva contrasena debe tener al menos 6 caracteres")
    private String nuevaContrasena;
}
