package com.masterdrilling.sgsramd.dto.request;

import com.masterdrilling.sgsramd.model.enums.EstadoDevolucion;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

// Calificacion e inspeccion fisica del retorno de herramientas (RF38, RF39, RF40)
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DevolucionHerramientaRequest {

    @NotBlank(message = "El numero de prestamo asociado es obligatorio")
    private String prestamoNum;

    private String detalleIncidencia;

    @NotEmpty(message = "Debe incluir la inspeccion de los activos a devolver")
    @Valid
    private List<ItemDevolucionRequest> items;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ItemDevolucionRequest {
        @NotBlank(message = "El codigo de la herramienta es obligatorio")
        private String codHerramienta;

        @NotNull(message = "Debe calificar la condicion fisica de retorno")
        private EstadoDevolucion estadoFisico;
    }
}