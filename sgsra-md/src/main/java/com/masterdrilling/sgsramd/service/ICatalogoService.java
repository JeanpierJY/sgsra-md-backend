package com.masterdrilling.sgsramd.service;

import com.masterdrilling.sgsramd.dto.request.ActualizarRepuestoRequest;
import com.masterdrilling.sgsramd.dto.request.CrearRepuestoRequest;
import com.masterdrilling.sgsramd.dto.response.MensajeGenericoResponse;
import com.masterdrilling.sgsramd.dto.response.RepuestoResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;

// Contrato para catalogo maestro de repuestos pesados (RF09, RF10, RF12, RF32)
public interface ICatalogoService {
    Page<RepuestoResponse> listarCatalogo(Pageable pageable);
    List<RepuestoResponse> buscarPredictivo(String termino);
    RepuestoResponse obtenerPorCodigo(String codParte);
    RepuestoResponse registrarRepuesto(CrearRepuestoRequest request);
    RepuestoResponse actualizarRepuesto(String codParte, ActualizarRepuestoRequest request);
    MensajeGenericoResponse cambiarEstadoRepuesto(String codParte, boolean activo);
}