package com.masterdrilling.sgsramd.service.impl;

import com.masterdrilling.sgsramd.DAO.*;
import com.masterdrilling.sgsramd.dto.request.ActualizarPerfilRequest;
import com.masterdrilling.sgsramd.dto.request.CrearUsuarioRequest;
import com.masterdrilling.sgsramd.dto.request.LoginRequest;
import com.masterdrilling.sgsramd.dto.response.LoginResponse;
import com.masterdrilling.sgsramd.dto.response.MensajeGenericoResponse;
import com.masterdrilling.sgsramd.dto.response.SolicitudRecuperacionResponse;
import com.masterdrilling.sgsramd.dto.response.UsuarioResumenResponse;
import com.masterdrilling.sgsramd.exception.AccesoDenegadoException;
import com.masterdrilling.sgsramd.exception.BadRequestException;
import com.masterdrilling.sgsramd.exception.CuentaBloqueadaException;
import com.masterdrilling.sgsramd.exception.RecursoNoEncontradoException;
import com.masterdrilling.sgsramd.model.entity.Administrador;
import com.masterdrilling.sgsramd.model.entity.Almacenista;
import com.masterdrilling.sgsramd.model.entity.Mecanico;
import com.masterdrilling.sgsramd.model.entity.SolicitudRecuperacionClave;
import com.masterdrilling.sgsramd.model.entity.Usuario;
import com.masterdrilling.sgsramd.model.enums.EstadoCuenta;
import com.masterdrilling.sgsramd.model.enums.EstadoRecuperacion;
import com.masterdrilling.sgsramd.model.enums.RolUsuario;
import com.masterdrilling.sgsramd.service.IAuditoriaService;
import com.masterdrilling.sgsramd.service.IAutenticacionService;
import com.masterdrilling.sgsramd.service.INotificacionService;
import com.masterdrilling.sgsramd.util.JwtTokenUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class AutenticacionServiceImpl implements IAutenticacionService {

    private final Usuario_DAO usuarioRepository;
    private final Mecanico_DAO mecanicoRepository;
    private final Almacenista_DAO almacenistaRepository;
    private final Administrador_DAO administradorRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenUtil jwtTokenUtil;
    private final IAuditoriaService auditoriaService;
    private final INotificacionService notificacionService;
    private final SolicitudRecuperacionClave_DAO recuperacionRepository;

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
        return solicitarRecuperacionClave(correo, null, "0.0.0.0");
    }

    @Override
    @Transactional
    public MensajeGenericoResponse solicitarRecuperacionClave(String correo, String motivo, String ipOrigen) {
        if (correo == null || correo.isBlank()) {
            throw new BadRequestException("Debe ingresar su correo corporativo");
        }
        Usuario usuario = usuarioRepository.findByCorreoCorporativo(correo.trim().toLowerCase())
                .orElseThrow(() -> new RecursoNoEncontradoException("No existe cuenta corporativa vinculada al correo ingresado"));

        if (usuario.getRol() == RolUsuario.ADMINISTRADOR) {
            throw new AccesoDenegadoException("Las cuentas de Administrador deben gestionar su clave con el area de TI");
        }
        if (recuperacionRepository.existsByDniSolicitanteAndEstado(usuario.getDni(), EstadoRecuperacion.PENDIENTE)) {
            throw new BadRequestException("Ya tiene una solicitud de recuperacion pendiente de revision por Administracion");
        }

        SolicitudRecuperacionClave solicitud = recuperacionRepository.save(SolicitudRecuperacionClave.builder()
                .dniSolicitante(usuario.getDni())
                .nombreSolicitante(usuario.getNombre())
                .correoSolicitante(usuario.getCorreoCorporativo())
                .rolSolicitante(usuario.getRol())
                .motivo(motivo != null && !motivo.isBlank() ? motivo.trim() : "Olvido de contrasena")
                .estado(EstadoRecuperacion.PENDIENTE)
                .fechaSolicitud(LocalDateTime.now())
                .build());

        auditoriaService.registrarAsiento("RECUP_CLAVE_" + solicitud.getIdRecuperacion(), usuario.getIdUsuario(), "SOLICITUD_RECUPERACION_CLAVE", ipOrigen);
        notificacionService.enviarNotificacionConTipo(null, "ADMINISTRADOR", "Solicitud de Recuperacion de Contrasena",
                usuario.getNombre() + " (" + usuario.getRol() + ", DNI " + usuario.getDni() + ") solicita restablecer su contrasena. "
                        + "Solicitud #" + solicitud.getIdRecuperacion() + ". Revisela en Gestionar Personal.",
                "RECUPERACION_CLAVE");

        return MensajeGenericoResponse.builder()
                .exito(true)
                .mensaje("Solicitud de recuperacion #" + solicitud.getIdRecuperacion() + " enviada a Administracion. Sera notificado cuando sea resuelta")
                .dato(solicitud.getIdRecuperacion())
                .build();
    }

    @Override
    @Transactional(readOnly = true)
    public List<SolicitudRecuperacionResponse> listarSolicitudesRecuperacion(EstadoRecuperacion estado) {
        List<SolicitudRecuperacionClave> lista = (estado != null)
                ? recuperacionRepository.findByEstadoOrderByFechaSolicitudAsc(estado)
                : recuperacionRepository.findAllByOrderByFechaSolicitudDesc();
        return lista.stream().map(r -> SolicitudRecuperacionResponse.builder()
                .idRecuperacion(r.getIdRecuperacion())
                .dniSolicitante(r.getDniSolicitante())
                .nombreSolicitante(r.getNombreSolicitante())
                .correoSolicitante(r.getCorreoSolicitante())
                .rolSolicitante(r.getRolSolicitante())
                .motivo(r.getMotivo())
                .estado(r.getEstado())
                .fechaSolicitud(r.getFechaSolicitud())
                .fechaResolucion(r.getFechaResolucion())
                .dniAdministrador(r.getDniAdministrador())
                .observacionAdmin(r.getObservacionAdmin())
                .build()).toList();
    }

    @Override
    @Transactional
    public MensajeGenericoResponse aprobarRecuperacionClave(Long idRecuperacion, String nuevaClaveTemporal, String correoAdmin, String ipOrigen) {
        SolicitudRecuperacionClave solicitud = obtenerRecuperacionPendiente(idRecuperacion);
        Usuario admin = obtenerAdministrador(correoAdmin);

        if (nuevaClaveTemporal == null || nuevaClaveTemporal.trim().length() < 8) {
            throw new BadRequestException("La clave temporal debe tener al menos 8 caracteres");
        }
        Usuario objetivo = usuarioRepository.findByDni(solicitud.getDniSolicitante())
                .orElseThrow(() -> new RecursoNoEncontradoException("El usuario solicitante ya no existe"));

        objetivo.setContrasenaHash(passwordEncoder.encode(nuevaClaveTemporal.trim()));
        objetivo.setIntentosFallidos(0);
        objetivo.setEstadoCuenta(EstadoCuenta.ACTIVO);
        usuarioRepository.save(objetivo);

        solicitud.setEstado(EstadoRecuperacion.APROBADA);
        solicitud.setFechaResolucion(LocalDateTime.now());
        solicitud.setDniAdministrador(admin.getDni());
        solicitud.setObservacionAdmin("Clave temporal asignada");
        recuperacionRepository.save(solicitud);

        auditoriaService.registrarAsiento("RECUP_CLAVE_" + idRecuperacion, admin.getIdUsuario(), "RECUPERACION_CLAVE_APROBADA", ipOrigen);
        notificacionService.enviarNotificacionConTipo(objetivo.getDni(), null, "Recuperacion de Contrasena Aprobada",
                "Administracion aprobo su solicitud #" + idRecuperacion + ". Solicite su clave temporal al administrador "
                        + admin.getNombre() + " y cambiela desde Mi Perfil al ingresar.",
                "RECUPERACION_CLAVE");

        return MensajeGenericoResponse.builder()
                .exito(true)
                .mensaje("Solicitud #" + idRecuperacion + " aprobada. Clave temporal asignada a " + objetivo.getNombre())
                .dato(objetivo.getDni())
                .build();
    }

    @Override
    @Transactional
    public MensajeGenericoResponse rechazarRecuperacionClave(Long idRecuperacion, String motivoRechazo, String correoAdmin, String ipOrigen) {
        SolicitudRecuperacionClave solicitud = obtenerRecuperacionPendiente(idRecuperacion);
        Usuario admin = obtenerAdministrador(correoAdmin);

        if (motivoRechazo == null || motivoRechazo.trim().length() < 10) {
            throw new BadRequestException("Debe indicar el motivo del rechazo (minimo 10 caracteres)");
        }

        solicitud.setEstado(EstadoRecuperacion.RECHAZADA);
        solicitud.setFechaResolucion(LocalDateTime.now());
        solicitud.setDniAdministrador(admin.getDni());
        solicitud.setObservacionAdmin(motivoRechazo.trim());
        recuperacionRepository.save(solicitud);

        auditoriaService.registrarAsiento("RECUP_CLAVE_" + idRecuperacion, admin.getIdUsuario(), "RECUPERACION_CLAVE_RECHAZADA", ipOrigen);
        notificacionService.enviarNotificacionConTipo(solicitud.getDniSolicitante(), null, "Recuperacion de Contrasena Rechazada",
                "Administracion rechazo su solicitud #" + idRecuperacion + ". Motivo: " + motivoRechazo.trim(),
                "RECUPERACION_CLAVE");

        return MensajeGenericoResponse.builder()
                .exito(true)
                .mensaje("Solicitud #" + idRecuperacion + " rechazada")
                .dato(solicitud.getDniSolicitante())
                .build();
    }

    private SolicitudRecuperacionClave obtenerRecuperacionPendiente(Long idRecuperacion) {
        SolicitudRecuperacionClave solicitud = recuperacionRepository.findById(idRecuperacion)
                .orElseThrow(() -> new RecursoNoEncontradoException("Solicitud de recuperacion no encontrada: " + idRecuperacion));
        if (solicitud.getEstado() != EstadoRecuperacion.PENDIENTE) {
            throw new BadRequestException("La solicitud #" + idRecuperacion + " ya fue resuelta (" + solicitud.getEstado() + ")");
        }
        return solicitud;
    }

    private Usuario obtenerAdministrador(String correoAdmin) {
        Usuario admin = usuarioRepository.findByCorreoCorporativo(correoAdmin == null ? "" : correoAdmin.trim())
                .orElseThrow(() -> new RecursoNoEncontradoException("Administrador no encontrado: " + correoAdmin));
        if (admin.getRol() != RolUsuario.ADMINISTRADOR) {
            throw new AccesoDenegadoException("Solo un Administrador puede resolver solicitudes de recuperacion");
        }
        return admin;
    }

    @Override
    @Transactional
    public MensajeGenericoResponse actualizarPerfil(String correo, ActualizarPerfilRequest request) {
        Usuario usuario = usuarioRepository.findByCorreoCorporativo(correo)
                .orElseThrow(() -> new RecursoNoEncontradoException("Usuario no encontrado"));

        if (request.getNuevaContrasena() != null && !request.getNuevaContrasena().trim().isEmpty()) {
            usuario.setContrasenaHash(passwordEncoder.encode(request.getNuevaContrasena().trim()));
            usuarioRepository.save(usuario);
        }

        mecanicoRepository.findByDniMecanico(usuario.getDni()).ifPresent(m -> {
            if (request.getTelefono() != null && !request.getTelefono().isBlank()) {
                m.setTelefono(request.getTelefono().trim());
                mecanicoRepository.save(m);
            }
        });

        return MensajeGenericoResponse.builder()
                .exito(true)
                .mensaje("Perfil institucional actualizado exitosamente")
                .dato(null)
                .build();
    }

    @Override
    @Transactional
    public MensajeGenericoResponse cambiarContrasenaPropia(String correo, String claveActual, String claveNueva, String ipOrigen) {
        Usuario usuario = usuarioRepository.findByCorreoCorporativo(correo)
                .orElseThrow(() -> new RecursoNoEncontradoException("Usuario no encontrado"));

        if (claveActual == null || !passwordEncoder.matches(claveActual, usuario.getContrasenaHash())) {
            throw new BadRequestException("La contrasena actual es incorrecta");
        }
        if (claveNueva == null || claveNueva.trim().length() < 8) {
            throw new BadRequestException("La nueva contrasena debe tener al menos 8 caracteres");
        }

        usuario.setContrasenaHash(passwordEncoder.encode(claveNueva.trim()));
        usuarioRepository.save(usuario);
        auditoriaService.registrarAsiento("CAMBIO_CLAVE_" + usuario.getDni(), usuario.getIdUsuario(), "CAMBIO_CONTRASENA_PROPIA", ipOrigen);

        return MensajeGenericoResponse.builder()
                .exito(true)
                .mensaje("Contrasena actualizada exitosamente")
                .dato(null)
                .build();
    }

    @Override
    @Transactional(readOnly = true)
    public Page<UsuarioResumenResponse> listarUsuarios(RolUsuario rol, Pageable pageable) {
        Page<Usuario> pagina = (rol != null) 
                ? usuarioRepository.findByRol(rol, pageable) 
                : usuarioRepository.findAll(pageable);

        return pagina.map(u -> UsuarioResumenResponse.builder()
                .idUsuario(u.getIdUsuario())
                .dni(u.getDni())
                .nombre(u.getNombre())
                .correoCorporativo(u.getCorreoCorporativo())
                .rol(u.getRol())
                .estadoCuenta(u.getEstadoCuenta())
                .build());
    }

    @Override
    @Transactional
    public MensajeGenericoResponse registrarUsuario(CrearUsuarioRequest request, String ipOrigen) {
        if (usuarioRepository.existsByDni(request.getDni())) {
            throw new BadRequestException("El DNI ingresado ya se encuentra registrado");
        }
        if (usuarioRepository.existsByCorreoCorporativo(request.getCorreoCorporativo().toLowerCase())) {
            throw new BadRequestException("El correo corporativo ya pertenece a otra cuenta");
        }

        Usuario usuario = Usuario.builder()
                .dni(request.getDni().trim())
                .nombre(request.getNombre().trim())
                .correoCorporativo(request.getCorreoCorporativo().trim().toLowerCase())
                .contrasenaHash(passwordEncoder.encode(request.getContrasena()))
                .rol(request.getRol())
                .estadoCuenta(EstadoCuenta.ACTIVO)
                .intentosFallidos(0)
                .build();

        Usuario usuarioGuardado = usuarioRepository.save(usuario);

        switch (request.getRol()) {
            case MECANICO -> {
                Mecanico mec = Mecanico.builder()
                        .dniMecanico(usuarioGuardado.getDni())
                        .nombreMecanico(usuarioGuardado.getNombre())
                        .especialidadMecanico(request.getEspecialidad() != null ? request.getEspecialidad() : "Mantenimiento General")
                        .cargoMecanico(request.getCargo() != null ? request.getCargo() : "Tecnico de Mantenimiento")
                        .build();
                mecanicoRepository.save(mec);
            }
            case ALMACENISTA -> {
                Almacenista alm = Almacenista.builder()
                        .dniAlmacenista(usuarioGuardado.getDni())
                        .nombreAlmacenista(usuarioGuardado.getNombre())
                        .sedeAsignada(request.getSedeAsignada() != null ? request.getSedeAsignada() : "Sede Central")
                        .build();
                almacenistaRepository.save(alm);
            }
            case ADMINISTRADOR -> {
                Administrador adm = Administrador.builder()
                        .dniAdministrador(usuarioGuardado.getDni())
                        .nombreAdministrador(usuarioGuardado.getNombre())
                        .correoCorporativo(usuarioGuardado.getCorreoCorporativo())
                        .build();
                administradorRepository.save(adm);
            }
        }

        auditoriaService.registrarAsiento("ALTA_USUARIO_" + usuarioGuardado.getDni(), usuarioGuardado.getIdUsuario(), "USUARIO_CREADO", ipOrigen);

        return MensajeGenericoResponse.builder()
                .exito(true)
                .mensaje("Usuario " + usuarioGuardado.getNombre() + " registrado con exito")
                .dato(usuarioGuardado.getIdUsuario())
                .build();
    }

    @Override
    @Transactional
    public MensajeGenericoResponse cambiarEstadoCuenta(Long idUsuario, EstadoCuenta nuevoEstado, String ipOrigen) {
        Usuario usuario = usuarioRepository.findById(idUsuario)
                .orElseThrow(() -> new RecursoNoEncontradoException("Usuario no encontrado con ID: " + idUsuario));

        usuario.setEstadoCuenta(nuevoEstado);
        if (nuevoEstado == EstadoCuenta.ACTIVO) {
            usuario.setIntentosFallidos(0);
        }
        usuarioRepository.save(usuario);

        auditoriaService.registrarAsiento("ESTADO_CUENTA_" + usuario.getDni(), usuario.getIdUsuario(), "CAMBIO_ESTADO_" + nuevoEstado.name(), ipOrigen);

        return MensajeGenericoResponse.builder()
                .exito(true)
                .mensaje("Estado de cuenta actualizado a: " + nuevoEstado.name())
                .dato(usuario.getEstadoCuenta())
                .build();
    }
    
    @Override
    @Transactional
    public MensajeGenericoResponse cambiarEstadoCuentaPorDni(String dni, EstadoCuenta nuevoEstado, String ipOrigen) {
        return cambiarEstadoCuentaPorDni(dni, nuevoEstado, null, ipOrigen);
    }

    @Override
    @Transactional
    public MensajeGenericoResponse cambiarEstadoCuentaPorDni(String dni, EstadoCuenta nuevoEstado, String correoAdmin, String ipOrigen) {
        Usuario objetivo = usuarioRepository.findByDni(dni.trim())
                .orElseThrow(() -> new RecursoNoEncontradoException("Usuario no encontrado con DNI: " + dni));

        if (correoAdmin != null && !correoAdmin.trim().isEmpty()) {
            Usuario admin = usuarioRepository.findByCorreoCorporativo(correoAdmin.trim())
                    .orElseThrow(() -> new RecursoNoEncontradoException("Administrador no encontrado: " + correoAdmin));

            if (objetivo.getRol() == RolUsuario.ADMINISTRADOR && !objetivo.getIdUsuario().equals(admin.getIdUsuario())) {
                throw new AccesoDenegadoException("No tiene privilegios para modificar o suspender cuentas de nivel administrativo.");
            }
        }

        return cambiarEstadoCuenta(objetivo.getIdUsuario(), nuevoEstado, ipOrigen);
    }

    @Override
    @Transactional
    public MensajeGenericoResponse resetearClavePorDni(String dni, String nuevaClave, String correoAdmin, String ipOrigen) {
        Usuario objetivo = usuarioRepository.findByDni(dni.trim())
                .orElseThrow(() -> new RecursoNoEncontradoException("Usuario no encontrado con DNI: " + dni));

        if (correoAdmin != null && !correoAdmin.trim().isEmpty()) {
            Usuario admin = usuarioRepository.findByCorreoCorporativo(correoAdmin.trim())
                    .orElseThrow(() -> new RecursoNoEncontradoException("Administrador no encontrado: " + correoAdmin));

            if (objetivo.getRol() == RolUsuario.ADMINISTRADOR && !objetivo.getIdUsuario().equals(admin.getIdUsuario())) {
                throw new AccesoDenegadoException("No tiene privilegios para resetear contraseñas de nivel administrativo.");
            }
        }

        if (objetivo.getRol() != RolUsuario.ADMINISTRADOR) {
            SolicitudRecuperacionClave pendiente = recuperacionRepository
                    .findByEstadoOrderByFechaSolicitudAsc(EstadoRecuperacion.PENDIENTE).stream()
                    .filter(r -> r.getDniSolicitante().equals(objetivo.getDni()))
                    .findFirst()
                    .orElse(null);
            if (pendiente != null) {
                return aprobarRecuperacionClave(pendiente.getIdRecuperacion(), nuevaClave, correoAdmin, ipOrigen);
            }
        }

        objetivo.setContrasenaHash(passwordEncoder.encode(nuevaClave.trim()));
        objetivo.setIntentosFallidos(0);
        objetivo.setEstadoCuenta(EstadoCuenta.ACTIVO);
        usuarioRepository.save(objetivo);

        auditoriaService.registrarAsiento("RESET_CLAVE_" + objetivo.getDni(), objetivo.getIdUsuario(), "RESET_CONTRASENA_ADMIN", ipOrigen);

        return MensajeGenericoResponse.builder()
                .exito(true)
                .mensaje("Contraseña reseteada exitosamente para el usuario con DNI: " + dni)
                .dato(dni)
                .build();
    }

    @Override
    @Transactional
    public MensajeGenericoResponse actualizarUsuarioPorDni(String dni, ActualizarPerfilRequest request) {
        Usuario usuario = usuarioRepository.findByDni(dni.trim())
                .orElseThrow(() -> new RecursoNoEncontradoException("Usuario no encontrado con DNI: " + dni));
        if (request.getNombre() != null && !request.getNombre().isBlank()) {
            String nombre = request.getNombre().trim();
            usuario.setNombre(nombre);
            usuarioRepository.save(usuario);
            mecanicoRepository.findByDniMecanico(usuario.getDni()).ifPresent(m -> m.setNombreMecanico(nombre));
            almacenistaRepository.findByDniAlmacenista(usuario.getDni()).ifPresent(a -> a.setNombreAlmacenista(nombre));
            administradorRepository.findByDniAdministrador(usuario.getDni()).ifPresent(a -> a.setNombreAdministrador(nombre));
        }
        if (request.getTelefono() != null && !request.getTelefono().isBlank()) {
            mecanicoRepository.findByDniMecanico(usuario.getDni()).ifPresent(m -> m.setTelefono(request.getTelefono().trim()));
        }
        return MensajeGenericoResponse.builder()
                .exito(true)
                .mensaje("Usuario con DNI " + dni + " actualizado exitosamente")
                .dato(dni)
                .build();
    }
}
