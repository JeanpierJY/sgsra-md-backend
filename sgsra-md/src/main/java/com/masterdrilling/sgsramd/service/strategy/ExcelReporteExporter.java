package com.masterdrilling.sgsramd.service.strategy;

import com.masterdrilling.sgsramd.exception.BadRequestException;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Component;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.List;

// Exportador nativo a Microsoft Excel utilizando Apache POI (RF30 / Silabo U3)
@Component
public class ExcelReporteExporter implements IReporteExporter {

    @Override
    public String getTipoFormato() {
        return "EXCEL";
    }

    @Override
    public ByteArrayInputStream exportarReporte(String titulo, List<String> cabeceras, List<List<String>> filas) {
        try (Workbook workbook = new XSSFWorkbook(); ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            Sheet sheet = workbook.createSheet(titulo);

            // Estilo para encabezados
            Font headerFont = workbook.createFont();
            headerFont.setBold(true);
            headerFont.setColor(IndexedColors.WHITE.getIndex());

            CellStyle headerCellStyle = workbook.createCellStyle();
            headerCellStyle.setFont(headerFont);
            headerCellStyle.setFillForegroundColor(IndexedColors.DARK_BLUE.getIndex());
            headerCellStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);

            // Creacion de fila de encabezados
            Row headerRow = sheet.createRow(0);
            for (int col = 0; col < cabeceras.size(); col++) {
                Cell cell = headerRow.createCell(col);
                cell.setCellValue(cabeceras.get(col));
                cell.setCellStyle(headerCellStyle);
            }

            // Llenado de filas de datos
            int rowIdx = 1;
            for (List<String> fila : filas) {
                Row row = sheet.createRow(rowIdx++);
                for (int col = 0; col < fila.size(); col++) {
                    row.createCell(col).setCellValue(fila.get(col));
                }
            }

            for (int col = 0; col < cabeceras.size(); col++) {
                sheet.autoSizeColumn(col);
            }

            workbook.write(out);
            return new ByteArrayInputStream(out.toByteArray());
        } catch (IOException e) {
            throw new BadRequestException("Fallo al compilar archivo Excel mediante Apache POI: " + e.getMessage());
        }
    }
}