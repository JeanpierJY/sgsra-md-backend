package com.masterdrilling.sgsramd.service;

import com.masterdrilling.sgsramd.dto.response.AuditoriaResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.time.LocalDateTime;

// Contrato de auditoria append-only inalterable (RF49)
public interface IAuditoriaService {
    void registrarAsiento(String idOperacion, Long idUsuario, String accion, String ipOrigen);
    Page<AuditoriaResponse> consultarBitacora(String idOperacion, LocalDateTime fechaInicio, LocalDateTime fechaFin, Pageable pageable);
}