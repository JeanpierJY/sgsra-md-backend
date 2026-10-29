package com.masterdrilling.sgsramd.dto.response;

import com.masterdrilling.sgsramd.model.enums.EstadoPrestamo;
import lombok.*;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PrestamoResumenResponse {
    private String prestamoNum;
    private String dniMecanico;
    private String nombreMecanico;
    private EstadoPrestamo estadoPrestamo;
    private LocalDate fechaPrestamo;
    private LocalTime horaSalida;
    private List<ItemHerramientaPrestamo> herramientas;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ItemHerramientaPrestamo {
        private String codHerramienta;
        private String nombreHerramienta;
        private String estadoHerramienta;
        private String estadoFisicoActual;
    }
}