package com.masterdrilling.sgsramd.service.impl;

import com.masterdrilling.sgsramd.service.IExportacionDocumentoService;
import com.masterdrilling.sgsramd.service.IReporteService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.io.ByteArrayInputStream;
import java.time.LocalDate;

@Service
@RequiredArgsConstructor
public class ExportacionDocumentoServiceImpl implements IExportacionDocumentoService {

    private final IReporteService reporteService;

    @Override
    public ByteArrayInputStream generarDocumento(String formato, LocalDate inicio, LocalDate fin) {
        return reporteService.exportarConsolidadoAuditoria(formato, inicio, fin);
    }
}