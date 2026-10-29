package com.masterdrilling.sgsramd.integration;

import com.masterdrilling.sgsramd.DAO.Solicitud_DAO;
import com.masterdrilling.sgsramd.dto.request.SolicitudRepuestoRequest;
import com.masterdrilling.sgsramd.dto.response.MensajeGenericoResponse;
import com.masterdrilling.sgsramd.model.entity.Solicitud;
import com.masterdrilling.sgsramd.model.enums.EstadoSolicitud;
import com.masterdrilling.sgsramd.model.enums.PrioridadSolicitud;
import com.masterdrilling.sgsramd.service.ISolicitudService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
@Transactional
class SolicitudIntegrationTest {

    @Autowired
    private ISolicitudService solicitudService;

    @Autowired
    private Solicitud_DAO solicitudRepository;

    @Test
    @DisplayName("Debe persistir la solicitud con sus lineas de detalle de repuesto en cascada")
    void testRegistrarSolicitud_PersistenciaCascada() {
        SolicitudRepuestoRequest request = SolicitudRepuestoRequest.builder()
                .codMaquinaria("MD-RB-01")
                .prioridad(PrioridadSolicitud.ALTA)
                .justificacionTecnica("Falla de presion en manguera de retorno de bomba hidraulica")
                .items(List.of(
                        new SolicitudRepuestoRequest.ItemRepuestoRequest("P-REX-024", 1)
                ))
                .build();

        // Correo del mecanico real en la base de datos
        MensajeGenericoResponse response = solicitudService.registrarSolicitud(
                "carlos.baro@masterdrilling.com", request, "127.0.0.1");

        assertNotNull(response);
        assertTrue(response.isExito());
        String solicitudNum = (String) response.getDato();

        Solicitud solicitudPersistida = solicitudRepository.findById(solicitudNum).orElse(null);
        assertNotNull(solicitudPersistida);
        assertEquals(EstadoSolicitud.PENDIENTE, solicitudPersistida.getEstadoSolicitud());
        assertEquals("MD-RB-01", solicitudPersistida.getMaquinaria().getCodMaquinaria());
        assertFalse(solicitudPersistida.getDetalles().isEmpty());
    }
}