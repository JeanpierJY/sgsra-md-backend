package com.masterdrilling.sgsramd.controller;

import com.masterdrilling.sgsramd.dto.request.AprobacionParcialRequest;
import com.masterdrilling.sgsramd.dto.request.ContactarProveedorRequest;
import com.masterdrilling.sgsramd.dto.request.DictamenRechazoRequest;
import com.masterdrilling.sgsramd.dto.request.SolicitudRepuestoRequest;
import com.masterdrilling.sgsramd.dto.response.DetalleSolicitudResponse;
import com.masterdrilling.sgsramd.dto.response.MensajeGenericoResponse;
import com.masterdrilling.sgsramd.dto.response.SolicitudResumenResponse;
import com.masterdrilling.sgsramd.model.enums.EstadoSolicitud;
import com.masterdrilling.sgsramd.service.ISolicitudService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

// Endpoints para tramitacion, aprobacion y rechazo de solicitudes (RF13-RF28)
@RestController
@RequestMapping("/api/v1/solicitudes")
@RequiredArgsConstructor
public class SolicitudController {

    private final ISolicitudService solicitudService;

    @PostMapping
    public ResponseEntity<MensajeGenericoResponse> registrarSolicitud(
            @RequestParam("correoMecanico") String correoMecanico,
            @Valid @RequestBody SolicitudRepuestoRequest request,
            HttpServletRequest httpRequest) {
        String ipOrigen = httpRequest.getRemoteAddr();
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(solicitudService.registrarSolicitud(correoMecanico, request, ipOrigen));
    }

    @GetMapping("/mecanico")
    public ResponseEntity<Page<SolicitudResumenResponse>> listarHistorialMecanico(
            @RequestParam("correoMecanico") String correoMecanico,
            Pageable pageable) {
        return ResponseEntity.ok(solicitudService.listarHistorialMecanico(correoMecanico, pageable));
    }

    @GetMapping("/bandeja")
    public ResponseEntity<List<SolicitudResumenResponse>> listarBandejaAdministrador(
            @RequestParam(value = "estado", required = false) EstadoSolicitud estado) {
        return ResponseEntity.ok(solicitudService.listarBandejaAdministrador(estado));
    }

    @GetMapping("/{solicitudNum}")
    public ResponseEntity<DetalleSolicitudResponse> obtenerDetalleSolicitud(@PathVariable("solicitudNum") String solicitudNum) {
        return ResponseEntity.ok(solicitudService.obtenerDetalleSolicitud(solicitudNum));
    }

    @PutMapping("/{solicitudNum}/aprobar")
    public ResponseEntity<MensajeGenericoResponse> aprobarTotal(
            @PathVariable("solicitudNum") String solicitudNum,
            HttpServletRequest httpRequest) {
        String ipOrigen = httpRequest.getRemoteAddr();
        return ResponseEntity.ok(solicitudService.aprobarSolicitudTotal(solicitudNum, ipOrigen));
    }

    @PutMapping("/{solicitudNum}/rechazar")
    public ResponseEntity<MensajeGenericoResponse> rechazarTotal(
            @PathVariable("solicitudNum") String solicitudNum,
            @RequestParam("correoAdmin") String correoAdmin,
            @Valid @RequestBody DictamenRechazoRequest request,
            HttpServletRequest httpRequest) {
        String ipOrigen = httpRequest.getRemoteAddr();
        return ResponseEntity.ok(solicitudService.rechazarSolicitudTotal(solicitudNum, correoAdmin, request, ipOrigen));
    }

    @PutMapping("/{solicitudNum}/aprobar-parcial")
    public ResponseEntity<MensajeGenericoResponse> aprobarParcial(
            @PathVariable("solicitudNum") String solicitudNum,
            @RequestParam("correoAdmin") String correoAdmin,
            @Valid @RequestBody AprobacionParcialRequest request,
            HttpServletRequest httpRequest) {
        String ipOrigen = httpRequest.getRemoteAddr();
        return ResponseEntity.ok(solicitudService.aprobarSolicitudParcial(solicitudNum, correoAdmin, request, ipOrigen));
    }

    @PutMapping("/{solicitudNum}/contactar")
    public ResponseEntity<MensajeGenericoResponse> marcarContactada(
            @PathVariable("solicitudNum") String solicitudNum,
            @Valid @RequestBody ContactarProveedorRequest request,
            HttpServletRequest httpRequest) {
        String ipOrigen = httpRequest.getRemoteAddr();
        return ResponseEntity.ok(solicitudService.marcarOrdenContactada(solicitudNum, request, ipOrigen));
    }
}