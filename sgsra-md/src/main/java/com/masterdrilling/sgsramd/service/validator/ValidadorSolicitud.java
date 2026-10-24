package com.masterdrilling.sgsramd.service.validator;

import com.masterdrilling.sgsramd.dto.request.SolicitudRepuestoRequest;

// Contrato de validacion extensible bajo principio Open/Closed (OCP)
public interface ValidadorSolicitud {
    void validar(SolicitudRepuestoRequest request);
}