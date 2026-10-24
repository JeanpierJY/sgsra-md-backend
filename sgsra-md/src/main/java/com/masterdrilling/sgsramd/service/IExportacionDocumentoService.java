package com.masterdrilling.sgsramd.service;

import java.io.ByteArrayInputStream;
import java.time.LocalDate;

// Contrato de soporte para descargas binarias
public interface IExportacionDocumentoService {
    ByteArrayInputStream generarDocumento(String formato, LocalDate inicio, LocalDate fin);
}