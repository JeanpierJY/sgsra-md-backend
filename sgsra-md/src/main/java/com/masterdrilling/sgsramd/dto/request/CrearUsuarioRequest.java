package com.masterdrilling.sgsramd.dto.request;

import com.masterdrilling.sgsramd.model.enums.RolUsuario;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

// Carga util para registro administrativo de nuevos operarios y asignacion de roles
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CrearUsuarioRequest {

    @NotBlank(message = "El DNI es obligatorio")
    @Pattern(regexp = "^[0-9]{8}$", message = "El DNI debe contener exactamente 8 digitos numericos")
    private String dni;

    @NotBlank(message = "El nombre completo es obligatorio")
    @Size(max = 100, message = "El nombre no puede superar 100 caracteres")
    private String nombre;

    @NotBlank(message = "El correo corporativo es obligatorio")
    @Email(message = "Formato de correo institucional no valido")
    private String correoCorporativo;

    @NotBlank(message = "La contrasena inicial es obligatoria")
    @Size(min = 6, message = "La contrasena debe tener al menos 6 caracteres")
    private String contrasena;

    @NotNull(message = "Debe asignar un rol al usuario")
    private RolUsuario rol;

    // Campos especificos segun rol asignado
    private String especialidad;
    private String cargo;
    private String telefono;
    private String sedeAsignada;
}