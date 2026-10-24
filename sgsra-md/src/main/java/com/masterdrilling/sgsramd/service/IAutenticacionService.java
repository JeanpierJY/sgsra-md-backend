package com.masterdrilling.sgsramd.service;

import com.masterdrilling.sgsramd.dto.request.ActualizarPerfilRequest;
import com.masterdrilling.sgsramd.dto.request.LoginRequest;
import com.masterdrilling.sgsramd.dto.response.LoginResponse;
import com.masterdrilling.sgsramd.dto.response.MensajeGenericoResponse;

// Contrato de autenticacion, recuperacion y perfiles (RF01-RF07)
public interface IAutenticacionService {
    LoginResponse autenticar(LoginRequest request, String ipOrigen);
    MensajeGenericoResponse solicitarRecuperacionClave(String correo);
    MensajeGenericoResponse actualizarPerfil(String correo, ActualizarPerfilRequest request);
}