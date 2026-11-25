package com.masterdrilling.sgsramd.service.impl;

import com.masterdrilling.sgsramd.DAO.ArchivoAlmacenado_DAO;
import com.masterdrilling.sgsramd.exception.BadRequestException;
import com.masterdrilling.sgsramd.model.entity.ArchivoAlmacenado;
import com.masterdrilling.sgsramd.service.IStorageService;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

// [H-GEN-03] Almacenamiento de imagenes en PostgreSQL (tabla archivo_almacenado).
// Antes se escribia en el disco local "uploads/", que en Render es efimero y ademas
// se exponia con una ruta "file:/" invalida en Linux, por lo que las fotos no cargaban.
// Las URLs publicas se mantienen con el formato "/uploads/{carpeta}/{archivo}".
@Service
@RequiredArgsConstructor
public class LocalStorageServiceImpl implements IStorageService {

    private static final Logger log = LoggerFactory.getLogger(LocalStorageServiceImpl.class);
    private static final long MAX_FILE_SIZE = 5 * 1024 * 1024; // 5 MB (RF32 Ex3)
    private static final Set<String> EXTENSIONES = Set.of(".jpg", ".jpeg", ".png", ".webp", ".gif");
    private static final Path ROOT_PATH = Paths.get("uploads").toAbsolutePath().normalize();

    private final ArchivoAlmacenado_DAO archivoDao;

    @Override
    @Transactional
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

        String extension = ".jpg";
        String originalFilename = archivo.getOriginalFilename();
        if (originalFilename != null && originalFilename.contains(".")) {
            String ext = originalFilename.substring(originalFilename.lastIndexOf(".")).toLowerCase();
            if (EXTENSIONES.contains(ext)) {
                extension = ext;
            }
        }

        String ruta = subCarpeta + "/" + UUID.randomUUID() + extension;
        try {
            byte[] datos = archivo.getBytes();
            archivoDao.save(ArchivoAlmacenado.builder()
                    .ruta(ruta)
                    .contentType(contentType)
                    .datos(datos)
                    .tamanoBytes((long) datos.length)
                    .build());
        } catch (IOException e) {
            log.error("[STORAGE] Error de lectura del archivo subido", e);
            throw new BadRequestException("No se pudo leer la imagen enviada. Intente nuevamente.");
        }

        String urlPublica = "/uploads/" + ruta;
        log.info("[STORAGE] Imagen guardada en base de datos: {}", urlPublica);
        return urlPublica;
    }

    @Override
    @Transactional
    public void eliminarArchivo(String rutaRelativa) {
        if (rutaRelativa == null || !rutaRelativa.startsWith("/uploads/")) {
            return;
        }
        String ruta = rutaRelativa.replaceFirst("^/uploads/", "");
        if (archivoDao.existsById(ruta)) {
            archivoDao.deleteById(ruta);
            log.info("[STORAGE] Imagen eliminada de base de datos: {}", rutaRelativa);
        }
    }

    // Busca la imagen en BD; si no existe, intenta el disco local (imagenes semilla del repositorio)
    @Transactional(readOnly = true)
    public Optional<ArchivoAlmacenado> obtenerArchivo(String carpeta, String nombre) {
        String ruta = carpeta + "/" + nombre;
        Optional<ArchivoAlmacenado> enBd = archivoDao.findById(ruta);
        if (enBd.isPresent()) {
            return enBd;
        }

        Path archivo = ROOT_PATH.resolve(carpeta).resolve(nombre).normalize();
        if (!archivo.startsWith(ROOT_PATH) || !Files.isRegularFile(archivo)) {
            return Optional.empty();
        }
        try {
            byte[] datos = Files.readAllBytes(archivo);
            String tipo = Files.probeContentType(archivo);
            return Optional.of(ArchivoAlmacenado.builder()
                    .ruta(ruta)
                    .contentType(tipo != null ? tipo : "image/jpeg")
                    .datos(datos)
                    .tamanoBytes((long) datos.length)
                    .build());
        } catch (IOException e) {
            log.warn("[STORAGE] No se pudo leer el archivo local {}", archivo);
            return Optional.empty();
        }
    }
}
