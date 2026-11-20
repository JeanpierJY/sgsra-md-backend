package com.masterdrilling.sgsramd.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NotificacionResponse {
    private Long idNotificacion;
    private String dniDestinatario;
    private String rolDestinatario;
    private String titulo;
    private String mensaje;
    private String tipoAlerta;
    private Boolean leida;
    private LocalDateTime fechaCreacion;
}

