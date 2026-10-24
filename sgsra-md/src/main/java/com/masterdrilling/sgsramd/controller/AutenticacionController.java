package com.masterdrilling.sgsramd.controller;

import com.masterdrilling.sgsramd.dto.request.ActualizarPerfilRequest;
import com.masterdrilling.sgsramd.dto.request.LoginRequest;
import com.masterdrilling.sgsramd.dto.response.LoginResponse;
import com.masterdrilling.sgsramd.dto.response.MensajeGenericoResponse;
import com.masterdrilling.sgsramd.service.IAutenticacionService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

// Endpoints de autenticacion, recuperacion y gestion de perfiles (RF01-RF07)
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
}