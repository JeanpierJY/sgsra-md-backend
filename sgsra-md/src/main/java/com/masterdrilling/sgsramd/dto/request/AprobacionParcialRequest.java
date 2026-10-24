package com.masterdrilling.sgsramd.dto.request;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

// Autorizacion discriminada por componente (RF26)
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AprobacionParcialRequest {

    @NotEmpty(message = "Debe remitir el dictamen para cada componente de la orden")
    @Valid
    private List<ItemAprobacionParcialRequest> items;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ItemAprobacionParcialRequest {
        @NotNull(message = "El numero de item es obligatorio")
        private Integer item;

        @NotNull(message = "Debe indicar si el item queda aprobado o rechazado")
        private Boolean aprobado;

        // Obligatorio unicamente si aprobado es false
        private String motivoRechazoItem;
    }
}