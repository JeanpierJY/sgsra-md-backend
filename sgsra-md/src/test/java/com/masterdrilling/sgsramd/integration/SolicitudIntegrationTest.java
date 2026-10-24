package com.masterdrilling.sgsramd.integration;

import com.masterdrilling.sgsramd.dto.request.SolicitudRepuestoRequest;
import com.masterdrilling.sgsramd.dto.response.MensajeGenericoResponse;
import com.masterdrilling.sgsramd.model.entity.Solicitud;
import com.masterdrilling.sgsramd.model.enums.EstadoSolicitud;
import com.masterdrilling.sgsramd.model.enums.PrioridadSolicitud;
import com.masterdrilling.sgsramd.repository.SolicitudRepository;
import com.masterdrilling.sgsramd.service.ISolicitudService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

// Prueba de integracion completa de flujo de solicitud contra base de datos real con rollback automatico
@SpringBootTest
@Transactional
class SolicitudIntegrationTest {

    @Autowired
    private ISolicitudService solicitudService;

    @Autowired
    private SolicitudRepository solicitudRepository;

    @Test
    @DisplayName("Debe persistir la solicitud con sus lineas de detalle de repuesto en cascada")
    void testRegistrarSolicitud_PersistenciaCascada() {
        SolicitudRepuestoRequest request = SolicitudRepuestoRequest.builder()
                .codMaquinaria("MD-RB-01")
                .prioridad(PrioridadSolicitud.ALTA)
                .justificacionTecnica("Falla de presion en manguera de retorno de bomba hidraulica")
                .items(List.of(
                        new SolicitudRepuestoRequest.ItemRepuestoRequest("P-REX-024", 1),
                        new SolicitudRepuestoRequest.ItemRepuestoRequest("H-ESP-118", 2)
                ))
                .build();

        MensajeGenericoResponse response = solicitudService.registrarSolicitud(
                "carlos.mendoza@masterdrilling.com", request, "127.0.0.1");

        assertNotNull(response);
        assertTrue(response.isExito());
        String solicitudNum = (String) response.getDato();

        // Validacion directa contra base de datos
        Solicitud solicitudPersistida = solicitudRepository.findById(solicitudNum).orElse(null);
        assertNotNull(solicitudPersistida);
        assertEquals(EstadoSolicitud.PENDIENTE, solicitudPersistida.getEstadoSolicitud());
        assertEquals("MD-RB-01", solicitudPersistida.getMaquinaria().getCodMaquinaria());
        assertEquals(2, solicitudPersistida.getDetalles().size());
    }
}