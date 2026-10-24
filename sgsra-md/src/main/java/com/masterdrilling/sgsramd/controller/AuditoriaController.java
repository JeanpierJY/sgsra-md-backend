package com.masterdrilling.sgsramd.controller;

import com.masterdrilling.sgsramd.dto.response.AuditoriaResponse;
import com.masterdrilling.sgsramd.service.IAuditoriaService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;

// Endpoint de consulta y fiscalizacion de bitacora inalterable (RF31, RF49)
@RestController
@RequestMapping("/api/v1/auditoria")
@RequiredArgsConstructor
public class AuditoriaController {

    private final IAuditoriaService auditoriaService;

    @GetMapping
    public ResponseEntity<Page<AuditoriaResponse>> consultarBitacora(
            @RequestParam(value = "idOperacion", required = false) String idOperacion,
            @RequestParam(value = "inicio", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime inicio,
            @RequestParam(value = "fin", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime fin,
            Pageable pageable) {
        return ResponseEntity.ok(auditoriaService.consultarBitacora(idOperacion, inicio, fin, pageable));
    }
}