package com.masterdrilling.sgsramd.service;

import com.masterdrilling.sgsramd.dto.request.DevolucionHerramientaRequest;
import com.masterdrilling.sgsramd.dto.request.RegistrarPrestamoRequest;
import com.masterdrilling.sgsramd.dto.request.ReporteExtravioRequest;
import com.masterdrilling.sgsramd.dto.response.MensajeGenericoResponse;

// Contrato de prestamos, devoluciones QR y reporte de extravios (RF36-RF42)
public interface IPrestamoService {
    MensajeGenericoResponse registrarPrestamo(String correoAlmacenista, RegistrarPrestamoRequest request, String ipOrigen);
    MensajeGenericoResponse registrarDevolucion(String correoAlmacenista, DevolucionHerramientaRequest request, String ipOrigen);
    MensajeGenericoResponse reportarHerramientaExtraviada(ReporteExtravioRequest request, String ipOrigen);
}