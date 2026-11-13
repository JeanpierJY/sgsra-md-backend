package com.masterdrilling.sgsramd.dto.response;

import com.masterdrilling.sgsramd.model.enums.EstadoRecuperacion;
import com.masterdrilling.sgsramd.model.enums.RolUsuario;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

// Vista de una solicitud de recuperacion de contrasena para la bandeja del Administrador
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SolicitudRecuperacionResponse {

    private Long idRecuperacion;
    private String dniSolicitante;
    private String nombreSolicitante;
    private String correoSolicitante;
    private RolUsuario rolSolicitante;
    private String motivo;
    private EstadoRecuperacion estado;
    private LocalDateTime fechaSolicitud;
    private LocalDateTime fechaResolucion;
    private String dniAdministrador;
    private String observacionAdmin;
    private String fotoSelfieUrl;
}

