package com.masterdrilling.sgsramd.service;

import org.springframework.web.multipart.MultipartFile;

public interface IStorageService {
    String guardarArchivo(MultipartFile archivo, String subCarpeta);
    void eliminarArchivo(String rutaRelativa);
}

