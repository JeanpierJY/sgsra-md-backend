package com.masterdrilling.sgsramd.service.validator;

import com.masterdrilling.sgsramd.dto.request.SolicitudRepuestoRequest;
import com.masterdrilling.sgsramd.exception.BadRequestException;
import org.springframework.stereotype.Component;

// Valida obligatoriedad y umbral minimo de 10 caracteres en justificacion tecnica (RF16)
@Component
public class JustificacionTecnicaValidator implements ValidadorSolicitud {

    @Override
    public void validar(SolicitudRepuestoRequest request) {
        if (request.getJustificacionTecnica() == null || request.getJustificacionTecnica().trim().length() < 10) {
            throw new BadRequestException("La justificacion tecnica debe contener al menos 10 caracteres reales");
        }
    }
}