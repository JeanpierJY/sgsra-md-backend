package com.masterdrilling.sgsramd.service;

import com.masterdrilling.sgsramd.DAO.Mecanico_DAO;
import com.masterdrilling.sgsramd.DAO.Usuario_DAO;
import com.masterdrilling.sgsramd.dto.request.LoginRequest;
import com.masterdrilling.sgsramd.dto.response.LoginResponse;
import com.masterdrilling.sgsramd.exception.AccesoDenegadoException;
import com.masterdrilling.sgsramd.exception.CuentaBloqueadaException;
import com.masterdrilling.sgsramd.model.entity.Usuario;
import com.masterdrilling.sgsramd.model.enums.EstadoCuenta;
import com.masterdrilling.sgsramd.model.enums.RolUsuario;
import com.masterdrilling.sgsramd.service.impl.AutenticacionServiceImpl;
import com.masterdrilling.sgsramd.util.JwtTokenUtil;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

// Pruebas unitarias para logica de autenticacion y control de intentos fallidos (RF01, RF06)
@ExtendWith(MockitoExtension.class)
class AutenticacionServiceTest {

    @Mock
    private Usuario_DAO usuarioRepository;

    @Mock
    private Mecanico_DAO mecanicoRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @Mock
    private JwtTokenUtil jwtTokenUtil;

    @Mock
    private IAuditoriaService auditoriaService;

    @InjectMocks
    private AutenticacionServiceImpl autenticacionService;

    private Usuario usuarioPrueba;
    private LoginRequest loginRequest;

    @BeforeEach
    void setUp() {
        usuarioPrueba = Usuario.builder()
                .idUsuario(1L)
                .dni("75859812")
                .nombre("Carlos Mendoza")
                .correoCorporativo("carlos.mendoza@masterdrilling.com")
                .contrasenaHash("$2a$10$hashedPassword")
                .rol(RolUsuario.MECANICO)
                .estadoCuenta(EstadoCuenta.ACTIVO)
                .intentosFallidos(0)
                .build();

        loginRequest = LoginRequest.builder()
                .correoCorporativo("carlos.mendoza@masterdrilling.com")
                .contrasena("Mecanico123*")
                .build();
    }

    @Test
    @DisplayName("Debe autenticar exitosamente y retornar token cuando las credenciales son validas")
    void testAutenticar_Exito() {
        when(usuarioRepository.findByCorreoCorporativo(anyString())).thenReturn(Optional.of(usuarioPrueba));
        when(passwordEncoder.matches(anyString(), anyString())).thenReturn(true);
        when(jwtTokenUtil.generarToken(anyString(), any(RolUsuario.class))).thenReturn("token.jwt.valido");

        LoginResponse response = autenticacionService.autenticar(loginRequest, "127.0.0.1");

        assertNotNull(response);
        assertEquals("token.jwt.valido", response.getTokenJwt());
        assertEquals("75859812", response.getDni());
        assertEquals(0, usuarioPrueba.getIntentosFallidos());
        verify(usuarioRepository, times(1)).save(usuarioPrueba);
        verify(auditoriaService, times(1)).registrarAsiento(eq("LOGIN_EXITOSO"), eq(1L), eq("SESION_INICIADA"), anyString());
    }

    @Test
    @DisplayName("Debe incrementar intentos fallidos y lanzar excepcion cuando la clave no coincide")
    void testAutenticar_ClaveIncorrecta() {
        when(usuarioRepository.findByCorreoCorporativo(anyString())).thenReturn(Optional.of(usuarioPrueba));
        when(passwordEncoder.matches(anyString(), anyString())).thenReturn(false);

        assertThrows(AccesoDenegadoException.class, () -> autenticacionService.autenticar(loginRequest, "127.0.0.1"));

        assertEquals(1, usuarioPrueba.getIntentosFallidos());
        verify(usuarioRepository, times(1)).save(usuarioPrueba);
    }

    @Test
    @DisplayName("Debe bloquear la cuenta al alcanzar 3 intentos fallidos consecutivos (RF06)")
    void testAutenticar_BloqueoPorTresIntentos() {
        usuarioPrueba.setIntentosFallidos(2);
        when(usuarioRepository.findByCorreoCorporativo(anyString())).thenReturn(Optional.of(usuarioPrueba));
        when(passwordEncoder.matches(anyString(), anyString())).thenReturn(false);

        assertThrows(CuentaBloqueadaException.class, () -> autenticacionService.autenticar(loginRequest, "127.0.0.1"));

        assertEquals(3, usuarioPrueba.getIntentosFallidos());
        assertEquals(EstadoCuenta.BLOQUEADO, usuarioPrueba.getEstadoCuenta());
        verify(usuarioRepository, times(1)).save(usuarioPrueba);
        verify(auditoriaService, times(1)).registrarAsiento(eq("BLOQUEO_CUENTA"), eq(1L), eq("BLOQUEO_POR_INTENTOS"), anyString());
    }
}