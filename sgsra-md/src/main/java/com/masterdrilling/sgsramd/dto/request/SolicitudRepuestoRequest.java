package com.masterdrilling.sgsramd.dto.request;

import com.masterdrilling.sgsramd.model.enums.PrioridadSolicitud;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

// Payload para el registro de requerimiento de repuestos (RF13-RF17)
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SolicitudRepuestoRequest {

    @NotBlank(message = "Debe asociar la solicitud al codigo de la maquinaria afectada")
    private String codMaquinaria;

    @NotNull(message = "Debe seleccionar un nivel de prioridad")
    private PrioridadSolicitud prioridad;

    @NotBlank(message = "La justificacion tecnica es obligatoria")
    @Size(min = 10, max = 500, message = "La justificacion tecnica debe contener entre 10 y 500 caracteres")
    private String justificacionTecnica;

    @NotEmpty(message = "La solicitud debe incluir al menos un repuesto")
    @Valid
    private List<ItemRepuestoRequest> items;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ItemRepuestoRequest {
        @NotBlank(message = "El codigo de parte es obligatorio")
        private String codParte;

        @NotNull(message = "La cantidad solicitada es obligatoria")
        @Min(value = 1, message = "La cantidad de repuesto debe ser mayor a cero")
        private Integer cantidad;
    }
}