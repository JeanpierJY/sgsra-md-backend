package com.masterdrilling.sgsramd.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

// Respuesta uniforme para transacciones exitosas y alertas de servidor
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MensajeGenericoResponse {

    private boolean exito;
    private String mensaje;
    private Object dato;
}