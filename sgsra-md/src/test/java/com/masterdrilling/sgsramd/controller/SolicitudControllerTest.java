package com.masterdrilling.sgsramd.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.masterdrilling.sgsramd.dto.request.DictamenRechazoRequest;
import com.masterdrilling.sgsramd.dto.request.SolicitudRepuestoRequest;
import com.masterdrilling.sgsramd.dto.response.DetalleSolicitudResponse;
import com.masterdrilling.sgsramd.dto.response.MensajeGenericoResponse;
import com.masterdrilling.sgsramd.exception.GlobalExceptionHandler;
import com.masterdrilling.sgsramd.model.enums.EstadoSolicitud;
import com.masterdrilling.sgsramd.model.enums.PrioridadSolicitud;
import com.masterdrilling.sgsramd.service.ISolicitudService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

// Pruebas unitarias de capa web para registro, detalle, aprobacion y rechazo (RF17, RF22, RF23, RF24)
@ExtendWith(MockitoExtension.class)
class SolicitudControllerTest {

    private MockMvc mockMvc;

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Mock
    private ISolicitudService solicitudService;

    @InjectMocks
    private SolicitudController solicitudController;

    @BeforeEach
    void setUp() {
        mockMvc = MockMvcBuilders.standaloneSetup(solicitudController)
                .setControllerAdvice(new GlobalExceptionHandler())
                .build();
    }

    @Test
    @DisplayName("POST /api/v1/solicitudes debe registrar la solicitud y responder 201 CREATED")
    void testRegistrarSolicitud_Created() throws Exception {
        SolicitudRepuestoRequest request = SolicitudRepuestoRequest.builder()
                .codMaquinaria("MD-RB-01")
                .prioridad(PrioridadSolicitud.ALTA)
                .justificacionTecnica("Fuga critica de aceite en motor de empuje")
                .items(List.of(new SolicitudRepuestoRequest.ItemRepuestoRequest("P-REX-024", 1)))
                .build();

        MensajeGenericoResponse response = MensajeGenericoResponse.builder()
                .exito(true)
                .mensaje("Solicitud SOL-2026-0001 enviada con exito")
                .dato("SOL-2026-0001")
                .build();

        when(solicitudService.registrarSolicitud(eq("carlos.mendoza@masterdrilling.com"), any(SolicitudRepuestoRequest.class), anyString()))
                .thenReturn(response);

        mockMvc.perform(post("/api/v1/solicitudes")
                        .param("correoMecanico", "carlos.mendoza@masterdrilling.com")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.exito").value(true))
                .andExpect(jsonPath("$.dato").value("SOL-2026-0001"));
    }

    @Test
    @DisplayName("GET /api/v1/solicitudes/{id} debe retornar expediente completo con 200 OK")
    void testObtenerDetalleSolicitud_Ok() throws Exception {
        DetalleSolicitudResponse detalle = DetalleSolicitudResponse.builder()
                .solicitudNum("SOL-2026-0001")
                .fechaEmision(LocalDate.now())
                .horaEmision(LocalTime.now())
                .prioridad(PrioridadSolicitud.ALTA)
                .estado(EstadoSolicitud.PENDIENTE)
                .justificacionTecnica("Fuga critica de aceite")
                .codMaquinaria("MD-RB-01")
                .modeloMaquinaria("Raise Borer Rhino")
                .serieMaquinaria("SER-01")
                .dniMecanico("75859812")
                .nombreMecanico("Carlos Mendoza")
                .telefonoMecanico("995348431")
                .repuestos(new ArrayList<>())
                .build();

        when(solicitudService.obtenerDetalleSolicitud("SOL-2026-0001")).thenReturn(detalle);

        mockMvc.perform(get("/api/v1/solicitudes/SOL-2026-0001"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.solicitudNum").value("SOL-2026-0001"))
                .andExpect(jsonPath("$.estado").value("PENDIENTE"))
                .andExpect(jsonPath("$.dniMecanico").value("75859812"));
    }

    @Test
    @DisplayName("PUT /api/v1/solicitudes/{id}/aprobar debe autorizar orden y responder 200 OK")
    void testAprobarTotal_Ok() throws Exception {
        MensajeGenericoResponse response = MensajeGenericoResponse.builder()
                .exito(true)
                .mensaje("Solicitud aprobada integramente")
                .dato("SOL-2026-0001")
                .build();

        when(solicitudService.aprobarSolicitudTotal(eq("SOL-2026-0001"), anyString())).thenReturn(response);

        mockMvc.perform(put("/api/v1/solicitudes/SOL-2026-0001/aprobar"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.exito").value(true))
                .andExpect(jsonPath("$.mensaje").value("Solicitud aprobada integramente"));
    }

    @Test
    @DisplayName("PUT /api/v1/solicitudes/{id}/rechazar debe responder 400 Bad Request si la justificacion es corta")
    void testRechazarTotal_MotivoInvalido() throws Exception {
        DictamenRechazoRequest request = DictamenRechazoRequest.builder()
                .justificacionRechazo("Corto") // Menor a 15 caracteres
                .build();

        mockMvc.perform(put("/api/v1/solicitudes/SOL-2026-0001/rechazar")
                        .param("correoAdmin", "leao.chura@masterdrilling.com")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("Error de validacion de campos"));
    }
}