package com.masterdrilling.sgsramd.service.impl;

import com.masterdrilling.sgsramd.DAO.Notificacion_DAO;
import com.masterdrilling.sgsramd.DAO.Usuario_DAO;
import com.masterdrilling.sgsramd.dto.response.MensajeGenericoResponse;
import com.masterdrilling.sgsramd.dto.response.NotificacionResponse;
import com.masterdrilling.sgsramd.exception.RecursoNoEncontradoException;
import com.masterdrilling.sgsramd.model.entity.Notificacion;
import com.masterdrilling.sgsramd.model.entity.Usuario;
import com.masterdrilling.sgsramd.service.INotificacionService;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class FirebaseNotificacionServiceImpl implements INotificacionService {

    private static final Logger log = LoggerFactory.getLogger(FirebaseNotificacionServiceImpl.class);
    private final Notificacion_DAO notificacionRepository;
    private final Usuario_DAO usuarioRepository;

    @Override
    @Transactional
    public void enviarNotificacion(String destinatario, String titulo, String mensaje) {
        log.info("[ALERTA PUSH/DB] Destinatario: {} | Titulo: {} | Mensaje: {}", destinatario, titulo, mensaje);
        
        String dni = null;
        String rol = null;
        if ("ADMINISTRACION".equalsIgnoreCase(destinatario) || "ADMINISTRADOR".equalsIgnoreCase(destinatario)) {
            rol = "ADMINISTRADOR";
        } else if ("ALMACEN".equalsIgnoreCase(destinatario) || "ALMACENISTA".equalsIgnoreCase(destinatario)) {
            rol = "ALMACENISTA";
        } else if ("MECANICO".equalsIgnoreCase(destinatario)) {
            rol = "MECANICO";
        } else if ("TODOS".equalsIgnoreCase(destinatario)) {
            rol = "TODOS";
        } else {
            dni = destinatario;
        }

        Notificacion notificacion = Notificacion.builder()
                .dniDestinatario(dni)
                .rolDestinatario(rol)
                .titulo(titulo)
                .mensaje(mensaje)
                .tipoAlerta("INFO")
                .leida(false)
                .fechaCreacion(LocalDateTime.now())
                .build();
        notificacionRepository.save(notificacion);
    }

    @Override
    @Transactional
    public void enviarNotificacionConTipo(String dniDestinatario, String rolDestinatario, String titulo, String mensaje, String tipoAlerta) {
        log.info("[ALERTA PERSISTIDA] DNI: {} | Rol: {} | Titulo: {} | Tipo: {}", dniDestinatario, rolDestinatario, titulo, tipoAlerta);
        Notificacion notificacion = Notificacion.builder()
                .dniDestinatario(dniDestinatario)
                .rolDestinatario(rolDestinatario)
                .titulo(titulo)
                .mensaje(mensaje)
                .tipoAlerta(tipoAlerta != null ? tipoAlerta : "INFO")
                .leida(false)
                .fechaCreacion(LocalDateTime.now())
                .build();
        notificacionRepository.save(notificacion);
    }

    @Override
    @Transactional(readOnly = true)
    public List<NotificacionResponse> listarPorUsuario(String dni) {
        String rol = obtenerRolPorDni(dni);
        return notificacionRepository.listarPorDestinatario(dni, rol).stream()
                .map(this::mapearADto)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public Page<NotificacionResponse> listarPorUsuarioPaginado(String dni, Pageable pageable) {
        String rol = obtenerRolPorDni(dni);
        return notificacionRepository.listarPorDestinatarioPaginado(dni, rol, pageable)
                .map(this::mapearADto);
    }

    @Override
    @Transactional(readOnly = true)
    public long contarNoLeidas(String dni) {
        String rol = obtenerRolPorDni(dni);
        return notificacionRepository.contarNoLeidas(dni, rol);
    }

    @Override
    @Transactional
    public MensajeGenericoResponse marcarComoLeida(Long idNotificacion) {
        Notificacion notif = notificacionRepository.findById(idNotificacion)
                .orElseThrow(() -> new RecursoNoEncontradoException("Notificacion no encontrada con ID: " + idNotificacion));
        notif.setLeida(true);
        notificacionRepository.save(notif);
        return MensajeGenericoResponse.builder()
                .exito(true)
                .mensaje("Notificacion marcada como leida")
                .dato(idNotificacion)
                .build();
    }

    @Override
    @Transactional
    public MensajeGenericoResponse marcarTodasComoLeidas(String dni) {
        String rol = obtenerRolPorDni(dni);
        notificacionRepository.marcarTodasComoLeidas(dni, rol);
        return MensajeGenericoResponse.builder()
                .exito(true)
                .mensaje("Todas las notificaciones fueron marcadas como leidas")
                .dato(dni)
                .build();
    }

    private String obtenerRolPorDni(String dni) {
        if (dni == null || dni.trim().isEmpty()) return "TODOS";
        return usuarioRepository.findByDni(dni.trim())
                .map(Usuario::getRol)
                .map(Enum::name)
                .orElse("TODOS");
    }

    private NotificacionResponse mapearADto(Notificacion n) {
        return NotificacionResponse.builder()
                .idNotificacion(n.getIdNotificacion())
                .dniDestinatario(n.getDniDestinatario())
                .rolDestinatario(n.getRolDestinatario())
                .titulo(n.getTitulo())
                .mensaje(n.getMensaje())
                .tipoAlerta(n.getTipoAlerta())
                .leida(n.getLeida())
                .fechaCreacion(n.getFechaCreacion())
                .build();
    }
}
