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

    @NotBlank(message = "El nombre del operario no puede quedar vacio")
    @Size(max = 100, message = "El nombre no puede superar 100 caracteres")
    private String nombre;

    @NotBlank(message = "El telefono movil es obligatorio")
    @Pattern(regexp = "^[0-9]{9}$", message = "El telefono debe contener exactamente 9 digitos numericos")
    private String telefono;
}