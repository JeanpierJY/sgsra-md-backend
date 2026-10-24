package com.masterdrilling.sgsramd.exception;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

// Esquema uniforme para respuestas de error de la API REST
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ErrorDetalle {
    private LocalDateTime timestamp;
    private int codigoEstado;
    private String error;
    private String mensaje;
    private String ruta;
    private List<String> erroresValidacion;
}