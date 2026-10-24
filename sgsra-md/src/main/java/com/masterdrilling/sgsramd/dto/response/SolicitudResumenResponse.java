package com.masterdrilling.sgsramd.dto.response;

import com.masterdrilling.sgsramd.model.enums.EstadoSolicitud;
import com.masterdrilling.sgsramd.model.enums.PrioridadSolicitud;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalTime;

// Ficha sintetica para listas e historiales (RF19, RF20, RF21)
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SolicitudResumenResponse {

    private String solicitudNum;
    private LocalDate fechaEmision;
    private LocalTime horaEmision;
    private PrioridadSolicitud prioridad;
    private EstadoSolicitud estado;
    private String codMaquinaria;
    private String modeloMaquinaria;
    private String nombreMecanico;
    private int totalComponentes;
}