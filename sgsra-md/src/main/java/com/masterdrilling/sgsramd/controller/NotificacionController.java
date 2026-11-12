package com.masterdrilling.sgsramd.controller;

import com.masterdrilling.sgsramd.dto.response.MensajeGenericoResponse;
import com.masterdrilling.sgsramd.dto.response.NotificacionResponse;
import com.masterdrilling.sgsramd.service.INotificacionService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

// Endpoints para centro de notificaciones y alertas reactivas (RF46 - RF50)
@RestController
@RequestMapping("/api/v1/notificaciones")
@RequiredArgsConstructor
public class NotificacionController {

    private final INotificacionService notificacionService;

    @GetMapping("/{dni}")
    public ResponseEntity<List<NotificacionResponse>> listarPorUsuario(@PathVariable("dni") String dni) {
        return ResponseEntity.ok(notificacionService.listarPorUsuario(dni));
    }

    @GetMapping("/{dni}/paginado")
    public ResponseEntity<Page<NotificacionResponse>> listarPorUsuarioPaginado(
            @PathVariable("dni") String dni,
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(notificacionService.listarPorUsuarioPaginado(dni, pageable));
    }

    @GetMapping("/{dni}/no-leidas/conteo")
    public ResponseEntity<Map<String, Long>> contarNoLeidas(@PathVariable("dni") String dni) {
        long conteo = notificacionService.contarNoLeidas(dni);
        return ResponseEntity.ok(Map.of("noLeidas", conteo));
    }

    @PutMapping("/{id}/leer")
    public ResponseEntity<MensajeGenericoResponse> marcarComoLeida(@PathVariable("id") Long id) {
        return ResponseEntity.ok(notificacionService.marcarComoLeida(id));
    }

    @PutMapping("/leer-todas/{dni}")
    public ResponseEntity<MensajeGenericoResponse> marcarTodasComoLeidas(@PathVariable("dni") String dni) {
        return ResponseEntity.ok(notificacionService.marcarTodasComoLeidas(dni));
    }
}

