package com.masterdrilling.sgsramd.service.strategy;

import com.masterdrilling.sgsramd.util.CsvSanitizerUtil;
import org.springframework.stereotype.Component;

import java.io.ByteArrayInputStream;
import java.nio.charset.StandardCharsets;
import java.util.List;

// Exportador CSV plano con saneamiento de formulas (RF30 / RNF20)
@Component
public class CsvReporteExporter implements IReporteExporter {

    @Override
    public String getTipoFormato() {
        return "CSV";
    }

    @Override
    public ByteArrayInputStream exportarReporte(String titulo, List<String> cabeceras, List<List<String>> filas) {
        StringBuilder csv = new StringBuilder();

        // Cabeceras
        csv.append(String.join(";", cabeceras)).append("\n");

        // Filas saneadas
        for (List<String> fila : filas) {
            for (int i = 0; i < fila.size(); i++) {
                csv.append(CsvSanitizerUtil.sanearTexto(fila.get(i)));
                if (i < fila.size() - 1) {
                    csv.append(";");
                }
            }
            csv.append("\n");
        }

        return new ByteArrayInputStream(csv.toString().getBytes(StandardCharsets.UTF_8));
    }
}