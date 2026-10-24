package com.masterdrilling.sgsramd.exception;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.time.LocalDateTime;
import java.util.List;

// Interceptor centralizado de excepciones (MVC / REST)
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(RecursoNoEncontradoException.class)
    public ResponseEntity<ErrorDetalle> manejarRecursoNoEncontrado(RecursoNoEncontradoException ex, HttpServletRequest req) {
        ErrorDetalle error = ErrorDetalle.builder()
                .timestamp(LocalDateTime.now())
                .codigoEstado(HttpStatus.NOT_FOUND.value())
                .error("Recurso no encontrado")
                .mensaje(ex.getMessage())
                .ruta(req.getRequestURI())
                .build();
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
    }

    @ExceptionHandler(BadRequestException.class)
    public ResponseEntity<ErrorDetalle> manejarBadRequest(BadRequestException ex, HttpServletRequest req) {
        ErrorDetalle error = ErrorDetalle.builder()
                .timestamp(LocalDateTime.now())
                .codigoEstado(HttpStatus.BAD_REQUEST.value())
                .error("Peticion invalida")
                .mensaje(ex.getMessage())
                .ruta(req.getRequestURI())
                .build();
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
    }

    @ExceptionHandler(AccesoDenegadoException.class)
    public ResponseEntity<ErrorDetalle> manejarAccesoDenegado(AccesoDenegadoException ex, HttpServletRequest req) {
        ErrorDetalle error = ErrorDetalle.builder()
                .timestamp(LocalDateTime.now())
                .codigoEstado(HttpStatus.FORBIDDEN.value())
                .error("Acceso denegado")
                .mensaje(ex.getMessage())
                .ruta(req.getRequestURI())
                .build();
        return ResponseEntity.status(HttpStatus.FORBIDDEN).body(error);
    }

    @ExceptionHandler(CuentaBloqueadaException.class)
    public ResponseEntity<ErrorDetalle> manejarCuentaBloqueada(CuentaBloqueadaException ex, HttpServletRequest req) {
        ErrorDetalle error = ErrorDetalle.builder()
                .timestamp(LocalDateTime.now())
                .codigoEstado(HttpStatus.LOCKED.value())
                .error("Cuenta bloqueada temporalmente")
                .mensaje(ex.getMessage())
                .ruta(req.getRequestURI())
                .build();
        return ResponseEntity.status(HttpStatus.LOCKED).body(error);
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorDetalle> manejarValidacionCampos(MethodArgumentNotValidException ex, HttpServletRequest req) {
        List<String> errores = ex.getBindingResult().getFieldErrors().stream()
                .map(FieldError::getDefaultMessage)
                .toList();

        ErrorDetalle error = ErrorDetalle.builder()
                .timestamp(LocalDateTime.now())
                .codigoEstado(HttpStatus.BAD_REQUEST.value())
                .error("Error de validacion de campos")
                .mensaje("Existen campos obligatorios invalidos o vacios")
                .ruta(req.getRequestURI())
                .erroresValidacion(errores)
                .build();
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorDetalle> manejarErrorGeneral(Exception ex, HttpServletRequest req) {
        ErrorDetalle error = ErrorDetalle.builder()
                .timestamp(LocalDateTime.now())
                .codigoEstado(HttpStatus.INTERNAL_SERVER_ERROR.value())
                .error("Error interno del servidor")
                .mensaje(ex.getMessage())
                .ruta(req.getRequestURI())
                .build();
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
    }
}