package com.masterdrilling.sgsramd.service.impl;

import com.masterdrilling.sgsramd.DAO.*;
import com.masterdrilling.sgsramd.dto.request.AprobacionParcialRequest;
import com.masterdrilling.sgsramd.dto.request.ContactarProveedorRequest;
import com.masterdrilling.sgsramd.dto.request.DictamenRechazoRequest;
import com.masterdrilling.sgsramd.dto.request.SolicitudRepuestoRequest;
import com.masterdrilling.sgsramd.dto.response.DetalleSolicitudResponse;
import com.masterdrilling.sgsramd.dto.response.MensajeGenericoResponse;
import com.masterdrilling.sgsramd.dto.response.SolicitudResumenResponse;
import com.masterdrilling.sgsramd.exception.BadRequestException;
import com.masterdrilling.sgsramd.exception.RecursoNoEncontradoException;
import com.masterdrilling.sgsramd.model.entity.*;
import com.masterdrilling.sgsramd.model.enums.EstadoItemSolicitud;
import com.masterdrilling.sgsramd.model.enums.EstadoSolicitud;
import com.masterdrilling.sgsramd.service.IAuditoriaService;
import com.masterdrilling.sgsramd.service.INotificacionService;
import com.masterdrilling.sgsramd.service.ISolicitudService;
import com.masterdrilling.sgsramd.service.validator.JustificacionRechazoValidator;
import com.masterdrilling.sgsramd.service.validator.ValidadorSolicitud;
import com.masterdrilling.sgsramd.util.IdGeneratorUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class SolicitudServiceImpl implements ISolicitudService {

    private final Solicitud_DAO solicitudRepository;
    private final Repuesto_DAO repuestoRepository;
    private final Maquinaria_DAO maquinariaRepository;
    private final Mecanico_DAO mecanicoRepository;
    private final Administrador_DAO administradorRepository;
    private final DictamenRechazo_DAO dictamenRepository;
    private final Usuario_DAO usuarioRepository;
    private final IAuditoriaService auditoriaService;
    private final INotificacionService notificacionService;
    private final List<ValidadorSolicitud> validadoresSolicitud;
    private final JustificacionRechazoValidator rechazoValidator;

    @Override
    @Transactional
    public MensajeGenericoResponse registrarSolicitud(String correoMecanico, SolicitudRepuestoRequest request, String ipOrigen) {
        validadoresSolicitud.forEach(v -> v.validar(request));

        Usuario usuario = usuarioRepository.findByCorreoCorporativo(correoMecanico)
                .orElseThrow(() -> new RecursoNoEncontradoException("Usuario no autenticado"));

        Mecanico mecanico = mecanicoRepository.findByDniMecanico(usuario.getDni())
                .orElseThrow(() -> new RecursoNoEncontradoException("Perfil de mecanico no encontrado"));

        Maquinaria maquinaria = maquinariaRepository.findById(request.getCodMaquinaria())
                .orElseThrow(() -> new RecursoNoEncontradoException("Maquinaria no registrada: " + request.getCodMaquinaria()));

        String anio = String.valueOf(LocalDate.now().getYear());
        String ultimoCorrelativo = solicitudRepository.findUltimoCorrelativoPorAnio(anio);
        String nuevoId = IdGeneratorUtil.generarCodigoCorrelativo("SOL", ultimoCorrelativo);

        Solicitud solicitud = Solicitud.builder()
                .solicitudNum(nuevoId)
                .fechaEmision(LocalDate.now())
                .horaEmision(LocalTime.now())
                .prioridadSolicitud(request.getPrioridad())
                .justificacionTecnica(request.getJustificacionTecnica().trim())
                .estadoSolicitud(EstadoSolicitud.PENDIENTE)
                .mecanico(mecanico)
                .maquinaria(maquinaria)
                .detalles(new ArrayList<>())
                .build();

        int itemIdx = 1;
        for (SolicitudRepuestoRequest.ItemRepuestoRequest itemReq : request.getItems()) {
            Repuesto repuesto = repuestoRepository.findByCodParteAndActivoTrue(itemReq.getCodParte())
                    .orElseThrow(() -> new RecursoNoEncontradoException("Repuesto inactivo o no existe: " + itemReq.getCodParte()));

            SolicitudDetalleId detId = new SolicitudDetalleId(nuevoId, itemIdx);
            SolicitudDetalle det = SolicitudDetalle.builder()
                    .id(detId)
                    .solicitud(solicitud)
                    .repuesto(repuesto)
                    .cantidadRepuesto(itemReq.getCantidad())
                    .estadoItem(EstadoItemSolicitud.PENDIENTE)
                    .build();

            solicitud.getDetalles().add(det);
            itemIdx++;
        }

        solicitudRepository.save(solicitud);
        auditoriaService.registrarAsiento(nuevoId, usuario.getIdUsuario(), "SOLICITUD_CREADA", ipOrigen);
        notificacionService.enviarNotificacion("ADMINISTRACION", "Nueva Solicitud", "Solicitud " + nuevoId + " ingresada por mecanico");

        return MensajeGenericoResponse.builder()
                .exito(true)
                .mensaje("Solicitud " + nuevoId + " enviada con exito")
                .dato(nuevoId)
                .build();
    }

    @Override
    @Transactional(readOnly = true)
    public Page<SolicitudResumenResponse> listarHistorialMecanico(String correoMecanico, Pageable pageable) {
        Usuario usuario = usuarioRepository.findByCorreoCorporativo(correoMecanico)
                .orElseThrow(() -> new RecursoNoEncontradoException("Usuario no encontrado"));

        return solicitudRepository.findByMecanicoDniMecanicoOrderByFechaEmisionDescHoraEmisionDesc(usuario.getDni(), pageable)
                .map(this::mapearAResumen);
    }

    @Override
    @Transactional(readOnly = true)
    public List<SolicitudResumenResponse> listarBandejaAdministrador(EstadoSolicitud estado) {
        if (estado != null) {
            return solicitudRepository.findByEstadoSolicitudOrderByFechaEmisionDescHoraEmisionDesc(estado)
                    .stream().map(this::mapearAResumen).toList();
        }
        return solicitudRepository.findAll()
                .stream().map(this::mapearAResumen).toList();
    }

    @Override
    @Transactional(readOnly = true)
    public DetalleSolicitudResponse obtenerDetalleSolicitud(String solicitudNum) {
        Solicitud s = solicitudRepository.findById(solicitudNum)
                .orElseThrow(() -> new RecursoNoEncontradoException("Solicitud no encontrada: " + solicitudNum));

        List<DetalleSolicitudResponse.ItemDetalleResponse> items = s.getDetalles().stream()
                .map(d -> DetalleSolicitudResponse.ItemDetalleResponse.builder()
                        .item(d.getId().getItem())
                        .codParte(d.getRepuesto().getCodParte())
                        .nombreRepuesto(d.getRepuesto().getNombreRepuesto())
                        .cantidadSolicitada(d.getCantidadRepuesto())
                        .estadoItem(d.getEstadoItem())
                        .build())
                .toList();

        DetalleSolicitudResponse.DictamenRechazoResponse rechazoDto = null;
        var optDictamen = dictamenRepository.findBySolicitudSolicitudNum(s.getSolicitudNum());
        if (optDictamen.isPresent()) {
            DictamenRechazo d = optDictamen.get();
            rechazoDto = DetalleSolicitudResponse.DictamenRechazoResponse.builder()
                    .dictamenNum(d.getDictamenNum())
                    .fechaEvaluacion(d.getFechaEvaluacion())
                    .justificacionRechazo(d.getJustificacionRechazo())
                    .evaluador(d.getAdministrador().getNombreAdministrador())
                    .build();
        }

        return DetalleSolicitudResponse.builder()
                .solicitudNum(s.getSolicitudNum())
                .fechaEmision(s.getFechaEmision())
                .horaEmision(s.getHoraEmision())
                .prioridad(s.getPrioridadSolicitud())
                .estado(s.getEstadoSolicitud())
                .justificacionTecnica(s.getJustificacionTecnica())
                .codMaquinaria(s.getMaquinaria().getCodMaquinaria())
                .modeloMaquinaria(s.getMaquinaria().getModeloMaquinaria())
                .serieMaquinaria(s.getMaquinaria().getSerieFabricante())
                .dniMecanico(s.getMecanico().getDniMecanico())
                .nombreMecanico(s.getMecanico().getNombreMecanico())
                .telefonoMecanico(s.getMecanico().getTelefono())
                .repuestos(items)
                .rechazo(rechazoDto)
                .build();
    }

    @Override
    @Transactional
    public MensajeGenericoResponse aprobarSolicitudTotal(String solicitudNum, String correoAdmin, String ipOrigen) {
        Solicitud s = solicitudRepository.findById(solicitudNum)
                .orElseThrow(() -> new RecursoNoEncontradoException("Solicitud no encontrada"));

        if (s.getEstadoSolicitud() != EstadoSolicitud.PENDIENTE) {
            throw new BadRequestException("La solicitud ya fue procesada anteriormente");
        }

        Usuario adminUsuario = usuarioRepository.findByCorreoCorporativo(correoAdmin)
                .orElseThrow(() -> new RecursoNoEncontradoException("Usuario evaluador no registrado"));

        s.setEstadoSolicitud(EstadoSolicitud.APROBADA);
        s.getDetalles().forEach(d -> d.setEstadoItem(EstadoItemSolicitud.APROBADO));
        solicitudRepository.save(s);

        auditoriaService.registrarAsiento(s.getSolicitudNum(), adminUsuario.getIdUsuario(), "SOLICITUD_APROBADA_TOTAL", ipOrigen);
        notificacionService.enviarNotificacion(s.getMecanico().getDniMecanico(), "Solicitud Aprobada", "La orden " + s.getSolicitudNum() + " fue autorizada");

        return MensajeGenericoResponse.builder().exito(true).mensaje("Solicitud aprobada integramente").dato(s.getSolicitudNum()).build();
    }

    @Override
    @Transactional
    public MensajeGenericoResponse rechazarSolicitudTotal(String solicitudNum, String correoAdmin, DictamenRechazoRequest request, String ipOrigen) {
        rechazoValidator.validarMotivoRechazo(request.getJustificacionRechazo());

        Solicitud s = solicitudRepository.findById(solicitudNum)
                .orElseThrow(() -> new RecursoNoEncontradoException("Solicitud no encontrada"));

        Usuario usuario = usuarioRepository.findByCorreoCorporativo(correoAdmin)
                .orElseThrow(() -> new RecursoNoEncontradoException("Administrador no encontrado"));

        Administrador admin = administradorRepository.findByDniAdministrador(usuario.getDni())
                .orElseThrow(() -> new RecursoNoEncontradoException("Ficha administrativa no existe"));

        s.setEstadoSolicitud(EstadoSolicitud.RECHAZADA);
        s.getDetalles().forEach(d -> d.setEstadoItem(EstadoItemSolicitud.RECHAZADO));
        solicitudRepository.save(s);

        String dictamenId = "DIC-" + s.getSolicitudNum();
        DictamenRechazo dictamen = DictamenRechazo.builder()
                .dictamenNum(dictamenId)
                .solicitud(s)
                .fechaEvaluacion(LocalDate.now())
                .justificacionRechazo(request.getJustificacionRechazo().trim())
                .administrador(admin)
                .detallesRechazo(new ArrayList<>())
                .build();

        int itemIdx = 1;
        for (SolicitudDetalle det : s.getDetalles()) {
            DetalleRechazo dr = DetalleRechazo.builder()
                    .id(new DetalleRechazoId(dictamenId, itemIdx++))
                    .dictamenRechazo(dictamen)
                    .repuesto(det.getRepuesto())
                    .cantidadRechazada(det.getCantidadRepuesto())
                    .motivoEspecificoItem(request.getJustificacionRechazo().trim())
                    .build();
            dictamen.getDetallesRechazo().add(dr);
        }

        dictamenRepository.save(dictamen);
        auditoriaService.registrarAsiento(s.getSolicitudNum(), usuario.getIdUsuario(), "SOLICITUD_RECHAZADA_TOTAL", ipOrigen);
        notificacionService.enviarNotificacion(s.getMecanico().getDniMecanico(), "Solicitud Rechazada", "La orden " + s.getSolicitudNum() + " fue denegada");

        return MensajeGenericoResponse.builder().exito(true).mensaje("Solicitud rechazada formalmente").dato(s.getSolicitudNum()).build();
    }

    @Override
    @Transactional
    public MensajeGenericoResponse aprobarSolicitudParcial(String solicitudNum, String correoAdmin, AprobacionParcialRequest request, String ipOrigen) {
        Solicitud s = solicitudRepository.findById(solicitudNum)
                .orElseThrow(() -> new RecursoNoEncontradoException("Solicitud no encontrada"));

        Usuario adminUsuario = usuarioRepository.findByCorreoCorporativo(correoAdmin)
                .orElseThrow(() -> new RecursoNoEncontradoException("Usuario evaluador no registrado"));

        boolean existenAprobados = false;
        boolean existenRechazados = false;

        for (AprobacionParcialRequest.ItemAprobacionParcialRequest itemReq : request.getItems()) {
            SolicitudDetalle det = s.getDetalles().stream()
                    .filter(d -> d.getId().getItem().equals(itemReq.getItem()))
                    .findFirst()
                    .orElseThrow(() -> new BadRequestException("Item no coincide con la orden: " + itemReq.getItem()));

            if (Boolean.TRUE.equals(itemReq.getAprobado())) {
                det.setEstadoItem(EstadoItemSolicitud.APROBADO);
                existenAprobados = true;
            } else {
                det.setEstadoItem(EstadoItemSolicitud.RECHAZADO);
                existenRechazados = true;
                if (itemReq.getMotivoRechazoItem() == null || itemReq.getMotivoRechazoItem().isBlank()) {
                    throw new BadRequestException("Debe ingresar la causa tecnica para el componente rechazado item " + itemReq.getItem());
                }
            }
        }

        if (existenAprobados && existenRechazados) {
            s.setEstadoSolicitud(EstadoSolicitud.APROBADA_PARCIAL);
        } else if (existenAprobados) {
            s.setEstadoSolicitud(EstadoSolicitud.APROBADA);
        } else {
            s.setEstadoSolicitud(EstadoSolicitud.RECHAZADA);
        }

        solicitudRepository.save(s);
        auditoriaService.registrarAsiento(s.getSolicitudNum(), adminUsuario.getIdUsuario(), "SOLICITUD_APROBADA_PARCIAL", ipOrigen);
        notificacionService.enviarNotificacion(s.getMecanico().getDniMecanico(), "Resolucion Mixta", "Orden " + s.getSolicitudNum() + " resuelta parcialmente");

        return MensajeGenericoResponse.builder().exito(true).mensaje("Dictamen parcial aplicado").dato(s.getSolicitudNum()).build();
    }

    @Override
    @Transactional
    public MensajeGenericoResponse marcarOrdenContactada(String solicitudNum, String correoAdmin, ContactarProveedorRequest request, String ipOrigen) {
        Solicitud s = solicitudRepository.findById(solicitudNum)
                .orElseThrow(() -> new RecursoNoEncontradoException("Solicitud no encontrada"));

        if (s.getEstadoSolicitud() != EstadoSolicitud.APROBADA && s.getEstadoSolicitud() != EstadoSolicitud.APROBADA_PARCIAL) {
            throw new BadRequestException("Solo se pueden contactar ordenes aprobadas previamente");
        }

        Usuario adminUsuario = usuarioRepository.findByCorreoCorporativo(correoAdmin)
                .orElseThrow(() -> new RecursoNoEncontradoException("Usuario no registrado"));

        s.setEstadoSolicitud(EstadoSolicitud.ORDEN_CONTACTADA);
        solicitudRepository.save(s);
        auditoriaService.registrarAsiento(s.getSolicitudNum(), adminUsuario.getIdUsuario(), "ORDEN_CONTACTADA_PROVEEDOR", ipOrigen);

        return MensajeGenericoResponse.builder().exito(true).mensaje("Orden marcada como contactada").dato(s.getSolicitudNum()).build();
    }

    private SolicitudResumenResponse mapearAResumen(Solicitud s) {
        return SolicitudResumenResponse.builder()
                .solicitudNum(s.getSolicitudNum())
                .fechaEmision(s.getFechaEmision())
                .horaEmision(s.getHoraEmision())
                .prioridad(s.getPrioridadSolicitud())
                .estado(s.getEstadoSolicitud())
                .codMaquinaria(s.getMaquinaria().getCodMaquinaria())
                .modeloMaquinaria(s.getMaquinaria().getModeloMaquinaria())
                .nombreMecanico(s.getMecanico().getNombreMecanico())
                .totalComponentes(s.getDetalles().size())
                .build();
    }
}