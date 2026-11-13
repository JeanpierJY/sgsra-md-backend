package com.masterdrilling.sgsramd.service;

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
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;

// Contrato de autenticacion, recuperacion, perfiles y administracion de usuarios
public interface IAutenticacionService {
    LoginResponse autenticar(LoginRequest request, String ipOrigen);
    MensajeGenericoResponse solicitarRecuperacionClave(String correo);
    MensajeGenericoResponse solicitarRecuperacionClave(String correo, String motivo, String ipOrigen);
    MensajeGenericoResponse solicitarRecuperacionClavePorDniYTelefono(String dni, String telefono, String motivo, String ipOrigen);
    MensajeGenericoResponse solicitarRecuperacionClavePorDniYTelefono(String dni, String telefono, String motivo, org.springframework.web.multipart.MultipartFile fotoSelfie, String ipOrigen);
    List<SolicitudRecuperacionResponse> listarSolicitudesRecuperacion(EstadoRecuperacion estado);
    MensajeGenericoResponse aprobarRecuperacionClave(Long idRecuperacion, String nuevaClaveTemporal, String correoAdmin, String ipOrigen);
    MensajeGenericoResponse rechazarRecuperacionClave(Long idRecuperacion, String motivoRechazo, String correoAdmin, String ipOrigen);
    MensajeGenericoResponse actualizarPerfil(String correo, ActualizarPerfilRequest request);
    MensajeGenericoResponse cambiarContrasenaPropia(String correo, String claveActual, String claveNueva, String ipOrigen);
    
    // Metodos para gestion de usuarios
    Page<UsuarioResumenResponse> listarUsuarios(RolUsuario rol, Pageable pageable);
    MensajeGenericoResponse registrarUsuario(CrearUsuarioRequest request, String ipOrigen);
    MensajeGenericoResponse cambiarEstadoCuenta(Long idUsuario, EstadoCuenta nuevoEstado, String ipOrigen);
    MensajeGenericoResponse cambiarEstadoCuentaPorDni(String dni, EstadoCuenta nuevoEstado, String ipOrigen);
    MensajeGenericoResponse cambiarEstadoCuentaPorDni(String dni, EstadoCuenta nuevoEstado, String correoAdmin, String ipOrigen);
    MensajeGenericoResponse resetearClavePorDni(String dni, String nuevaClave, String correoAdmin, String ipOrigen);
    MensajeGenericoResponse actualizarUsuarioPorDni(String dni, ActualizarPerfilRequest request);
}
