package com.masterdrilling.sgsramd.service;

import com.masterdrilling.sgsramd.dto.request.RegistrarHerramientaRequest;
import com.masterdrilling.sgsramd.dto.response.DashboardStockResponse;
import com.masterdrilling.sgsramd.dto.response.FichaHerramientaResponse;
import com.masterdrilling.sgsramd.model.enums.CategoriaHerramienta;

import java.util.List;

// Contrato de pañol y dashboard de herramientas (RF33, RF35, RF44, RF45)
public interface IInventarioService {
    DashboardStockResponse obtenerMetricasDashboard();
    FichaHerramientaResponse consultarHerramientaPorCodigo(String codHerramienta);
    List<FichaHerramientaResponse> listarHerramientasPorCategoria(CategoriaHerramienta categoria);
    FichaHerramientaResponse registrarNuevaHerramienta(RegistrarHerramientaRequest request, String correoAlmacenista);
}