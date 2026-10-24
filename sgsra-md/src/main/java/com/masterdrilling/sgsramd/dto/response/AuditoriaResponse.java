package com.masterdrilling.sgsramd.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

// Registro individual de bitacora inalterable (RF31, RF49)
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AuditoriaResponse {

    private Long idAuditoria;
    private String idOperacion;
    private Long idUsuario;
    private String accion;
    private String ipOrigen;
    private LocalDateTime timestamp;
    private String hashSha256;
}