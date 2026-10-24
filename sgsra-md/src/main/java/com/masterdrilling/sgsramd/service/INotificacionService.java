package com.masterdrilling.sgsramd.service;

// Contrato desacoplado para despacho reactivo de alertas (RF46, RF47, RF48)
public interface INotificacionService {
    void enviarNotificacion(String destinatario, String titulo, String mensaje);
}