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

    private record RolInfo(String dni, String rol) {}

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
            rol = usuarioRepository.findByDni(dni)
                    .map(Usuario::getRol)
                    .map(Enum::name)
                    .orElse(null);
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
        String tipoNormalizado = normalizarTipoAlerta(tipoAlerta);
        log.info("[ALERTA PERSISTIDA] DNI: {} | Rol: {} | Titulo: {} | Tipo: {} (BD: {})",
                dniDestinatario, rolDestinatario, titulo, tipoAlerta, tipoNormalizado);
        Notificacion notificacion = Notificacion.builder()
                .dniDestinatario(dniDestinatario)
                .rolDestinatario(rolDestinatario)
                .titulo(titulo)
                .mensaje(mensaje)
                .tipoAlerta(tipoNormalizado)
                .leida(false)
                .fechaCreacion(LocalDateTime.now())
                .build();
        notificacionRepository.save(notificacion);
    }

    /**
     * Mapea el tipo de alerta a los valores estrictos del check constraint en PostgreSQL:
     * ('INFO', 'SOLICITUD', 'APROBACION', 'RECHAZO', 'MORA', 'EXTRAVIO', 'STOCK_MINIMO')
     */
    private String normalizarTipoAlerta(String tipoAlerta) {
        if (tipoAlerta == null || tipoAlerta.isBlank()) {
            return "INFO";
        }
        String upper = tipoAlerta.trim().toUpperCase();
        return switch (upper) {
            case "SOLICITUD", "PRIORIDAD_ALTA", "NUEVA_SOLICITUD" -> "SOLICITUD";
            case "APROBACION", "SOLICITUD_APROBADA", "SOLICITUD_APROBADA_PARCIAL", "DESPACHO_URGENTE", "ENTREGA" -> "APROBACION";
            case "RECHAZO", "SOLICITUD_RECHAZADA" -> "RECHAZO";
            case "MORA", "ALERTA_PREVENTIVA", "PREVENTIVA" -> "MORA";
            case "EXTRAVIO" -> "EXTRAVIO";
            case "STOCK_MINIMO", "STOCK_CRITICO" -> "STOCK_MINIMO";
            default -> "INFO"; // Cubre RECUPERACION_CLAVE, DESBLOQUEO, INFO, SEGURIDAD
        };
    }

    @Override
    @Transactional(readOnly = true)
    public List<NotificacionResponse> listarPorUsuario(String dni) {
        RolInfo info = resolverDestinatario(dni);
        return notificacionRepository.listarPorDestinatario(info.dni(), info.rol()).stream()
                .map(this::mapearADto)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public Page<NotificacionResponse> listarPorUsuarioPaginado(String dni, Pageable pageable) {
        RolInfo info = resolverDestinatario(dni);
        return notificacionRepository.listarPorDestinatarioPaginado(info.dni(), info.rol(), pageable)
                .map(this::mapearADto);
    }

    @Override
    @Transactional(readOnly = true)
    public long contarNoLeidas(String dni) {
        RolInfo info = resolverDestinatario(dni);
        return notificacionRepository.contarNoLeidas(info.dni(), info.rol());
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
        RolInfo info = resolverDestinatario(dni);
        notificacionRepository.marcarTodasComoLeidas(info.dni(), info.rol());
        return MensajeGenericoResponse.builder()
                .exito(true)
                .mensaje("Todas las notificaciones fueron marcadas como leidas")
                .dato(dni)
                .build();
    }

    private RolInfo resolverDestinatario(String identificador) {
        if (identificador == null || identificador.trim().isEmpty()) {
            return new RolInfo(null, null);
        }
        String clean = identificador.trim();
        if ("ADMINISTRACION".equalsIgnoreCase(clean) || "ADMINISTRADOR".equalsIgnoreCase(clean)) {
            return new RolInfo(null, "ADMINISTRADOR");
        }
        if ("ALMACEN".equalsIgnoreCase(clean) || "ALMACENISTA".equalsIgnoreCase(clean)) {
            return new RolInfo(null, "ALMACENISTA");
        }
        if ("MECANICO".equalsIgnoreCase(clean)) {
            return new RolInfo(null, "MECANICO");
        }
        if ("TODOS".equalsIgnoreCase(clean)) {
            return new RolInfo(null, "TODOS");
        }
        String rol = usuarioRepository.findByDni(clean)
                .map(Usuario::getRol)
                .map(Enum::name)
                .orElse(null);
        return new RolInfo(clean, rol);
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
