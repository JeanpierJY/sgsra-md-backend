package com.masterdrilling.sgsramd.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

// Representacion de repuesto para busqueda y vista de catalogo (RF09, RF10, RF12)
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RepuestoResponse {

    private String codParte;
    private String nombreRepuesto;
    private Integer stockActual;
    private Integer stockMinimo;
    private String descripcion;
    private Boolean activo;
}