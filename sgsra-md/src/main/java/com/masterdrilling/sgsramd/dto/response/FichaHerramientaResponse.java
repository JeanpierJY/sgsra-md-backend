package com.masterdrilling.sgsramd.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

// Expediente tecnico obtenido tras escanear el codigo QR (RF34, RF35)
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FichaHerramientaResponse {

    private String codHerramienta;
    private String nombreHerramienta;
    private String marcaHerramienta;
    private String categoria;
    private String estadoActual;
}