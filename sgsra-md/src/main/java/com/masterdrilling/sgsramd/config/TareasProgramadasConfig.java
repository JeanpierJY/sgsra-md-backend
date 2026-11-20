package com.masterdrilling.sgsramd.config;

import com.masterdrilling.sgsramd.service.IPrestamoService;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;

// RF43 / Mantenimiento (cron jobs): verificacion automatica diaria de prestamos
// (aviso preventivo al mecanico y paso a MORA al cumplir 7 dias)
@Configuration
@EnableScheduling
@RequiredArgsConstructor
public class TareasProgramadasConfig {

    private static final Logger log = LoggerFactory.getLogger(TareasProgramadasConfig.class);
    private final IPrestamoService prestamoService;

    @Scheduled(cron = "0 0 7 * * *")
    public void verificarPrestamosDiario() {
        log.info("[CRON] {}", prestamoService.verificarAlertasPrestamos().getMensaje());
    }
}
