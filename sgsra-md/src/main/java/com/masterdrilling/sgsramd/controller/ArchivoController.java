package com.masterdrilling.sgsramd.controller;

import com.masterdrilling.sgsramd.model.entity.ArchivoAlmacenado;
import com.masterdrilling.sgsramd.service.impl.LocalStorageServiceImpl;
import lombok.RequiredArgsConstructor;
import org.springframework.http.CacheControl;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import java.util.concurrent.TimeUnit;

// [H-GEN-03] Sirve las imagenes publicas "/uploads/{carpeta}/{archivo}" desde PostgreSQL
// (con respaldo al disco local para las imagenes semilla). Reemplaza al ResourceHandler estatico.
@RestController
@RequiredArgsConstructor
public class ArchivoController {

    private final LocalStorageServiceImpl storageService;

    @GetMapping("/uploads/{carpeta}/{archivo:.+}")
    public ResponseEntity<byte[]> obtenerArchivo(@PathVariable String carpeta, @PathVariable String archivo) {
        return storageService.obtenerArchivo(carpeta, archivo)
                .map(this::construirRespuesta)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    private ResponseEntity<byte[]> construirRespuesta(ArchivoAlmacenado a) {
        MediaType tipo;
        try {
            tipo = MediaType.parseMediaType(a.getContentType());
        } catch (Exception e) {
            tipo = MediaType.IMAGE_JPEG;
        }
        // Cada subida genera un nombre UUID nuevo, por lo que el contenido nunca cambia
        return ResponseEntity.ok()
                .contentType(tipo)
                .contentLength(a.getDatos().length)
                .cacheControl(CacheControl.maxAge(30, TimeUnit.DAYS).cachePublic())
                .body(a.getDatos());
    }
}
