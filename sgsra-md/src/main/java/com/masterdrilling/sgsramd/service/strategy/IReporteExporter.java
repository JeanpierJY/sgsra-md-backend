package com.masterdrilling.sgsramd.service.strategy;

import java.io.ByteArrayInputStream;
import java.util.List;

// Interfaz del patron Strategy para formatos de exportacion (RF30 / Silabo U3)
public interface IReporteExporter {
    String getTipoFormato();
    ByteArrayInputStream exportarReporte(String titulo, List<String> cabeceras, List<List<String>> filas);
}