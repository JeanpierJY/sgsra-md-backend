package com.masterdrilling.sgsramd.util;

import org.apache.commons.lang3.StringUtils;

// Saneamiento de cadenas contra inyeccion de formulas CSV/Excel (RF30 / Silabo U3)
public final class CsvSanitizerUtil {

    private CsvSanitizerUtil() {
    }

    public static String sanearTexto(String valor) {
        if (StringUtils.isBlank(valor)) {
            return "";
        }
        String limpio = valor.trim();
        // Si inicia con caracteres de formula de hojas de calculo, antepone apostrofe
        if (limpio.startsWith("=") || limpio.startsWith("+") || limpio.startsWith("-") || limpio.startsWith("@")) {
            return "'" + limpio;
        }
        return limpio;
    }
}