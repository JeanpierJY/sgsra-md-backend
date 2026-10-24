package com.masterdrilling.sgsramd.service;

import com.masterdrilling.sgsramd.dto.request.RegistrarHerramientaRequest;
import com.masterdrilling.sgsramd.dto.response.DashboardStockResponse;
import com.masterdrilling.sgsramd.dto.response.FichaHerramientaResponse;
import com.masterdrilling.sgsramd.exception.BadRequestException;
import com.masterdrilling.sgsramd.exception.RecursoNoEncontradoException;
import com.masterdrilling.sgsramd.model.entity.Almacenista;
import com.masterdrilling.sgsramd.model.entity.Herramienta;
import com.masterdrilling.sgsramd.model.entity.Usuario;
import com.masterdrilling.sgsramd.model.enums.CategoriaHerramienta;
import com.masterdrilling.sgsramd.repository.AlmacenistaRepository;
import com.masterdrilling.sgsramd.repository.HerramientaRepository;
import com.masterdrilling.sgsramd.repository.RegistroRepository;
import com.masterdrilling.sgsramd.repository.UsuarioRepository;
import com.masterdrilling.sgsramd.service.impl.InventarioServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

// Pruebas unitarias para logica de stock de panol y alta formal (RF33, RF35, RF44)
@ExtendWith(MockitoExtension.class)
class InventarioServiceTest {

    @Mock
    private HerramientaRepository herramientaRepository;

    @Mock
    private AlmacenistaRepository almacenistaRepository;

    @Mock
    private UsuarioRepository usuarioRepository;

    @Mock
    private RegistroRepository registroRepository;

    @InjectMocks
    private InventarioServiceImpl inventarioService;

    private Herramienta herramienta;
    private Usuario usuarioAlmacen;
    private Almacenista almacenista;

    @BeforeEach
    void setUp() {
        herramienta = Herramienta.builder()
                .codHerramienta("HER-TOR-004")
                .nombreHerramienta("Torquimetro Industrial")
                .marcaHerramienta("Proto")
                .categoria("Manuales")
                .estadoActual("Disponible")
                .build();

        usuarioAlmacen = Usuario.builder()
                .idUsuario(2L)
                .dni("45829104")
                .correoCorporativo("marcos.ramos@masterdrilling.com")
                .build();

        almacenista = Almacenista.builder()
                .dniAlmacenista("45829104")
                .nombreAlmacenista("Marcos Aurelio Ramos")
                .sedeAsignada("Taller Lurin")
                .build();
    }

    @Test
    @DisplayName("Debe procesar la consulta agrupada y devolver las metricas exactas del dashboard (RF33)")
    void testObtenerMetricasDashboard_Exito() {
        List<Object[]> resultados = new ArrayList<>();
        resultados.add(new Object[]{"Disponible", 142L});
        resultados.add(new Object[]{"Prestada", 18L});
        resultados.add(new Object[]{"En Mora", 3L});
        resultados.add(new Object[]{"En Mantenimiento", 5L});
        resultados.add(new Object[]{"Extraviada", 1L});

        when(herramientaRepository.contarHerramientasPorEstado()).thenReturn(resultados);

        DashboardStockResponse dashboard = inventarioService.obtenerMetricasDashboard();

        assertNotNull(dashboard);
        assertEquals(142, dashboard.getTotalDisponibles());
        assertEquals(18, dashboard.getTotalPrestadas());
        assertEquals(3, dashboard.getTotalEnMora());
        assertEquals(5, dashboard.getTotalEnMantenimiento());
        assertEquals(1, dashboard.getTotalExtraviadas());
    }

    @Test
    @DisplayName("Debe retornar la ficha de herramienta cuando el codigo existe (RF35)")
    void testConsultarHerramientaPorCodigo_Exito() {
        when(herramientaRepository.findByCodHerramienta("HER-TOR-004")).thenReturn(Optional.of(herramienta));

        FichaHerramientaResponse ficha = inventarioService.consultarHerramientaPorCodigo("HER-TOR-004");

        assertNotNull(ficha);
        assertEquals("HER-TOR-004", ficha.getCodHerramienta());
        assertEquals("Proto", ficha.getMarcaHerramienta());
        assertEquals("Disponible", ficha.getEstadoActual());
    }

    @Test
    @DisplayName("Debe lanzar RecursoNoEncontradoException si la herramienta no existe")
    void testConsultarHerramientaPorCodigo_NoExiste() {
        when(herramientaRepository.findByCodHerramienta("HER-INEXISTENTE")).thenReturn(Optional.empty());

        assertThrows(RecursoNoEncontradoException.class, () ->
                inventarioService.consultarHerramientaPorCodigo("HER-INEXISTENTE"));
    }

    @Test
    @DisplayName("Debe registrar herramienta y crear ficha de registro de ingreso formal (RF44)")
    void testRegistrarNuevaHerramienta_Exito() {
        RegistrarHerramientaRequest request = RegistrarHerramientaRequest.builder()
                .codHerramienta("HER-LLAV-099")
                .nombreHerramienta("Juego de Llaves")
                .marcaHerramienta("Stanley")
                .categoria(CategoriaHerramienta.MANUALES)
                .build();

        when(herramientaRepository.existsById("HER-LLAV-099")).thenReturn(false);
        when(usuarioRepository.findByCorreoCorporativo(anyString())).thenReturn(Optional.of(usuarioAlmacen));
        when(almacenistaRepository.findByDniAlmacenista(anyString())).thenReturn(Optional.of(almacenista));
        when(herramientaRepository.save(any(Herramienta.class))).thenAnswer(i -> i.getArgument(0));

        FichaHerramientaResponse ficha = inventarioService.registrarNuevaHerramienta(request, "marcos.ramos@masterdrilling.com");

        assertNotNull(ficha);
        assertEquals("HER-LLAV-099", ficha.getCodHerramienta());
        assertEquals("Disponible", ficha.getEstadoActual());
        verify(registroRepository, times(1)).save(any());
    }

    @Test
    @DisplayName("Debe lanzar BadRequestException si el codigo de herramienta ya existe")
    void testRegistrarNuevaHerramienta_Duplicada() {
        RegistrarHerramientaRequest request = RegistrarHerramientaRequest.builder()
                .codHerramienta("HER-TOR-004")
                .nombreHerramienta("Torquimetro")
                .marcaHerramienta("Proto")
                .categoria(CategoriaHerramienta.MANUALES)
                .build();

        when(herramientaRepository.existsById("HER-TOR-004")).thenReturn(true);

        assertThrows(BadRequestException.class, () ->
                inventarioService.registrarNuevaHerramienta(request, "marcos.ramos@masterdrilling.com"));

        verify(herramientaRepository, never()).save(any());
        verify(registroRepository, never()).save(any());
    }
}