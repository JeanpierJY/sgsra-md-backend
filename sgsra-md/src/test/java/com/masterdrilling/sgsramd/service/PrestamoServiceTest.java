package com.masterdrilling.sgsramd.service;

import com.masterdrilling.sgsramd.DAO.*;
import com.masterdrilling.sgsramd.dto.request.RegistrarPrestamoRequest;
import com.masterdrilling.sgsramd.dto.response.MensajeGenericoResponse;
import com.masterdrilling.sgsramd.exception.BadRequestException;
import com.masterdrilling.sgsramd.model.entity.Almacenista;
import com.masterdrilling.sgsramd.model.entity.Herramienta;
import com.masterdrilling.sgsramd.model.entity.Mecanico;
import com.masterdrilling.sgsramd.model.entity.Usuario;
import com.masterdrilling.sgsramd.model.enums.RolUsuario;
import com.masterdrilling.sgsramd.service.impl.PrestamoServiceImpl;
import com.masterdrilling.sgsramd.service.validator.CupoPrestamoValidator;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

// Pruebas unitarias para prestamos y validacion de pañol (RF36, RF37)
@ExtendWith(MockitoExtension.class)
class PrestamoServiceTest {

    @Mock
    private Prestamo_DAO prestamoRepository;

    @Mock
    private Herramienta_DAO herramientaRepository;

    @Mock
    private Mecanico_DAO mecanicoRepository;

    @Mock
    private Almacenista_DAO almacenistaRepository;

    @Mock
    private Usuario_DAO usuarioRepository;

    @Mock
    private IAuditoriaService auditoriaService;

    @Mock
    private CupoPrestamoValidator cupoValidator;

    @InjectMocks
    private PrestamoServiceImpl prestamoService;

    private Usuario usuarioAlmacen;
    private Almacenista almacenista;
    private Mecanico mecanico;
    private Herramienta herramienta;
    private RegistrarPrestamoRequest request;

    @BeforeEach
    void setUp() {
        usuarioAlmacen = Usuario.builder()
                .idUsuario(2L)
                .dni("45829104")
                .correoCorporativo("marcos.ramos@masterdrilling.com")
                .rol(RolUsuario.ALMACENISTA)
                .build();

        almacenista = Almacenista.builder()
                .dniAlmacenista("45829104")
                .nombreAlmacenista("Marcos Aurelio Ramos")
                .sedeAsignada("Taller Lurin")
                .build();

        mecanico = Mecanico.builder()
                .dniMecanico("75859812")
                .nombreMecanico("Carlos Mendoza")
                .especialidadMecanico("Hidraulica")
                .cargoMecanico("Mecanico de Planta")
                .build();

        herramienta = Herramienta.builder()
                .codHerramienta("HER-TOR-004")
                .nombreHerramienta("Torquimetro Industrial")
                .marcaHerramienta("Proto")
                .categoria("Manuales")
                .estadoActual("Disponible")
                .build();

        request = RegistrarPrestamoRequest.builder()
                .dniMecanico("75859812")
                .codigosHerramienta(List.of("HER-TOR-004"))
                .firmaMecanico("FIRMA_DIGITAL_BASE64")
                .build();
    }

    @Test
    @DisplayName("Debe registrar el prestamo y cambiar estado de la herramienta a Prestada")
    void testRegistrarPrestamo_Exito() {
        when(usuarioRepository.findByCorreoCorporativo(anyString())).thenReturn(Optional.of(usuarioAlmacen));
        when(almacenistaRepository.findByDniAlmacenista(anyString())).thenReturn(Optional.of(almacenista));
        when(mecanicoRepository.findByDniMecanico(anyString())).thenReturn(Optional.of(mecanico));
        when(herramientaRepository.findByCodHerramienta("HER-TOR-004")).thenReturn(Optional.of(herramienta));

        MensajeGenericoResponse response = prestamoService.registrarPrestamo("marcos.ramos@masterdrilling.com", request, "127.0.0.1");

        assertNotNull(response);
        assertTrue(response.isExito());
        assertEquals("Prestada", herramienta.getEstadoActual());
        verify(herramientaRepository, times(1)).save(herramienta);
        verify(prestamoRepository, times(1)).save(any());
        verify(auditoriaService, times(1)).registrarAsiento(anyString(), eq(2L), eq("PRESTAMO_HERRAMIENTAS"), anyString());
    }

    @Test
    @DisplayName("Debe fallar si la herramienta solicitada no se encuentra disponible")
    void testRegistrarPrestamo_HerramientaNoDisponible() {
        herramienta.setEstadoActual("Prestada");
        when(usuarioRepository.findByCorreoCorporativo(anyString())).thenReturn(Optional.of(usuarioAlmacen));
        when(almacenistaRepository.findByDniAlmacenista(anyString())).thenReturn(Optional.of(almacenista));
        when(mecanicoRepository.findByDniMecanico(anyString())).thenReturn(Optional.of(mecanico));
        when(herramientaRepository.findByCodHerramienta("HER-TOR-004")).thenReturn(Optional.of(herramienta));

        assertThrows(BadRequestException.class, () -> 
                prestamoService.registrarPrestamo("marcos.ramos@masterdrilling.com", request, "127.0.0.1"));

        verify(prestamoRepository, never()).save(any());
    }
}