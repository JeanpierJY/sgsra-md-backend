package com.masterdrilling.sgsramd.controller;

import com.masterdrilling.sgsramd.dto.response.EstadisticaDemandaResponse;
import com.masterdrilling.sgsramd.service.IReporteService;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.InputStreamResource;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.ByteArrayInputStream;
import java.time.LocalDate;
import java.util.List;

// Endpoints para estadisticas de demanda y exportacion ofimatica (RF29, RF30)
@RestController
@RequestMapping("/api/v1/reportes")
@RequiredArgsConstructor
public class ReporteController {

    private final IReporteService reporteService;

    @GetMapping("/demanda")
    public ResponseEntity<List<EstadisticaDemandaResponse>> obtenerDemanda(
            @RequestParam(value = "inicio", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate inicio,
            @RequestParam(value = "fin", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate fin) {
        return ResponseEntity.ok(reporteService.obtenerTopRepuestosDemandados(inicio, fin));
    }

    @GetMapping("/exportar")
    public ResponseEntity<InputStreamResource> exportarReporte(
            @RequestParam("formato") String formato,
            @RequestParam(value = "inicio", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate inicio,
            @RequestParam(value = "fin", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate fin) {

        ByteArrayInputStream stream = reporteService.exportarConsolidadoAuditoria(formato, inicio, fin);

        String nombreArchivo;
        MediaType mediaType;

        if ("EXCEL".equalsIgnoreCase(formato)) {
            nombreArchivo = "Reporte_Solicitudes_" + LocalDate.now() + ".xlsx";
            mediaType = MediaType.parseMediaType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        } else {
            nombreArchivo = "Reporte_Solicitudes_" + LocalDate.now() + ".csv";
            mediaType = MediaType.parseMediaType("text/csv");
        }

        HttpHeaders headers = new HttpHeaders();
        headers.add("Content-Disposition", "attachment; filename=" + nombreArchivo);

        return ResponseEntity.ok()
                .headers(headers)
                .contentType(mediaType)
                .body(new InputStreamResource(stream));
    }
}