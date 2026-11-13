package com.masterdrilling.sgsramd.controller;

import com.masterdrilling.sgsramd.dto.request.ActualizarPerfilRequest;
import com.masterdrilling.sgsramd.dto.request.CrearUsuarioRequest;
import com.masterdrilling.sgsramd.dto.request.LoginRequest;
import com.masterdrilling.sgsramd.dto.response.LoginResponse;
import com.masterdrilling.sgsramd.dto.response.MensajeGenericoResponse;
import com.masterdrilling.sgsramd.dto.response.SolicitudRecuperacionResponse;
import com.masterdrilling.sgsramd.dto.response.UsuarioResumenResponse;
import com.masterdrilling.sgsramd.model.enums.EstadoCuenta;
import com.masterdrilling.sgsramd.model.enums.EstadoRecuperacion;
import com.masterdrilling.sgsramd.model.enums.RolUsuario;
import com.masterdrilling.sgsramd.service.IAutenticacionService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

// Endpoints de autenticacion, recuperacion, perfiles y gestion administrativa de usuarios (RF01-RF08)
@RestController
@RequestMapping("/api/v1/auth")
public class AutenticacionController {

    private final IAutenticacionService autenticacionService;

    public AutenticacionController(IAutenticacionService autenticacionService) {
        this.autenticacionService = autenticacionService;
    }

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> iniciarSesion(@Valid @RequestBody LoginRequest request,
            HttpServletRequest httpRequest) {
        String ipOrigen = httpRequest.getRemoteAddr();
        return ResponseEntity.ok(autenticacionService.autenticar(request, ipOrigen));
    }

    @PostMapping(value = "/recuperar-clave", consumes = { MediaType.MULTIPART_FORM_DATA_VALUE,
            MediaType.APPLICATION_FORM_URLENCODED_VALUE, MediaType.ALL_VALUE })
    public ResponseEntity<MensajeGenericoResponse> recuperarClave(
            @RequestParam(value = "correo", required = false) String correo,
            @RequestParam(value = "dni", required = false) String dni,
            @RequestParam(value = "telefono", required = false) String telefono,
            @RequestParam(value = "motivo", required = false) String motivo,
            @RequestPart(value = "fotoSelfie", required = false) MultipartFile fotoSelfie,
            HttpServletRequest httpRequest) {
        String ip = httpRequest.getRemoteAddr();
        if (dni != null && !dni.isBlank() && telefono != null && !telefono.isBlank()) {
            return ResponseEntity.ok(autenticacionService.solicitarRecuperacionClavePorDniYTelefono(dni, telefono,
                    motivo, fotoSelfie, ip));
        }
        if (correo != null && !correo.isBlank()) {
            return ResponseEntity.ok(autenticacionService.solicitarRecuperacionClave(correo, motivo, ip));
        }
        throw new com.masterdrilling.sgsramd.exception.BadRequestException(
                "Debe proporcionar DNI y telefono, o correo corporativo para solicitar recuperacion");
    }

    // Bandeja de solicitudes de recuperacion para el Administrador (estado
    // opcional)
    @GetMapping("/recuperaciones")
    public ResponseEntity<List<SolicitudRecuperacionResponse>> listarRecuperaciones(
            @RequestParam(value = "estado", required = false) EstadoRecuperacion estado) {
        return ResponseEntity.ok(autenticacionService.listarSolicitudesRecuperacion(estado));
    }

    @PutMapping("/recuperaciones/{id}/aprobar")
    public ResponseEntity<MensajeGenericoResponse> aprobarRecuperacion(
            @PathVariable("id") Long id,
            @RequestParam("nuevaClave") String nuevaClave,
            @RequestParam("correoAdmin") String correoAdmin,
            HttpServletRequest httpRequest) {
        return ResponseEntity.ok(autenticacionService.aprobarRecuperacionClave(id, nuevaClave, correoAdmin,
                httpRequest.getRemoteAddr()));
    }

    @PutMapping("/recuperaciones/{id}/rechazar")
    public ResponseEntity<MensajeGenericoResponse> rechazarRecuperacion(
            @PathVariable("id") Long id,
            @RequestParam("motivo") String motivo,
            @RequestParam("correoAdmin") String correoAdmin,
            HttpServletRequest httpRequest) {
        return ResponseEntity.ok(
                autenticacionService.rechazarRecuperacionClave(id, motivo, correoAdmin, httpRequest.getRemoteAddr()));
    }

    @PutMapping("/perfil")
    public ResponseEntity<MensajeGenericoResponse> actualizarPerfil(
            @RequestParam("correo") String correo,
            @Valid @RequestBody ActualizarPerfilRequest request) {
        return ResponseEntity.ok(autenticacionService.actualizarPerfil(correo, request));
    }

    @PutMapping("/cambiar-clave")
    public ResponseEntity<MensajeGenericoResponse> cambiarContrasenaPropia(
            @RequestParam("correo") String correo,
            @RequestParam("claveActual") String claveActual,
            @RequestParam("claveNueva") String claveNueva,
            HttpServletRequest httpRequest) {
        return ResponseEntity.ok(autenticacionService.cambiarContrasenaPropia(correo, claveActual, claveNueva,
                httpRequest.getRemoteAddr()));
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
            @RequestParam(value = "correoAdmin", required = false) String correoAdmin,
            HttpServletRequest httpRequest) {
        return ResponseEntity.ok(autenticacionService.cambiarEstadoCuentaPorDni(dni, nuevoEstado, correoAdmin,
                httpRequest.getRemoteAddr()));
    }

    @PutMapping("/usuarios/dni/{dni}/reset-clave")
    public ResponseEntity<MensajeGenericoResponse> resetearClavePorDni(
            @PathVariable("dni") String dni,
            @RequestParam("nuevaClave") String nuevaClave,
            @RequestParam(value = "correoAdmin", required = false) String correoAdmin,
            HttpServletRequest httpRequest) {
        return ResponseEntity.ok(
                autenticacionService.resetearClavePorDni(dni, nuevaClave, correoAdmin, httpRequest.getRemoteAddr()));
    }

    @PutMapping("/usuarios/dni/{dni}")
    public ResponseEntity<MensajeGenericoResponse> actualizarUsuarioPorDni(
            @PathVariable("dni") String dni,
            @Valid @RequestBody ActualizarPerfilRequest request) {
        return ResponseEntity.ok(autenticacionService.actualizarUsuarioPorDni(dni, request));
    }
}
