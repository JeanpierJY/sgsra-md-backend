package com.masterdrilling.sgsramd.service.validator;

import com.masterdrilling.sgsramd.exception.BadRequestException;
import org.springframework.stereotype.Component;

// Valida obligatoriedad y longitud minima de 15 caracteres en motivos de denegacion (RF25)
@Component
public class JustificacionRechazoValidator {

    public void validarMotivoRechazo(String motivo) {
        if (motivo == null || motivo.trim().length() < 15) {
            throw new BadRequestException("El motivo de rechazo administrativo debe contener al menos 15 caracteres explicativos");
        }
    }
}