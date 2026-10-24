package com.masterdrilling.sgsramd.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

// Serie de datos para renderizar el grafico de barras de consumo (RF29)
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class EstadisticaDemandaResponse {

    private String codParte;
    private String nombreRepuesto;
    private long cantidadTotalSolicitada;
}