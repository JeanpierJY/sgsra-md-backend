package com.masterdrilling.sgsramd.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

// Contadores en tiempo real para las tarjetas del pañol (RF33)
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DashboardStockResponse {

    private long totalDisponibles;
    private long totalPrestadas;
    private long totalEnMora;
    private long totalEnMantenimiento;
    private long totalExtraviadas;
}