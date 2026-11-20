package com.masterdrilling.sgsramd.dto.response;

import com.masterdrilling.sgsramd.model.enums.RolUsuario;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

// Ficha de "Mi Perfil" universal para los 3 roles (RF07, REQ-01)
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PerfilResponse {

    private String dni;
    private String nombre;
    private String correoCorporativo;
    private RolUsuario rol;
    private String telefono;        // null para Administrador (no registra telefono)
    private boolean telefonoEditable; // solo Mecanico y Almacenista
    private String sedeAsignada;
    private String fotoPerfilUrl;    // solo Almacenista
}
