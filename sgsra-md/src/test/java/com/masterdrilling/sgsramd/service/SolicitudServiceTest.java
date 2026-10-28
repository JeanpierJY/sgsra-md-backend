package com.masterdrilling.sgsramd.service;

import com.masterdrilling.sgsramd.DAO.*;
import com.masterdrilling.sgsramd.dto.request.DictamenRechazoRequest;
import com.masterdrilling.sgsramd.dto.response.MensajeGenericoResponse;
import com.masterdrilling.sgsramd.exception.BadRequestException;
import com.masterdrilling.sgsramd.model.entity.*;
import com.masterdrilling.sgsramd.model.enums.EstadoSolicitud;
import com.masterdrilling.sgsramd.model.enums.PrioridadSolicitud;
import com.masterdrilling.sgsramd.service.impl.SolicitudServiceImpl;
import com.masterdrilling.sgsramd.service.validator.JustificacionRechazoValidator;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Spy;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

// Pruebas unitarias para aprobacion y rechazo justificado de solicitudes (RF23, RF24, RF25)
@ExtendWith(MockitoExtension.class)
class SolicitudServiceTest {

    @Mock
    private Solicitud_DAO solicitudRepository;

    @Mock
    private Administrador_DAO administradorRepository;

    @Mock
    private DictamenRechazo_DAO dictamenRepository;

    @Mock
    private Usuario_DAO usuarioRepository;

    @Mock
    private IAuditoriaService auditoriaService;

    @Mock
    private INotificacionService notificacionService;

    @Spy
    private JustificacionRechazoValidator rechazoValidator = new JustificacionRechazoValidator();

    @InjectMocks
    private SolicitudServiceImpl solicitudService;

    private Solicitud solicitud;
    private Usuario usuarioAdmin;
    private Administrador administrador;

    @BeforeEach
    void setUp() {
        Mecanico mecanico = Mecanico.builder()
                .dniMecanico("75859812")
                .nombreMecanico("Carlos Mendoza")
                .build();

        solicitud = Solicitud.builder()
                .solicitudNum("SOL-2026-0001")
                .fechaEmision(LocalDate.now())
                .horaEmision(LocalTime.now())
                .prioridadSolicitud(PrioridadSolicitud.ALTA)
                .justificacionTecnica("Fuga de aceite en bomba principal de rotacion")
                .estadoSolicitud(EstadoSolicitud.PENDIENTE)
                .mecanico(mecanico)
                .detalles(new ArrayList<>())
                .build();

        usuarioAdmin = Usuario.builder()
                .idUsuario(3L)
                .dni("10293847")
                .correoCorporativo("leao.chura@masterdrilling.com")
                .build();

        administrador = Administrador.builder()
                .dniAdministrador("10293847")
                .nombreAdministrador("Leao Chura")
                .correoCorporativo("leao.chura@masterdrilling.com")
                .build();
    }

    @Test
    @DisplayName("Debe aprobar la solicitud cambiando el estado a APROBADA (RF23)")
    void testAprobarSolicitudTotal_Exito() {
        when(solicitudRepository.findById("SOL-2026-0001")).thenReturn(Optional.of(solicitud));
        when(usuarioRepository.findByCorreoCorporativo("leao.chura@masterdrilling.com")).thenReturn(Optional.of(usuarioAdmin));

        MensajeGenericoResponse response = solicitudService.aprobarSolicitudTotal(
                "SOL-2026-0001", "leao.chura@masterdrilling.com", "127.0.0.1");

        assertNotNull(response);
        assertTrue(response.isExito());
        assertEquals(EstadoSolicitud.APROBADA, solicitud.getEstadoSolicitud());
        verify(solicitudRepository, times(1)).save(solicitud);
        verify(notificacionService, times(1)).enviarNotificacion(anyString(), eq("Solicitud Aprobada"), anyString());
    }

    @Test
    @DisplayName("Debe rechazar la solicitud cuando el motivo cumple la longitud minima (RF25)")
    void testRechazarSolicitudTotal_Exito() {
        DictamenRechazoRequest request = DictamenRechazoRequest.builder()
                .justificacionRechazo("Stock en panol cubre requerimiento inmediato")
                .build();

        when(solicitudRepository.findById("SOL-2026-0001")).thenReturn(Optional.of(solicitud));
        when(usuarioRepository.findByCorreoCorporativo(anyString())).thenReturn(Optional.of(usuarioAdmin));
        when(administradorRepository.findByDniAdministrador(anyString())).thenReturn(Optional.of(administrador));

        MensajeGenericoResponse response = solicitudService.rechazarSolicitudTotal(
                "SOL-2026-0001", "leao.chura@masterdrilling.com", request, "127.0.0.1");

        assertNotNull(response);
        assertTrue(response.isExito());
        assertEquals(EstadoSolicitud.RECHAZADA, solicitud.getEstadoSolicitud());
        verify(dictamenRepository, times(1)).save(any(DictamenRechazo.class));
    }

    @Test
    @DisplayName("Debe lanzar BadRequestException si el motivo de rechazo tiene menos de 15 caracteres (RF25)")
    void testRechazarSolicitudTotal_MotivoInsuficiente() {
        DictamenRechazoRequest request = DictamenRechazoRequest.builder()
                .justificacionRechazo("No procede")
                .build();

        assertThrows(BadRequestException.class, () ->
                solicitudService.rechazarSolicitudTotal("SOL-2026-0001", "leao.chura@masterdrilling.com", request, "127.0.0.1"));

        verify(solicitudRepository, never()).save(any());
        verify(dictamenRepository, never()).save(any());
    }
}