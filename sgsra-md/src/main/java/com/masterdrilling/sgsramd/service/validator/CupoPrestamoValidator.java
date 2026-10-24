package com.masterdrilling.sgsramd.service.validator;

import com.masterdrilling.sgsramd.exception.BadRequestException;
import com.masterdrilling.sgsramd.repository.PrestamoRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

// Valida que el operario no supere el maximo de 5 herramientas prestadas simultaneas (RF36)
@Component
@RequiredArgsConstructor
public class CupoPrestamoValidator {

    private final PrestamoRepository prestamoRepository;
    private static final int LIMITE_MAXIMO_HERRAMIENTAS = 5;

    public void validarCupoDisponible(String dniMecanico, int cantidadNuevasHerramientas) {
        long activas = prestamoRepository.contarHerramientasActivasPorMecanico(dniMecanico);
        if (activas + cantidadNuevasHerramientas > LIMITE_MAXIMO_HERRAMIENTAS) {
            throw new BadRequestException("Limite alcanzado: El mecanico posee " + activas + 
                    " herramientas activas. No puede exceder el cupo de " + LIMITE_MAXIMO_HERRAMIENTAS);
        }
    }

    public void validarAusenciaDeMoras(String dniMecanico) {
        long enMora = prestamoRepository.contarPrestamosEnMoraPorMecanico(dniMecanico);
        if (enMora > 0) {
            throw new BadRequestException("Bloqueo preventivo: El mecanico registra prestamos con tiempo vencido sin regularizar");
        }
    }
}