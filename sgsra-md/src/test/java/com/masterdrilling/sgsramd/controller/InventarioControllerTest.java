package com.masterdrilling.sgsramd.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.masterdrilling.sgsramd.dto.request.RegistrarHerramientaRequest;
import com.masterdrilling.sgsramd.dto.response.DashboardStockResponse;
import com.masterdrilling.sgsramd.dto.response.FichaHerramientaResponse;
import com.masterdrilling.sgsramd.exception.GlobalExceptionHandler;
import com.masterdrilling.sgsramd.model.enums.CategoriaHerramienta;
import com.masterdrilling.sgsramd.service.IInventarioService;
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

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

// Pruebas unitarias para endpoints de control de herramientas y dashboard (RF33, RF35, RF44)
@ExtendWith(MockitoExtension.class)
class InventarioControllerTest {

    private MockMvc mockMvc;

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Mock
    private IInventarioService inventarioService;

    @InjectMocks
    private InventarioController inventarioController;

    @BeforeEach
    void setUp() {
        mockMvc = MockMvcBuilders.standaloneSetup(inventarioController)
                .setControllerAdvice(new GlobalExceptionHandler())
                .build();
    }

    @Test
    @DisplayName("GET /api/v1/inventario/dashboard debe retornar contadores de stock con 200 OK")
    void testObtenerDashboard_Ok() throws Exception {
        DashboardStockResponse dashboard = DashboardStockResponse.builder()
                .totalDisponibles(10L)
                .totalPrestadas(2L)
                .totalEnMora(1L)
                .totalEnMantenimiento(0L)
                .totalExtraviadas(0L)
                .build();

        when(inventarioService.obtenerMetricasDashboard()).thenReturn(dashboard);

        mockMvc.perform(get("/api/v1/inventario/dashboard"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalDisponibles").value(10))
                .andExpect(jsonPath("$.totalPrestadas").value(2))
                .andExpect(jsonPath("$.totalEnMora").value(1));
    }

    @Test
    @DisplayName("GET /api/v1/inventario/herramientas/{cod} debe retornar ficha de activo con 200 OK")
    void testConsultarHerramientaPorCodigo_Ok() throws Exception {
        FichaHerramientaResponse ficha = FichaHerramientaResponse.builder()
                .codHerramienta("HER-TOR-004")
                .nombreHerramienta("Torquimetro Industrial")
                .marcaHerramienta("Proto")
                .categoria("Manuales")
                .estadoActual("Disponible")
                .build();

        when(inventarioService.consultarHerramientaPorCodigo("HER-TOR-004")).thenReturn(ficha);

        mockMvc.perform(get("/api/v1/inventario/herramientas/HER-TOR-004"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.codHerramienta").value("HER-TOR-004"))
                .andExpect(jsonPath("$.estadoActual").value("Disponible"));
    }

    @Test
    @DisplayName("POST /api/v1/inventario/herramientas debe registrar activo nuevo y responder 201 CREATED")
    void testRegistrarHerramienta_Ok() throws Exception {
        RegistrarHerramientaRequest request = RegistrarHerramientaRequest.builder()
                .codHerramienta("HER-BOM-099")
                .nombreHerramienta("Bomba Hidraulica de Mano")
                .marcaHerramienta("Enerpac")
                .categoria(CategoriaHerramienta.HIDRAULICAS)
                .build();

        FichaHerramientaResponse response = FichaHerramientaResponse.builder()
                .codHerramienta("HER-BOM-099")
                .nombreHerramienta("Bomba Hidraulica de Mano")
                .marcaHerramienta("Enerpac")
                .categoria("Hidraulicas")
                .estadoActual("Disponible")
                .build();

        when(inventarioService.registrarNuevaHerramienta(any(RegistrarHerramientaRequest.class), eq("marcos.ramos@masterdrilling.com")))
                .thenReturn(response);

        mockMvc.perform(post("/api/v1/inventario/herramientas")
                        .param("correoAlmacenista", "marcos.ramos@masterdrilling.com")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.codHerramienta").value("HER-BOM-099"))
                .andExpect(jsonPath("$.categoria").value("Hidraulicas"));
    }
}