package com.masterdrilling.sgsramd.service.impl;

import com.masterdrilling.sgsramd.service.INotificacionService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

// Implementacion con registro seguro mediante Logback (RNF39 / Silabo U3)
@Service
public class FirebaseNotificacionServiceImpl implements INotificacionService {

    private static final Logger log = LoggerFactory.getLogger(FirebaseNotificacionServiceImpl.class);

    @Override
    public void enviarNotificacion(String destinatario, String titulo, String mensaje) {
        log.info("[ALERTA PUSH DESPACHADA] Destinatario: {} | Titulo: {} | Mensaje: {}", destinatario, titulo, mensaje);
    }
}