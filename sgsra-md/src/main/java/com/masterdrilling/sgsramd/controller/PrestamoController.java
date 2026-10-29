package com.masterdrilling.sgsramd.controller;

import com.masterdrilling.sgsramd.dto.request.DevolucionHerramientaRequest;
import com.masterdrilling.sgsramd.dto.request.RegistrarPrestamoRequest;
import com.masterdrilling.sgsramd.dto.request.ReporteExtravioRequest;
import com.masterdrilling.sgsramd.dto.response.MensajeGenericoResponse;
import com.masterdrilling.sgsramd.service.IPrestamoService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

// Endpoints para salidas, retornos con escaneo QR y extravios (RF34-RF42)
@RestController
@RequestMapping("/api/v1/prestamos")
@RequiredArgsConstructor
public class PrestamoController {

    private final IPrestamoService prestamoService;

    @PostMapping
    public ResponseEntity<MensajeGenericoResponse> registrarPrestamo(
            @RequestParam("correoAlmacenista") String correoAlmacenista,
            @Valid @RequestBody RegistrarPrestamoRequest request,
            HttpServletRequest httpRequest) {
        String ipOrigen = httpRequest.getRemoteAddr();
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(prestamoService.registrarPrestamo(correoAlmacenista, request, ipOrigen));
    }

    @PostMapping("/devolucion")
    public ResponseEntity<MensajeGenericoResponse> registrarDevolucion(
            @RequestParam("correoAlmacenista") String correoAlmacenista,
            @Valid @RequestBody DevolucionHerramientaRequest request,
            HttpServletRequest httpRequest) {
        String ipOrigen = httpRequest.getRemoteAddr();
        return ResponseEntity.ok(prestamoService.registrarDevolucion(correoAlmacenista, request, ipOrigen));
    }

    @PostMapping("/extravio")
    public ResponseEntity<MensajeGenericoResponse> reportarExtravio(
            @RequestParam("correoAlmacenista") String correoAlmacenista,
            @Valid @RequestBody ReporteExtravioRequest request,
            HttpServletRequest httpRequest) {
        String ipOrigen = httpRequest.getRemoteAddr();
        return ResponseEntity.ok(prestamoService.reportarHerramientaExtraviada(correoAlmacenista, request, ipOrigen));
    }

    @GetMapping
    public ResponseEntity<List<com.masterdrilling.sgsramd.dto.response.PrestamoResumenResponse>> listarTodosLosPrestamos() {
        return ResponseEntity.ok(prestamoService.listarTodosLosPrestamos());
    }

    @GetMapping("/mecanico/{dniMecanico}")
    public ResponseEntity<List<com.masterdrilling.sgsramd.dto.response.PrestamoResumenResponse>> listarPorMecanico(
            @PathVariable("dniMecanico") String dniMecanico) {
        return ResponseEntity.ok(prestamoService.listarPrestamosPorMecanico(dniMecanico));
    }
}