package com.masterdrilling.sgsramd.service.impl;

import com.masterdrilling.sgsramd.exception.BadRequestException;
import com.masterdrilling.sgsramd.service.IStorageService;
import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.*;
import java.util.UUID;

@Service
public class LocalStorageServiceImpl implements IStorageService {

    private static final Logger log = LoggerFactory.getLogger(LocalStorageServiceImpl.class);
    private final Path rootPath = Paths.get("uploads");
    private static final long MAX_FILE_SIZE = 5 * 1024 * 1024; // 5 MB (RF32 Ex3)

    @PostConstruct
    public void inicializar() {
        try {
            Files.createDirectories(rootPath.resolve("repuestos"));
            Files.createDirectories(rootPath.resolve("herramientas"));
            log.info("[STORAGE] Directorios de almacenamiento inicializados en: {}", rootPath.toAbsolutePath());
        } catch (IOException e) {
            log.error("[STORAGE] No se pudo inicializar la carpeta de uploads", e);
        }
    }

    @Override
    public String guardarArchivo(MultipartFile archivo, String subCarpeta) {
        if (archivo == null || archivo.isEmpty()) {
            throw new BadRequestException("El archivo cargado esta vacio o no fue adjuntado.");
        }

        if (archivo.getSize() > MAX_FILE_SIZE) {
            throw new BadRequestException("El archivo supera el limite maximo permitido de 5 MB.");
        }

        String contentType = archivo.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            throw new BadRequestException("Solo se permiten archivos de imagen validos (JPEG, PNG, WEBP).");
        }

        String originalFilename = archivo.getOriginalFilename();
        String extension = "";
        if (originalFilename != null && originalFilename.contains(".")) {
            extension = originalFilename.substring(originalFilename.lastIndexOf(".")).toLowerCase();
        } else {
            extension = ".jpg";
        }

        String nombreArchivo = UUID.randomUUID().toString() + extension;
        Path destinoCarpeta = rootPath.resolve(subCarpeta);

        try {
            if (!Files.exists(destinoCarpeta)) {
                Files.createDirectories(destinoCarpeta);
            }

            Path destinoFinal = destinoCarpeta.resolve(nombreArchivo);
            try (InputStream is = archivo.getInputStream()) {
                Files.copy(is, destinoFinal, StandardCopyOption.REPLACE_EXISTING);
            }

            String urlPublica = "/uploads/" + subCarpeta + "/" + nombreArchivo;
            log.info("[STORAGE] Archivo guardado con exito: {}", urlPublica);
            return urlPublica;
        } catch (IOException e) {
            log.error("[STORAGE] Error de I/O al guardar archivo", e);
            throw new RuntimeException("Error al almacenar el archivo fisico en el servidor", e);
        }
    }

    @Override
    public void eliminarArchivo(String rutaRelativa) {
        if (rutaRelativa == null || !rutaRelativa.startsWith("/uploads/")) {
            return;
        }
        try {
            String pathLimpio = rutaRelativa.replaceFirst("^/uploads/", "");
            Path archivo = rootPath.resolve(pathLimpio);
            Files.deleteIfExists(archivo);
            log.info("[STORAGE] Archivo eliminado: {}", archivo);
        } catch (IOException e) {
            log.warn("[STORAGE] No se pudo eliminar el archivo anterior: {}", rutaRelativa);
        }
    }
}

