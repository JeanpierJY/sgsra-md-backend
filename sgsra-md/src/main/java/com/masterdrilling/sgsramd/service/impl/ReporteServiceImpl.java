package com.masterdrilling.sgsramd.service.impl;

import com.masterdrilling.sgsramd.dto.response.EstadisticaDemandaResponse;
import com.masterdrilling.sgsramd.exception.BadRequestException;
import com.masterdrilling.sgsramd.model.entity.Solicitud;
import com.masterdrilling.sgsramd.repository.SolicitudDetalleRepository;
import com.masterdrilling.sgsramd.repository.SolicitudRepository;
import com.masterdrilling.sgsramd.service.IReporteService;
import com.masterdrilling.sgsramd.service.strategy.IReporteExporter;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.ByteArrayInputStream;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ReporteServiceImpl implements IReporteService {

    private final SolicitudDetalleRepository detalleRepository;
    private final SolicitudRepository solicitudRepository;
    private final List<IReporteExporter> exportadores;

    @Override
    @Transactional(readOnly = true)
    public List<EstadisticaDemandaResponse> obtenerTopRepuestosDemandados(LocalDate fechaInicio, LocalDate fechaFin) {
        LocalDate fInicio = (fechaInicio != null) ? fechaInicio : LocalDate.now().minusMonths(3);
        LocalDate fFin = (fechaFin != null) ? fechaFin : LocalDate.now();

        return detalleRepository.obtenerDemandaPorPeriodo(fInicio, fFin).stream()
                .map(fila -> EstadisticaDemandaResponse.builder()
                        .codParte((String) fila[0])
                        .nombreRepuesto((String) fila[1])
                        .cantidadTotalSolicitada(((Number) fila[2]).longValue())
                        .build())
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public ByteArrayInputStream exportarConsolidadoAuditoria(String formato, LocalDate fechaInicio, LocalDate fechaFin) {
        IReporteExporter exporter = exportadores.stream()
                .filter(e -> e.getTipoFormato().equalsIgnoreCase(formato))
                .findFirst()
                .orElseThrow(() -> new BadRequestException("Formato de exportacion no soportado: " + formato));

        List<Solicitud> solicitudes = solicitudRepository.findAll();
        List<String> cabeceras = List.of("Nro Solicitud", "Fecha", "Mecanico", "Maquina", "Prioridad", "Estado");
        List<List<String>> filas = new ArrayList<>();

        for (Solicitud s : solicitudes) {
            filas.add(List.of(
                    s.getSolicitudNum(),
                    s.getFechaEmision().toString(),
                    s.getMecanico().getNombreMecanico(),
                    s.getMaquinaria().getCodMaquinaria(),
                    s.getPrioridadSolicitud().name(),
                    s.getEstadoSolicitud().name()
            ));
        }

        return exporter.exportarReporte("Consolidado_Solicitudes", cabeceras, filas);
    }
}