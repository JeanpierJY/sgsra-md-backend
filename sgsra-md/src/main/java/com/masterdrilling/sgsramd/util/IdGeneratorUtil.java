package com.masterdrilling.sgsramd.util;

import java.time.LocalDate;

// Utilidad para generacion atomica de codigos correlativos formales (SOL-2026-XXXX, etc.)
public final class IdGeneratorUtil {

    private IdGeneratorUtil() {
    }

    public static String generarCodigoCorrelativo(String prefijo, String ultimoCorrelativo) {
        int anioActual = LocalDate.now().getYear();
        int siguienteNumero = 1;

        if (ultimoCorrelativo != null && !ultimoCorrelativo.isBlank()) {
            String[] partes = ultimoCorrelativo.split("-");
            if (partes.length == 3) {
                try {
                    siguienteNumero = Integer.parseInt(partes[2]) + 1;
                } catch (NumberFormatException ignored) {
                    siguienteNumero = 1;
                }
            }
        }
        return String.format("%s-%d-%04d", prefijo, anioActual, siguienteNumero);
    }
}