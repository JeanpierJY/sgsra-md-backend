package com.masterdrilling.sgsramd.controller;

import com.masterdrilling.sgsramd.dto.request.CrearRepuestoRequest;
import com.masterdrilling.sgsramd.dto.response.RepuestoResponse;
import com.masterdrilling.sgsramd.service.ICatalogoService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

// Endpoints para consulta de catalogo y busqueda predictiva (RF09-RF12, RF32)
@RestController
@RequestMapping("/api/v1/catalogo")
@RequiredArgsConstructor
public class CatalogoController {

    private final ICatalogoService catalogoService;

    @GetMapping
    public ResponseEntity<Page<RepuestoResponse>> listarCatalogo(Pageable pageable) {
        return ResponseEntity.ok(catalogoService.listarCatalogo(pageable));
    }

    @GetMapping("/buscar")
    public ResponseEntity<List<RepuestoResponse>> buscarPredictivo(@RequestParam("termino") String termino) {
        return ResponseEntity.ok(catalogoService.buscarPredictivo(termino));
    }

    @GetMapping("/{codParte}")
    public ResponseEntity<RepuestoResponse> obtenerDetalleRepuesto(@PathVariable("codParte") String codParte) {
        return ResponseEntity.ok(catalogoService.obtenerPorCodigo(codParte));
    }

    @PostMapping
    public ResponseEntity<RepuestoResponse> registrarRepuesto(@Valid @RequestBody CrearRepuestoRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(catalogoService.registrarRepuesto(request));
    }
    
    @PutMapping("/{codParte}")
    public ResponseEntity<RepuestoResponse> actualizarRepuesto(
            @PathVariable("codParte") String codParte,
            @Valid @RequestBody com.masterdrilling.sgsramd.dto.request.ActualizarRepuestoRequest request) {
        return ResponseEntity.ok(catalogoService.actualizarRepuesto(codParte, request));
    }

    @PutMapping("/{codParte}/estado")
    public ResponseEntity<com.masterdrilling.sgsramd.dto.response.MensajeGenericoResponse> cambiarEstadoRepuesto(
            @PathVariable("codParte") String codParte,
            @RequestParam("activo") boolean activo) {
        return ResponseEntity.ok(catalogoService.cambiarEstadoRepuesto(codParte, activo));
    }
}