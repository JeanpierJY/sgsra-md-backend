package com.masterdrilling.sgsramd.service;

import com.masterdrilling.sgsramd.dto.response.EstadisticaDemandaResponse;

import java.io.ByteArrayInputStream;
import java.time.LocalDate;
import java.util.List;

// Contrato para reportes estadisticos y exportacion ofimatica (RF29, RF30)
public interface IReporteService {
    List<EstadisticaDemandaResponse> obtenerTopRepuestosDemandados(LocalDate fechaInicio, LocalDate fechaFin);
    ByteArrayInputStream exportarConsolidadoAuditoria(String formato, LocalDate fechaInicio, LocalDate fechaFin);
}