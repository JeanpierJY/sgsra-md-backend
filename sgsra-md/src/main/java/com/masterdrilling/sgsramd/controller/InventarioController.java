package com.masterdrilling.sgsramd.controller;

import com.masterdrilling.sgsramd.dto.request.RegistrarHerramientaRequest;
import com.masterdrilling.sgsramd.dto.response.DashboardStockResponse;
import com.masterdrilling.sgsramd.dto.response.FichaHerramientaResponse;
import com.masterdrilling.sgsramd.model.enums.CategoriaHerramienta;
import com.masterdrilling.sgsramd.service.IInventarioService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

// Endpoints para control de herramientas y pañol (RF33, RF35, RF44, RF45)
@RestController
@RequestMapping("/api/v1/inventario")
@RequiredArgsConstructor
public class InventarioController {

    private final IInventarioService inventarioService;

    @GetMapping("/dashboard")
    public ResponseEntity<DashboardStockResponse> obtenerDashboard() {
        return ResponseEntity.ok(inventarioService.obtenerMetricasDashboard());
    }

    @GetMapping("/herramientas/{codHerramienta}")
    public ResponseEntity<FichaHerramientaResponse> consultarHerramientaPorCodigo(
            @PathVariable("codHerramienta") String codHerramienta) {
        return ResponseEntity.ok(inventarioService.consultarHerramientaPorCodigo(codHerramienta));
    }

    @GetMapping("/herramientas")
    public ResponseEntity<List<FichaHerramientaResponse>> listarPorCategoria(
            @RequestParam(value = "categoria", required = false) CategoriaHerramienta categoria) {
        return ResponseEntity.ok(inventarioService.listarHerramientasPorCategoria(categoria));
    }

    @PostMapping("/herramientas")
    public ResponseEntity<FichaHerramientaResponse> registrarHerramienta(
            @RequestParam("correoAlmacenista") String correoAlmacenista,
            @Valid @RequestBody RegistrarHerramientaRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(inventarioService.registrarNuevaHerramienta(request, correoAlmacenista));
    }
}