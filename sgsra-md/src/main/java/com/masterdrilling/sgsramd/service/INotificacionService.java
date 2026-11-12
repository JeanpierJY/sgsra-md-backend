package com.masterdrilling.sgsramd.service;

import com.masterdrilling.sgsramd.dto.response.MensajeGenericoResponse;
import com.masterdrilling.sgsramd.dto.response.NotificacionResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;

public interface INotificacionService {
    void enviarNotificacion(String destinatario, String titulo, String mensaje);
    void enviarNotificacionConTipo(String dniDestinatario, String rolDestinatario, String titulo, String mensaje, String tipoAlerta);
    List<NotificacionResponse> listarPorUsuario(String dni);
    Page<NotificacionResponse> listarPorUsuarioPaginado(String dni, Pageable pageable);
    long contarNoLeidas(String dni);
    MensajeGenericoResponse marcarComoLeida(Long idNotificacion);
    MensajeGenericoResponse marcarTodasComoLeidas(String dni);
}
