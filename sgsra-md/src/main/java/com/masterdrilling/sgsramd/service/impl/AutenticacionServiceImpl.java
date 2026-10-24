package com.masterdrilling.sgsramd.service.impl;

import com.masterdrilling.sgsramd.dto.request.ActualizarPerfilRequest;
import com.masterdrilling.sgsramd.dto.request.LoginRequest;
import com.masterdrilling.sgsramd.dto.response.LoginResponse;
import com.masterdrilling.sgsramd.dto.response.MensajeGenericoResponse;
import com.masterdrilling.sgsramd.exception.AccesoDenegadoException;
import com.masterdrilling.sgsramd.exception.CuentaBloqueadaException;
import com.masterdrilling.sgsramd.exception.RecursoNoEncontradoException;
import com.masterdrilling.sgsramd.model.entity.Mecanico;
import com.masterdrilling.sgsramd.model.entity.Usuario;
import com.masterdrilling.sgsramd.model.enums.EstadoCuenta;
import com.masterdrilling.sgsramd.repository.MecanicoRepository;
import com.masterdrilling.sgsramd.repository.UsuarioRepository;
import com.masterdrilling.sgsramd.service.IAuditoriaService;
import com.masterdrilling.sgsramd.service.IAutenticacionService;
import com.masterdrilling.sgsramd.util.JwtTokenUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AutenticacionServiceImpl implements IAutenticacionService {

    private final UsuarioRepository usuarioRepository;
    private final MecanicoRepository mecanicoRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenUtil jwtTokenUtil;
    private final IAuditoriaService auditoriaService;

    private static final int UMBRAL_BLOQUEO_INTENTOS = 3;

    @Override
    @Transactional
    public LoginResponse autenticar(LoginRequest request, String ipOrigen) {
        Usuario usuario = usuarioRepository.findByCorreoCorporativo(request.getCorreoCorporativo().trim().toLowerCase())
                .orElseThrow(() -> new AccesoDenegadoException("Credenciales no validas"));

        if (usuario.getEstadoCuenta() == EstadoCuenta.BLOQUEADO) {
            auditoriaService.registrarAsiento("LOGIN_FALLIDO", usuario.getIdUsuario(), "INTENTO_CUENTA_BLOQUEADA", ipOrigen);
            throw new CuentaBloqueadaException("Cuenta bloqueada temporalmente por exceso de intentos fallidos. Contacte a soporte");
        }

        if (usuario.getEstadoCuenta() == EstadoCuenta.INACTIVO) {
            throw new AccesoDenegadoException("La cuenta de usuario se encuentra suspendida o dada de baja");
        }

        if (!passwordEncoder.matches(request.getContrasena(), usuario.getContrasenaHash())) {
            usuario.setIntentosFallidos(usuario.getIntentosFallidos() + 1);
            if (usuario.getIntentosFallidos() >= UMBRAL_BLOQUEO_INTENTOS) {
                usuario.setEstadoCuenta(EstadoCuenta.BLOQUEADO);
                usuarioRepository.save(usuario);
                auditoriaService.registrarAsiento("BLOQUEO_CUENTA", usuario.getIdUsuario(), "BLOQUEO_POR_INTENTOS", ipOrigen);
                throw new CuentaBloqueadaException("Cuenta bloqueada tras 3 intentos fallidos consecutivos");
            }
            usuarioRepository.save(usuario);
            auditoriaService.registrarAsiento("LOGIN_FALLIDO", usuario.getIdUsuario(), "CONTRASENA_INCORRECTA", ipOrigen);
            throw new AccesoDenegadoException("Credenciales no validas. Intentos restantes: " + (UMBRAL_BLOQUEO_INTENTOS - usuario.getIntentosFallidos()));
        }

        // Exito de autenticacion
        usuario.setIntentosFallidos(0);
        usuarioRepository.save(usuario);

        String token = jwtTokenUtil.generarToken(usuario.getCorreoCorporativo(), usuario.getRol());
        auditoriaService.registrarAsiento("LOGIN_EXITOSO", usuario.getIdUsuario(), "SESION_INICIADA", ipOrigen);

        return LoginResponse.builder()
                .tokenJwt(token)
                .tipoToken("Bearer")
                .idUsuario(usuario.getIdUsuario())
                .dni(usuario.getDni())
                .nombre(usuario.getNombre())
                .correoCorporativo(usuario.getCorreoCorporativo())
                .rol(usuario.getRol())
                .build();
    }

    @Override
    public MensajeGenericoResponse solicitarRecuperacionClave(String correo) {
        Usuario usuario = usuarioRepository.findByCorreoCorporativo(correo.trim().toLowerCase())
                .orElseThrow(() -> new RecursoNoEncontradoException("No existe cuenta corporativa vinculada al correo ingresado"));

        return MensajeGenericoResponse.builder()
                .exito(true)
                .mensaje("Se ha enviado un enlace seguro de recuperacion a la bandeja institucional de " + usuario.getCorreoCorporativo())
                .dato(null)
                .build();
    }

    @Override
    @Transactional
    public MensajeGenericoResponse actualizarPerfil(String correo, ActualizarPerfilRequest request) {
        Usuario usuario = usuarioRepository.findByCorreoCorporativo(correo)
                .orElseThrow(() -> new RecursoNoEncontradoException("Usuario no encontrado"));

        usuario.setNombre(request.getNombre().trim());
        usuarioRepository.save(usuario);

        mecanicoRepository.findByDniMecanico(usuario.getDni()).ifPresent(m -> {
            m.setNombreMecanico(request.getNombre().trim());
            m.setTelefono(request.getTelefono().trim());
            mecanicoRepository.save(m);
        });

        return MensajeGenericoResponse.builder()
                .exito(true)
                .mensaje("Perfil de operario actualizado exitosamente")
                .dato(null)
                .build();
    }
}