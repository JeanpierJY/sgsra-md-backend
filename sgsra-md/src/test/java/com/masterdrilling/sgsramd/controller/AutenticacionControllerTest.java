package com.masterdrilling.sgsramd.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.masterdrilling.sgsramd.dto.request.LoginRequest;
import com.masterdrilling.sgsramd.dto.response.LoginResponse;
import com.masterdrilling.sgsramd.exception.GlobalExceptionHandler;
import com.masterdrilling.sgsramd.model.enums.RolUsuario;
import com.masterdrilling.sgsramd.service.IAutenticacionService;
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
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

// Pruebas unitarias de capa web para el controlador de autenticacion (RF01)
@ExtendWith(MockitoExtension.class)
class AutenticacionControllerTest {

    private MockMvc mockMvc;

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Mock
    private IAutenticacionService autenticacionService;

    @InjectMocks
    private AutenticacionController autenticacionController;

    @BeforeEach
    void setUp() {
        mockMvc = MockMvcBuilders.standaloneSetup(autenticacionController)
                .setControllerAdvice(new GlobalExceptionHandler())
                .build();
    }

    @Test
    @DisplayName("POST /api/v1/auth/login debe responder 200 OK con token cuando las credenciales son validas")
    void testIniciarSesion_Ok() throws Exception {
        LoginRequest request = LoginRequest.builder()
                .correoCorporativo("carlos.mendoza@masterdrilling.com")
                .contrasena("Mecanico123*")
                .build();

        LoginResponse response = LoginResponse.builder()
                .tokenJwt("token.jwt.valido")
                .tipoToken("Bearer")
                .idUsuario(1L)
                .dni("75859812")
                .nombre("Carlos Mendoza")
                .correoCorporativo("carlos.mendoza@masterdrilling.com")
                .rol(RolUsuario.MECANICO)
                .build();

        when(autenticacionService.autenticar(any(LoginRequest.class), anyString())).thenReturn(response);

        mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.tokenJwt").value("token.jwt.valido"))
                .andExpect(jsonPath("$.dni").value("75859812"))
                .andExpect(jsonPath("$.rol").value("MECANICO"));
    }

    @Test
    @DisplayName("POST /api/v1/auth/login debe responder 400 Bad Request si el correo no cumple formato corporativo")
    void testIniciarSesion_CorreoInvalido() throws Exception {
        LoginRequest request = LoginRequest.builder()
                .correoCorporativo("formato-invalido")
                .contrasena("Mecanico123*")
                .build();

        mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("Error de validacion de campos"));
    }
}