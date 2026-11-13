package com.masterdrilling.sgsramd.service.impl;

import com.masterdrilling.sgsramd.DAO.Herramienta_DAO;
import com.masterdrilling.sgsramd.DAO.Prestamo_DAO;
import com.masterdrilling.sgsramd.model.entity.Herramienta;
import com.masterdrilling.sgsramd.model.entity.Prestamo;
import com.masterdrilling.sgsramd.model.entity.PrestamoDetalle;
import com.masterdrilling.sgsramd.model.enums.EstadoHerramienta;
import com.masterdrilling.sgsramd.model.enums.EstadoPrestamo;
import com.masterdrilling.sgsramd.service.INotificacionService;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.stream.Collectors;

// Control de vencimiento de prestamos de herramientas (RF43, matriz de notificaciones 6.2 y 6.3):
// - Dia 6: aviso preventivo al mecanico (el prestamo esta por caer en mora)
// - Dia 7 o mas: el prestamo pasa a MORA, las herramientas a "En Mora" y se avisa al almacenista
@Service
@RequiredArgsConstructor
public class PrestamoVencimientoService {

    public static final int DIAS_LIMITE_PRESTAMO = 7;
    private static final Logger log = LoggerFactory.getLogger(PrestamoVencimientoService.class);

    private final Prestamo_DAO prestamoRepository;
    private final Herramienta_DAO herramientaRepository;
    private final INotificacionService notificacionService;

    // Se ejecuta todos los dias a las 07:00 y tambien puede invocarse manualmente
    @Scheduled(cron = "0 0 7 * * *")
    @Transactional
    public String verificarVencimientos() {
        LocalDate hoy = LocalDate.now();
        int avisosPreventivos = 0;
        int nuevasMoras = 0;

        for (Prestamo p : prestamoRepository.findAll()) {
            if (p.getEstadoPrestamo() != EstadoPrestamo.ACTIVO || p.getMecanico() == null) {
                continue;
            }
            long dias = ChronoUnit.DAYS.between(p.getFechaPrestamo(), hoy);
            String herramientas = p.getDetalles().stream()
                    .map(d -> d.getHerramienta().getCodHerramienta() + " (" + d.getNombreHerramienta() + ")")
                    .collect(Collectors.joining(", "));

            if (dias >= DIAS_LIMITE_PRESTAMO) {
                p.setEstadoPrestamo(EstadoPrestamo.MORA);
                for (PrestamoDetalle d : p.getDetalles()) {
                    Herramienta h = d.getHerramienta();
                    if (EstadoHerramienta.PRESTADA.getDescripcionSql().equalsIgnoreCase(h.getEstadoActual())) {
                        h.setEstadoActual(EstadoHerramienta.EN_MORA.getDescripcionSql());
                        herramientaRepository.save(h);
                    }
                }
                prestamoRepository.save(p);
                notificacionService.enviarNotificacionConTipo(null, "ALMACENISTA", "Prestamo en Mora",
                        "El prestamo " + p.getPrestamoNum() + " del mecanico " + p.getMecanico().getNombreMecanico()
                                + " (DNI " + p.getMecanico().getDniMecanico() + ") cumplio " + dias
                                + " dias sin devolucion. Herramientas: " + herramientas,
                        "MORA");
                nuevasMoras++;
            } else if (dias == DIAS_LIMITE_PRESTAMO - 1 && !Boolean.TRUE.equals(p.getAvisoPreventivoEnviado())) {
                p.setAvisoPreventivoEnviado(true);
                prestamoRepository.save(p);
                notificacionService.enviarNotificacionConTipo(p.getMecanico().getDniMecanico(), null,
                        "Prestamo por Vencer",
                        "Su prestamo " + p.getPrestamoNum() + " vence manana (7 dias). Devuelva al panol: " + herramientas,
                        "VENCIMIENTO");
                avisosPreventivos++;
            }
        }

        String resumen = "Verificacion de vencimientos: " + avisosPreventivos + " aviso(s) preventivo(s), "
                + nuevasMoras + " prestamo(s) pasados a MORA";
        log.info(resumen);
        return resumen;
    }
}
