package com.masterdrilling.sgsramd.dto.response;

import com.masterdrilling.sgsramd.model.enums.EstadoItemSolicitud;
import com.masterdrilling.sgsramd.model.enums.EstadoSolicitud;
import com.masterdrilling.sgsramd.model.enums.PrioridadSolicitud;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

// Expediente completo de requerimiento para evaluacion en administracion (RF22)
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DetalleSolicitudResponse {

    private String solicitudNum;
    private LocalDate fechaEmision;
    private LocalTime horaEmision;
    private PrioridadSolicitud prioridad;
    private EstadoSolicitud estado;
    private String justificacionTecnica;

    // Datos de la maquina
    private String codMaquinaria;
    private String modeloMaquinaria;
    private String serieMaquinaria;

    // Datos del solicitante
    private String dniMecanico;
    private String nombreMecanico;
    private String telefonoMecanico;

    // Lineas de repuestos
    private List<ItemDetalleResponse> repuestos;

    // Resolucion de rechazo (si aplica)
    private DictamenRechazoResponse rechazo;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ItemDetalleResponse {
        private Integer item;
        private String codParte;
        private String nombreRepuesto;
        private Integer cantidadSolicitada;
        private EstadoItemSolicitud estadoItem;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class DictamenRechazoResponse {
        private String dictamenNum;
        private LocalDate fechaEvaluacion;
        private String justificacionRechazo;
        private String evaluador;
    }
}