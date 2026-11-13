package com.masterdrilling.sgsramd.service.impl;

import com.masterdrilling.sgsramd.DAO.*;
import com.masterdrilling.sgsramd.dto.request.DevolucionHerramientaRequest;
import com.masterdrilling.sgsramd.dto.request.RegistrarPrestamoRequest;
import com.masterdrilling.sgsramd.dto.request.ReporteExtravioRequest;
import com.masterdrilling.sgsramd.dto.response.MensajeGenericoResponse;
import com.masterdrilling.sgsramd.dto.response.PrestamoResumenResponse;
import com.masterdrilling.sgsramd.exception.BadRequestException;
import com.masterdrilling.sgsramd.exception.RecursoNoEncontradoException;
import com.masterdrilling.sgsramd.model.entity.*;
import com.masterdrilling.sgsramd.model.enums.EstadoDevolucion;
import com.masterdrilling.sgsramd.model.enums.EstadoHerramienta;
import com.masterdrilling.sgsramd.model.enums.EstadoPrestamo;
import com.masterdrilling.sgsramd.service.IAuditoriaService;
import com.masterdrilling.sgsramd.service.INotificacionService;
import com.masterdrilling.sgsramd.service.IPrestamoService;
import com.masterdrilling.sgsramd.service.validator.CupoPrestamoValidator;
import lombok.RequiredArgsConstructor;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class PrestamoServiceImpl implements IPrestamoService {

    private final Prestamo_DAO prestamoRepository;
    private final Herramienta_DAO herramientaRepository;
    private final Mecanico_DAO mecanicoRepository;
    private final Almacenista_DAO almacenistaRepository;
    private final Devolucion_DAO devolucionRepository;
    private final Usuario_DAO usuarioRepository;
    private final IAuditoriaService auditoriaService;
    private final INotificacionService notificacionService;
    private final CupoPrestamoValidator cupoValidator;
    private final PrestamoDetalle_DAO prestamoDetalleRepository;

    @Override
    @Transactional
    public MensajeGenericoResponse registrarPrestamo(String correoAlmacenista, RegistrarPrestamoRequest request, String ipOrigen) {
        cupoValidator.validarAusenciaDeMoras(request.getDniMecanico());
        cupoValidator.validarCupoDisponible(request.getDniMecanico(), request.getCodigosHerramienta().size());

        Usuario usuario = usuarioRepository.findByCorreoCorporativo(correoAlmacenista)
                .orElseThrow(() -> new RecursoNoEncontradoException("Almacenista no encontrado"));

        Almacenista almacenista = almacenistaRepository.findByDniAlmacenista(usuario.getDni())
                .orElseThrow(() -> new RecursoNoEncontradoException("Ficha de almacenista no existe"));

        Mecanico mecanico = mecanicoRepository.findByDniMecanico(request.getDniMecanico())
                .orElseThrow(() -> new RecursoNoEncontradoException("Mecanico no registrado"));

        String prestamoId = "PRES-" + System.currentTimeMillis();

        Prestamo prestamo = Prestamo.builder()
                .prestamoNum(prestamoId)
                .fechaPrestamo(LocalDate.now())
                .horaSalida(LocalTime.now())
                .almacenista(almacenista)
                .mecanico(mecanico)
                .estadoPrestamo(EstadoPrestamo.ACTIVO)
                .detalles(new ArrayList<>())
                .build();

        int itemIdx = 1;
        for (String codH : request.getCodigosHerramienta()) {
            Herramienta herramienta = herramientaRepository.findByCodHerramienta(codH.trim())
                    .orElseThrow(() -> new RecursoNoEncontradoException("Herramienta no encontrada: " + codH));

            if (!EstadoHerramienta.DISPONIBLE.getDescripcionSql().equalsIgnoreCase(herramienta.getEstadoActual())) {
                throw new BadRequestException("Herramienta " + codH + " no disponible. Estado actual: " + herramienta.getEstadoActual());
            }

            herramienta.setEstadoActual(EstadoHerramienta.PRESTADA.getDescripcionSql());
            herramientaRepository.save(herramienta);

            PrestamoDetalle det = PrestamoDetalle.builder()
                    .id(new PrestamoDetalleId(prestamoId, itemIdx++))
                    .prestamo(prestamo)
                    .herramienta(herramienta)
                    .nombreHerramienta(herramienta.getNombreHerramienta())
                    .estadoHerramienta(EstadoHerramienta.PRESTADA.getDescripcionSql())
                    .firmaMecanico(request.getFirmaMecanico())
                    .build();

            prestamo.getDetalles().add(det);
        }

        prestamoRepository.save(prestamo);
        auditoriaService.registrarAsiento(prestamoId, usuario.getIdUsuario(), "PRESTAMO_HERRAMIENTAS", ipOrigen);

        return MensajeGenericoResponse.builder()
                .exito(true)
                .mensaje("Prestamo registrado exitosamente")
                .dato(prestamoId)
                .build();
    }

    @Override
    @Transactional
    public MensajeGenericoResponse registrarDevolucion(String correoAlmacenista, DevolucionHerramientaRequest request, String ipOrigen) {
        Prestamo prestamo = prestamoRepository.findById(request.getPrestamoNum())
                .orElseThrow(() -> new RecursoNoEncontradoException("Prestamo no encontrado"));

        Usuario usuario = usuarioRepository.findByCorreoCorporativo(correoAlmacenista)
                .orElseThrow(() -> new RecursoNoEncontradoException("Almacenista no encontrado"));

        Almacenista almacenista = almacenistaRepository.findByDniAlmacenista(usuario.getDni())
                .orElseThrow(() -> new RecursoNoEncontradoException("Ficha de almacenista no existe"));

        String devId = "DEV-" + System.currentTimeMillis();

        Devolucion devolucion = Devolucion.builder()
                .devolucionNum(devId)
                .fechaDevolucion(LocalDate.now())
                .horaRetorno(LocalTime.now())
                .detalleIncidencia(request.getDetalleIncidencia())
                .prestamo(prestamo)
                .almacenista(almacenista)
                .mecanico(prestamo.getMecanico())
                .detalles(new ArrayList<>())
                .build();

        int itemIdx = 1;
        for (DevolucionHerramientaRequest.ItemDevolucionRequest itemReq : request.getItems()) {
            Herramienta herramienta = herramientaRepository.findByCodHerramienta(itemReq.getCodHerramienta())
                    .orElseThrow(() -> new RecursoNoEncontradoException("Herramienta no encontrada: " + itemReq.getCodHerramienta()));

            // RF40: Con Averia o Incompleta pasan a En Mantenimiento (nunca Disponible si faltan partes)
            if (itemReq.getEstadoFisico() == EstadoDevolucion.CON_AVERIA || itemReq.getEstadoFisico() == EstadoDevolucion.INCOMPLETA) {
                herramienta.setEstadoActual(EstadoHerramienta.EN_MANTENIMIENTO.getDescripcionSql());
            } else {
                herramienta.setEstadoActual(EstadoHerramienta.DISPONIBLE.getDescripcionSql());
            }
            herramientaRepository.save(herramienta);

            DevolucionDetalle det = DevolucionDetalle.builder()
                    .id(new DevolucionDetalleId(devId, itemIdx++))
                    .devolucion(devolucion)
                    .herramienta(herramienta)
                    .estadoHerramienta(itemReq.getEstadoFisico().getDescripcionSql())
                    .build();

            devolucion.getDetalles().add(det);
        }

        // RF40: Actualizar hora de retorno efectiva en los detalles del prestamo original
        LocalTime horaCierre = LocalTime.now();
        List<PrestamoDetalle> detallesPrestamo = prestamoDetalleRepository.findByIdPrestamoNum(prestamo.getPrestamoNum());
        for (PrestamoDetalle pd : detallesPrestamo) {
            pd.setHoraRetorno(horaCierre);
            prestamoDetalleRepository.save(pd);
        }

        prestamo.setEstadoPrestamo(EstadoPrestamo.CERRADO);
        prestamoRepository.save(prestamo);
        devolucionRepository.save(devolucion);

        auditoriaService.registrarAsiento(devId, usuario.getIdUsuario(), "DEVOLUCION_HERRAMIENTAS", ipOrigen);

        return MensajeGenericoResponse.builder()
                .exito(true)
                .mensaje("Devolucion procesada e inventario actualizado")
                .dato(devId)
                .build();
    }

    @Override
    @Transactional
    public MensajeGenericoResponse reportarHerramientaExtraviada(String correoAlmacenista, ReporteExtravioRequest request, String ipOrigen) {
        Herramienta herramienta = herramientaRepository.findByCodHerramienta(request.getCodHerramienta().trim())
                .orElseThrow(() -> new RecursoNoEncontradoException("Herramienta no registrada"));

        if (EstadoHerramienta.DISPONIBLE.getDescripcionSql().equalsIgnoreCase(herramienta.getEstadoActual())) {
            throw new BadRequestException("La herramienta figura disponible en estantes. Verifique fisicamente el panol antes de reportarla");
        }

        Usuario usuarioAlmacen = usuarioRepository.findByCorreoCorporativo(correoAlmacenista)
                .orElseThrow(() -> new RecursoNoEncontradoException("Almacenista reportante no encontrado"));

        herramienta.setEstadoActual(EstadoHerramienta.EXTRAVIADA.getDescripcionSql());
        herramientaRepository.save(herramienta);

        String custodio = prestamoRepository.findUltimoMecanicoCustodio(herramienta.getCodHerramienta())
                .orElse("SIN_CUSTODIO_PREVIO");

        // Se usa el ID del usuario real autenticado que emite el reporte
        auditoriaService.registrarAsiento(herramienta.getCodHerramienta(), usuarioAlmacen.getIdUsuario(), "EXTRAVIO_IMPUTADO_" + custodio, ipOrigen);

        String detalle = "La herramienta " + herramienta.getCodHerramienta() + " (" + herramienta.getNombreHerramienta()
                + ") fue reportada como EXTRAVIADA. Motivo: " + request.getMotivoExtravio().trim();
        notificacionService.enviarNotificacionConTipo(null, "ADMINISTRADOR", "Herramienta Extraviada",
                detalle + ". Custodio responsable: " + custodio, "EXTRAVIO");
        if (!"SIN_CUSTODIO_PREVIO".equals(custodio)) {
            notificacionService.enviarNotificacionConTipo(custodio, "MECANICO", "Herramienta Extraviada a su Cargo",
                    detalle + ". Usted figura como ultimo custodio; acerquese al panol.", "EXTRAVIO");
        }

        return MensajeGenericoResponse.builder()
                .exito(true)
                .mensaje("Herramienta marcada como extraviada. Se asocio la responsabilidad a la bitacora de custodia")
                .dato(custodio)
                .build();
    }

    @Override
    @Transactional
    public MensajeGenericoResponse verificarAlertasPrestamos() {
        List<Prestamo> prestamosActivos = prestamoRepository.findAll().stream()
                .filter(p -> p.getEstadoPrestamo() == EstadoPrestamo.ACTIVO)
                .toList();

        int preventivas = 0;
        int moras = 0;
        LocalDate hoy = LocalDate.now();

        for (Prestamo p : prestamosActivos) {
            long dias = ChronoUnit.DAYS.between(p.getFechaPrestamo(), hoy);
            String dniMec = p.getMecanico() != null ? p.getMecanico().getDniMecanico() : null;
            String nomMec = p.getMecanico() != null ? p.getMecanico().getNombreMecanico() : "Mecanico";

            if (dias >= 5 && dias < 7) {
                // Alerta preventiva al mecanico (6.2.2)
                if (dniMec != null) {
                    notificacionService.enviarNotificacionConTipo(dniMec, "MECANICO", "Aviso Preventivo de Devolucion",
                            "Su prestamo " + p.getPrestamoNum() + " tiene " + dias + " dias de antiguedad. Recuerde devolver las herramientas antes de cumplir 7 dias para evitar sanciones.",
                            "ALERTA_PREVENTIVA");
                    preventivas++;
                }
            } else if (dias >= 7) {
                // Transicion a MORA y alertas (6.2.2, 6.3.1)
                p.setEstadoPrestamo(EstadoPrestamo.MORA);
                prestamoRepository.save(p);

                // RF43: Actualizar estado de las herramientas del prestamo a 'En Mora' para el tablero de panol
                List<PrestamoDetalle> detallesMora = prestamoDetalleRepository.findByIdPrestamoNum(p.getPrestamoNum());
                for (PrestamoDetalle d : detallesMora) {
                    Herramienta h = d.getHerramienta();
                    if (h != null && EstadoHerramienta.PRESTADA.getDescripcionSql().equalsIgnoreCase(h.getEstadoActual())) {
                        h.setEstadoActual(EstadoHerramienta.EN_MORA.getDescripcionSql());
                        herramientaRepository.save(h);
                    }
                }

                // Almacenista: aviso de mora (6.3.1)
                notificacionService.enviarNotificacionConTipo(null, "ALMACENISTA", "Prestamo en Mora / Atrasado",
                        "El prestamo " + p.getPrestamoNum() + " del mecanico " + nomMec + " ha superado el plazo de 7 dias y paso a estado MORA.",
                        "MORA");

                // Mecanico: aviso de mora
                if (dniMec != null) {
                    notificacionService.enviarNotificacionConTipo(dniMec, "MECANICO", "Prestamo Vencido en Mora",
                            "Su prestamo " + p.getPrestamoNum() + " ha superado el plazo maximo de 7 dias sin devolverse. Su cupo para nuevos prestamos queda bloqueado.",
                            "MORA");
                }
                moras++;
            }
        }

        return MensajeGenericoResponse.builder()
                .exito(true)
                .mensaje("Verificacion de prestamos ejecutada: " + preventivas + " alertas preventivas emitidas, " + moras + " prestamos en MORA.")
                .dato(preventivas + moras)
                .build();
    }

    @Override
    @Transactional(readOnly = true)
    public List<PrestamoResumenResponse> listarTodosLosPrestamos() {
        return prestamoRepository.findAll().stream()
                .map(this::mapearAPrestamoResumen)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public List<PrestamoResumenResponse> listarPrestamosPorMecanico(String dniMecanico) {
        return prestamoRepository.findAll().stream()
                .filter(p -> p.getMecanico() != null && dniMecanico.trim().equals(p.getMecanico().getDniMecanico()))
                .map(this::mapearAPrestamoResumen)
                .toList();
    }

    private PrestamoResumenResponse mapearAPrestamoResumen(Prestamo p) {
        String dniMec = (p.getMecanico() != null) ? p.getMecanico().getDniMecanico() : "";
        String nombreMec = mecanicoRepository.findByDniMecanico(dniMec)
                .map(Mecanico::getNombreMecanico)
                .orElse("Mecanico no registrado");

        List<PrestamoDetalle> detalles = prestamoDetalleRepository.findByIdPrestamoNum(p.getPrestamoNum());
        List<PrestamoResumenResponse.ItemHerramientaPrestamo> items = detalles.stream().map(d -> {
            String estadoFisico = herramientaRepository.findByCodHerramienta(d.getHerramienta().getCodHerramienta())
                    .map(Herramienta::getEstadoActual)
                    .orElse(d.getEstadoHerramienta());
            return PrestamoResumenResponse.ItemHerramientaPrestamo.builder()
                    .codHerramienta(d.getHerramienta().getCodHerramienta())
                    .nombreHerramienta(d.getNombreHerramienta())
                    .estadoHerramienta(d.getEstadoHerramienta())
                    .estadoFisicoActual(estadoFisico)
                    .build();
        }).toList();

        return PrestamoResumenResponse.builder()
                .prestamoNum(p.getPrestamoNum())
                .dniMecanico(dniMec)
                .nombreMecanico(nombreMec)
                .estadoPrestamo(p.getEstadoPrestamo())
                .fechaPrestamo(p.getFechaPrestamo())
                .horaSalida(p.getHoraSalida())
                .herramientas(items)
                .build();
    }
}