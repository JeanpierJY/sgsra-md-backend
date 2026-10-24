package com.masterdrilling.sgsramd.service;

import com.masterdrilling.sgsramd.dto.request.ActualizarPerfilRequest;
import com.masterdrilling.sgsramd.dto.request.CrearUsuarioRequest;
import com.masterdrilling.sgsramd.dto.request.LoginRequest;
import com.masterdrilling.sgsramd.dto.response.LoginResponse;
import com.masterdrilling.sgsramd.dto.response.MensajeGenericoResponse;
import com.masterdrilling.sgsramd.dto.response.UsuarioResumenResponse;
import com.masterdrilling.sgsramd.model.enums.EstadoCuenta;
import com.masterdrilling.sgsramd.model.enums.RolUsuario;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

// Contrato de autenticacion, recuperacion, perfiles y administracion de usuarios
public interface IAutenticacionService {
    LoginResponse autenticar(LoginRequest request, String ipOrigen);
    MensajeGenericoResponse solicitarRecuperacionClave(String correo);
    MensajeGenericoResponse actualizarPerfil(String correo, ActualizarPerfilRequest request);
    
    // Metodos para gestion de usuarios
    Page<UsuarioResumenResponse> listarUsuarios(RolUsuario rol, Pageable pageable);
    MensajeGenericoResponse registrarUsuario(CrearUsuarioRequest request, String ipOrigen);
    MensajeGenericoResponse cambiarEstadoCuenta(Long idUsuario, EstadoCuenta nuevoEstado, String ipOrigen);
}