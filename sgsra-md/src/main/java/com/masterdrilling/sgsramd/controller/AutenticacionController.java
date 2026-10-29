package com.masterdrilling.sgsramd.controller;

import com.masterdrilling.sgsramd.dto.request.ActualizarPerfilRequest;
import com.masterdrilling.sgsramd.dto.request.CrearUsuarioRequest;
import com.masterdrilling.sgsramd.dto.request.LoginRequest;
import com.masterdrilling.sgsramd.dto.response.LoginResponse;
import com.masterdrilling.sgsramd.dto.response.MensajeGenericoResponse;
import com.masterdrilling.sgsramd.dto.response.UsuarioResumenResponse;
import com.masterdrilling.sgsramd.model.enums.EstadoCuenta;
import com.masterdrilling.sgsramd.model.enums.RolUsuario;
import com.masterdrilling.sgsramd.service.IAutenticacionService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

// Endpoints de autenticacion, recuperacion, perfiles y gestion administrativa de usuarios (RF01-RF08)
@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AutenticacionController {

    private final IAutenticacionService autenticacionService;

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> iniciarSesion(@Valid @RequestBody LoginRequest request, HttpServletRequest httpRequest) {
        String ipOrigen = httpRequest.getRemoteAddr();
        return ResponseEntity.ok(autenticacionService.autenticar(request, ipOrigen));
    }

    @PostMapping("/recuperar-clave")
    public ResponseEntity<MensajeGenericoResponse> recuperarClave(@RequestParam("correo") String correo) {
        return ResponseEntity.ok(autenticacionService.solicitarRecuperacionClave(correo));
    }

    @PutMapping("/perfil")
    public ResponseEntity<MensajeGenericoResponse> actualizarPerfil(@RequestParam("correo") String correo,
                                                                    @Valid @RequestBody ActualizarPerfilRequest request) {
        return ResponseEntity.ok(autenticacionService.actualizarPerfil(correo, request));
    }

    // Endpoints administrativos de gestion de usuarios
    @GetMapping("/usuarios")
    public ResponseEntity<Page<UsuarioResumenResponse>> listarUsuarios(
            @RequestParam(value = "rol", required = false) RolUsuario rol,
            Pageable pageable) {
        return ResponseEntity.ok(autenticacionService.listarUsuarios(rol, pageable));
    }

    @PostMapping("/usuarios")
    public ResponseEntity<MensajeGenericoResponse> registrarUsuario(
            @Valid @RequestBody CrearUsuarioRequest request,
            HttpServletRequest httpRequest) {
        String ipOrigen = httpRequest.getRemoteAddr();
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(autenticacionService.registrarUsuario(request, ipOrigen));
    }

    @PutMapping("/usuarios/{idUsuario}/estado")
    public ResponseEntity<MensajeGenericoResponse> cambiarEstadoCuenta(
            @PathVariable("idUsuario") Long idUsuario,
            @RequestParam("nuevoEstado") EstadoCuenta nuevoEstado,
            HttpServletRequest httpRequest) {
        String ipOrigen = httpRequest.getRemoteAddr();
        return ResponseEntity.ok(autenticacionService.cambiarEstadoCuenta(idUsuario, nuevoEstado, ipOrigen));
    }

    @PutMapping("/usuarios/dni/{dni}/estado")
    public ResponseEntity<MensajeGenericoResponse> cambiarEstadoPorDni(
            @PathVariable("dni") String dni,
            @RequestParam("nuevoEstado") EstadoCuenta nuevoEstado,
            HttpServletRequest httpRequest) {
        return ResponseEntity.ok(autenticacionService.cambiarEstadoCuentaPorDni(dni, nuevoEstado, httpRequest.getRemoteAddr()));
    }

    @PutMapping("/usuarios/dni/{dni}")
    public ResponseEntity<MensajeGenericoResponse> actualizarUsuarioPorDni(
            @PathVariable("dni") String dni,
            @Valid @RequestBody ActualizarPerfilRequest request) {
        return ResponseEntity.ok(autenticacionService.actualizarUsuarioPorDni(dni, request));
    }
}