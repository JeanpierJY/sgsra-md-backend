package com.masterdrilling.sgsramd.service.impl;

import com.masterdrilling.sgsramd.dto.response.PerfilResponse;

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
    private final com.masterdrilling.sgsramd.service.IStorageService storageService;

    // RF04: 3 fallos -> 5 min, 6 fallos -> 10 min, 9 fallos -> bloqueo total
    private static final int INTENTOS_POR_TRAMO = 3;
    private static final int INTENTOS_BLOQUEO_TOTAL = 9;

    @Override
    @Transactional(noRollbackFor = {AccesoDenegadoException.class, CuentaBloqueadaException.class})
    public LoginResponse autenticar(LoginRequest request, String ipOrigen) {
        Usuario usuario = usuarioRepository.findByCorreoCorporativo(request.getCorreoCorporativo().trim().toLowerCase())
                .orElseThrow(() -> new AccesoDenegadoException("Credenciales no validas"));

        if (usuario.getEstadoCuenta() == EstadoCuenta.BLOQUEADO) {
            auditoriaService.registrarAsiento("LOGIN_FALLIDO", usuario.getIdUsuario(), "INTENTO_CUENTA_BLOQUEADA", ipOrigen);
            throw new CuentaBloqueadaException(
                    "Cuenta bloqueada por exceso de intentos fallidos. Solicite el desbloqueo a Administracion", 0, true);
        }

        LocalDateTime ahora = LocalDateTime.now();
        if (usuario.getBloqueadoHasta() != null && usuario.getBloqueadoHasta().isAfter(ahora)) {
            long segundos = java.time.Duration.between(ahora, usuario.getBloqueadoHasta()).getSeconds() + 1;
            throw new CuentaBloqueadaException(
                    "Cuenta bloqueada temporalmente. Intente nuevamente en " + formatearEspera(segundos), segundos, false);
        }

        if (usuario.getEstadoCuenta() == EstadoCuenta.INACTIVO) {
            throw new AccesoDenegadoException("La cuenta de usuario se encuentra suspendida o dada de baja");
        }

        if (!passwordEncoder.matches(request.getContrasena(), usuario.getContrasenaHash())) {
            int intentos = usuario.getIntentosFallidos() + 1;
            usuario.setIntentosFallidos(intentos);

            if (intentos >= INTENTOS_BLOQUEO_TOTAL) {
                usuario.setEstadoCuenta(EstadoCuenta.BLOQUEADO);
                usuario.setBloqueadoHasta(null);
                usuarioRepository.save(usuario);
                auditoriaService.registrarAsiento("BLOQUEO_CUENTA", usuario.getIdUsuario(), "BLOQUEO_TOTAL_POR_INTENTOS", ipOrigen);
                notificacionService.enviarNotificacionConTipo(null, "ADMINISTRADOR", "Cuenta Bloqueada",
                        usuario.getNombre() + " (DNI " + usuario.getDni() + ") fue bloqueado tras " + intentos
                                + " intentos fallidos de acceso.", "SEGURIDAD");
                throw new CuentaBloqueadaException(
                        "Cuenta bloqueada tras " + intentos + " intentos fallidos. Solicite el desbloqueo a Administracion", 0, true);
            }
            if (intentos % INTENTOS_POR_TRAMO == 0) {
                long minutos = intentos == INTENTOS_POR_TRAMO ? 5 : 10;
                usuario.setBloqueadoHasta(ahora.plusMinutes(minutos));
                usuarioRepository.save(usuario);
                auditoriaService.registrarAsiento("BLOQUEO_CUENTA", usuario.getIdUsuario(), "BLOQUEO_TEMPORAL_" + minutos + "_MIN", ipOrigen);
                throw new CuentaBloqueadaException(
                        "Demasiados intentos fallidos. Cuenta bloqueada por " + minutos + " minutos", minutos * 60, false);
            }
            usuarioRepository.save(usuario);
            auditoriaService.registrarAsiento("LOGIN_FALLIDO", usuario.getIdUsuario(), "CONTRASENA_INCORRECTA", ipOrigen);
            int restantes = INTENTOS_POR_TRAMO - (intentos % INTENTOS_POR_TRAMO);
            throw new AccesoDenegadoException("Credenciales no validas. Intentos restantes antes del bloqueo: " + restantes);
        }

        usuario.setIntentosFallidos(0);
        usuario.setBloqueadoHasta(null);
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
    @Transactional
    public MensajeGenericoResponse solicitarRecuperacionClave(String dni, String telefono, String motivo, String ipOrigen) {
        // REQ-02: el operario valida su identidad solo con DNI y telefono registrado
        if (dni == null || !dni.trim().matches("^[0-9]{8}$")) {
            throw new BadRequestException("Debe ingresar un DNI valido de 8 digitos");
        }
        if (telefono == null || !telefono.trim().matches("^[0-9]{9}$")) {
            throw new BadRequestException("Debe ingresar un telefono valido de 9 digitos");
        }
        final String mensajeInvalido = "Los datos ingresados no coinciden con ningun operario registrado";
        Usuario usuario = usuarioRepository.findByDni(dni.trim())
                .orElseThrow(() -> new BadRequestException(mensajeInvalido));

        if (usuario.getRol() == RolUsuario.ADMINISTRADOR) {
            throw new AccesoDenegadoException("Las cuentas de Administrador deben gestionar su clave con el area de TI");
        }
        String telefonoRegistrado = obtenerTelefonoRegistrado(usuario);
        if (telefonoRegistrado == null || telefonoRegistrado.isBlank()) {
            throw new BadRequestException("No tiene un telefono registrado para validar su identidad. Acuda presencialmente a Administracion");
        }
        if (!telefonoRegistrado.trim().equals(telefono.trim())) {
            auditoriaService.registrarAsiento("RECUP_CLAVE_FALLIDA", usuario.getIdUsuario(), "VALIDACION_TELEFONO_FALLIDA", ipOrigen);
            throw new BadRequestException(mensajeInvalido);
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
    @Transactional
    public MensajeGenericoResponse solicitarRecuperacionClavePorDniYTelefono(String dni, String telefono, String motivo, String ipOrigen) {
        return solicitarRecuperacionClavePorDniYTelefono(dni, telefono, motivo, null, ipOrigen);
    }

    @Override
    @Transactional
    public MensajeGenericoResponse solicitarRecuperacionClavePorDniYTelefono(String dni, String telefono, String motivo, org.springframework.web.multipart.MultipartFile fotoSelfie, String ipOrigen) {
        if (dni == null || dni.trim().length() != 8) {
            throw new BadRequestException("El DNI debe tener exactamente 8 digitos numericos");
        }
        if (telefono == null || !telefono.trim().matches("^9\\d{8}$")) {
            throw new BadRequestException("El numero telefonico debe tener exactamente 9 digitos y comenzar con 9");
        }

        Usuario usuario = usuarioRepository.findByDni(dni.trim())
                .orElseThrow(() -> new RecursoNoEncontradoException("No existe usuario registrado con el DNI: " + dni.trim()));

        if (usuario.getRol() == RolUsuario.ADMINISTRADOR) {
            throw new AccesoDenegadoException("Las cuentas de Administrador deben gestionar su clave con el area de TI");
        }

        // Seguridad: el telefono debe coincidir con el registrado; nunca se registra uno nuevo aqui
        // (antes un tercero podia fijar su propio telefono en cuentas sin telefono)
        String telefonoRegistrado = obtenerTelefonoRegistrado(usuario);
        if (telefonoRegistrado == null || telefonoRegistrado.isBlank()) {
            throw new BadRequestException("Su cuenta no tiene telefono registrado. Acuda presencialmente a Administracion");
        }
        if (!telefonoRegistrado.trim().equals(telefono.trim())) {
            auditoriaService.registrarAsiento("RECUP_CLAVE_FALLIDA", usuario.getIdUsuario(), "VALIDACION_TELEFONO_FALLIDA", ipOrigen);
            throw new BadRequestException("El DNI y el telefono no coinciden con los datos registrados");
        }

        if (recuperacionRepository.existsByDniSolicitanteAndEstado(usuario.getDni(), EstadoRecuperacion.PENDIENTE)) {
            throw new BadRequestException("Ya tiene una solicitud de recuperacion pendiente de revision por Administracion");
        }

        String selfieUrl = null;
        if (fotoSelfie != null && !fotoSelfie.isEmpty()) {
            selfieUrl = storageService.guardarArchivo(fotoSelfie, "selfies");
        }

        SolicitudRecuperacionClave solicitud = recuperacionRepository.save(SolicitudRecuperacionClave.builder()
                .dniSolicitante(usuario.getDni())
                .nombreSolicitante(usuario.getNombre())
                .correoSolicitante(usuario.getCorreoCorporativo())
                .rolSolicitante(usuario.getRol())
                .motivo(motivo != null && !motivo.isBlank() ? motivo.trim() : "Recuperacion de contrasena solicitada desde login con validacion de DNI y telefono")
                .fotoSelfieUrl(selfieUrl)
                .estado(EstadoRecuperacion.PENDIENTE)
                .fechaSolicitud(LocalDateTime.now())
                .build());

        auditoriaService.registrarAsiento("RECUP_CLAVE_" + solicitud.getIdRecuperacion(), usuario.getIdUsuario(), "SOLICITUD_RECUPERACION_CLAVE_DNI", ipOrigen);
        notificacionService.enviarNotificacionConTipo(null, "ADMINISTRADOR", "Solicitud de Recuperacion de Contrasena",
                usuario.getNombre() + " (" + usuario.getRol() + ", DNI " + usuario.getDni() + ") solicita restablecer su contrasena. "
                        + "Telefono: " + telefono.trim() + ". Solicitud #" + solicitud.getIdRecuperacion() + ". Revisela en Gestionar Personal.",
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
                .fotoSelfieUrl(r.getFotoSelfieUrl())
                .fotoPerfilUrl(usuarioRepository.findByDni(r.getDniSolicitante()).map(Usuario::getFotoPerfilUrl).orElse(null))
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
        objetivo.setBloqueadoHasta(null);
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

    private String obtenerTelefonoRegistrado(Usuario usuario) {
        if (usuario.getRol() == RolUsuario.MECANICO) {
            return mecanicoRepository.findByDniMecanico(usuario.getDni()).map(Mecanico::getTelefono).orElse(null);
        }
        if (usuario.getRol() == RolUsuario.ALMACENISTA) {
            return almacenistaRepository.findByDniAlmacenista(usuario.getDni()).map(Almacenista::getTelefono).orElse(null);
        }
        return null;
    }

    // SEC-01: ningun administrador puede alterar cuentas de nivel administrativo
    private void validarObjetivoNoAdministrador(Usuario objetivo) {
        if (objetivo.getRol() == RolUsuario.ADMINISTRADOR) {
            throw new AccesoDenegadoException("No tiene privilegios para modificar cuentas de nivel administrativo. Gestionelo con el area de TI");
        }
    }

    private static String formatearEspera(long segundos) {
        long m = segundos / 60;
        long s = segundos % 60;
        return m > 0 ? m + " min " + s + " s" : s + " s";
    }

    @Override
    @Transactional(readOnly = true)
    public PerfilResponse obtenerPerfil(String correo) {
        Usuario u = usuarioRepository.findByCorreoCorporativo(correo.trim().toLowerCase())
                .orElseThrow(() -> new RecursoNoEncontradoException("Usuario no encontrado"));
        PerfilResponse.PerfilResponseBuilder b = PerfilResponse.builder()
                .dni(u.getDni())
                .nombre(u.getNombre())
                .correoCorporativo(u.getCorreoCorporativo())
                .rol(u.getRol())
                .telefonoEditable(u.getRol() != RolUsuario.ADMINISTRADOR)
                .telefono(obtenerTelefonoRegistrado(u))
                .fotoPerfilUrl(u.getFotoPerfilUrl());
        if (u.getRol() == RolUsuario.ALMACENISTA) {
            almacenistaRepository.findByDniAlmacenista(u.getDni()).ifPresent(a -> b.sedeAsignada(a.getSedeAsignada()));
        }
        return b.build();
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

        // RF07 / REQ-01: DNI, nombre y correo son de solo lectura; solo se edita el telefono.
        // La contrasena se cambia en /cambiar-clave, que exige la contrasena actual
        if (request.getTelefono() == null || !request.getTelefono().trim().matches("^[0-9]{9}$")) {
            throw new BadRequestException("El telefono debe contener exactamente 9 digitos numericos");
        }
        String tel = request.getTelefono().trim();
        switch (usuario.getRol()) {
            case MECANICO -> mecanicoRepository.findByDniMecanico(usuario.getDni())
                    .ifPresent(m -> { m.setTelefono(tel); mecanicoRepository.save(m); });
            case ALMACENISTA -> almacenistaRepository.findByDniAlmacenista(usuario.getDni())
                    .ifPresent(a -> { a.setTelefono(tel); almacenistaRepository.save(a); });
            default -> throw new BadRequestException("El perfil de Administrador no registra telefono de contacto");
        }

        return MensajeGenericoResponse.builder()
                .exito(true)
                .mensaje("Telefono de contacto actualizado exitosamente")
                .dato(null)
                .build();
    }

    @Override
    @Transactional
    public MensajeGenericoResponse actualizarFotoPerfil(String correo, org.springframework.web.multipart.MultipartFile foto) {
        Usuario usuario = usuarioRepository.findByCorreoCorporativo(correo.trim().toLowerCase())
                .orElseThrow(() -> new RecursoNoEncontradoException("Usuario no encontrado"));
        String url = storageService.guardarArchivo(foto, "perfiles");
        usuario.setFotoPerfilUrl(url);
        usuarioRepository.save(usuario);
        return MensajeGenericoResponse.builder().exito(true).mensaje("Foto de perfil actualizada").dato(url).build();
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
        if (pageable.getSort().isUnsorted()) {
            pageable = org.springframework.data.domain.PageRequest.of(pageable.getPageNumber(), pageable.getPageSize(),
                    org.springframework.data.domain.Sort.by("nombre").ascending());
        }
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
                .intentosFallidos(u.getIntentosFallidos())
                .telefono(obtenerTelefonoRegistrado(u))
                .fotoPerfilUrl(u.getFotoPerfilUrl())
                .build());
    }

    @Override
    @Transactional
    public MensajeGenericoResponse registrarUsuario(CrearUsuarioRequest request, String ipOrigen) {
        if (request.getRol() == RolUsuario.ADMINISTRADOR) {
            throw new AccesoDenegadoException("Las cuentas de Administrador solo pueden ser creadas por el area de TI");
        }
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
                        // REQ-01: la especialidad refleja el rol operativo; "cargo" ya no se usa
                        .especialidadMecanico("Mecanico")
                        .cargoMecanico("Mecanico")
                        .telefono(request.getTelefono())
                        .build();
                mecanicoRepository.save(mec);
            }
            case ALMACENISTA -> {
                Almacenista alm = Almacenista.builder()
                        .dniAlmacenista(usuarioGuardado.getDni())
                        .nombreAlmacenista(usuarioGuardado.getNombre())
                        .sedeAsignada(request.getSedeAsignada() != null ? request.getSedeAsignada() : "Sede Central")
                        .telefono(request.getTelefono())
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
        validarObjetivoNoAdministrador(usuario);

        usuario.setEstadoCuenta(nuevoEstado);
        if (nuevoEstado == EstadoCuenta.ACTIVO) {
            usuario.setIntentosFallidos(0);
            usuario.setBloqueadoHasta(null);
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

        }
        validarObjetivoNoAdministrador(objetivo);

        return cambiarEstadoCuenta(objetivo.getIdUsuario(), nuevoEstado, ipOrigen);
    }

    @Override
    @Transactional
    public MensajeGenericoResponse resetearClavePorDni(String dni, String nuevaClave, String correoAdmin, String ipOrigen) {
        // REQ-02: el Administrador no cambia contrasenas arbitrariamente; solo resuelve
        // una solicitud de recuperacion pendiente del propio operario
        Usuario objetivo = usuarioRepository.findByDni(dni.trim())
                .orElseThrow(() -> new RecursoNoEncontradoException("Usuario no encontrado con DNI: " + dni));
        validarObjetivoNoAdministrador(objetivo);

        if (correoAdmin != null && !correoAdmin.trim().isEmpty()) {
            Usuario admin = usuarioRepository.findByCorreoCorporativo(correoAdmin.trim())
                    .orElseThrow(() -> new RecursoNoEncontradoException("Administrador no encontrado: " + correoAdmin));

            if (objetivo.getRol() == RolUsuario.ADMINISTRADOR && !objetivo.getIdUsuario().equals(admin.getIdUsuario())) {
                throw new AccesoDenegadoException("No tiene privilegios para resetear contraseñas de nivel administrativo.");
            }
        }

        // REQ-02: el Administrador no cambia contrasenas arbitrariamente; solo resuelve
        // una solicitud de recuperacion pendiente. Las cuentas administrativas las gestiona TI
        if (objetivo.getRol() == RolUsuario.ADMINISTRADOR) {
            throw new AccesoDenegadoException("Las contrasenas de Administrador solo las gestiona el area de TI");
        }
        SolicitudRecuperacionClave pendiente = recuperacionRepository
                .findByEstadoOrderByFechaSolicitudAsc(EstadoRecuperacion.PENDIENTE).stream()
                .filter(r -> r.getDniSolicitante().equals(objetivo.getDni()))
                .findFirst()
                .orElseThrow(() -> new BadRequestException(
                        "El usuario con DNI " + dni + " no tiene una solicitud de recuperacion pendiente"));
        return aprobarRecuperacionClave(pendiente.getIdRecuperacion(), nuevaClave, correoAdmin, ipOrigen);
    }

    @Override
    @Transactional
    public MensajeGenericoResponse actualizarUsuarioPorDni(String dni, ActualizarPerfilRequest request) {
        Usuario usuario = usuarioRepository.findByDni(dni.trim())
                .orElseThrow(() -> new RecursoNoEncontradoException("Usuario no encontrado con DNI: " + dni));
        validarObjetivoNoAdministrador(usuario);
        String nombre = request.getNombre() != null && !request.getNombre().isBlank() ? request.getNombre().trim() : null;
        String tel = request.getTelefono() != null && !request.getTelefono().isBlank() ? request.getTelefono().trim() : null;
        if (nombre != null) {
            usuario.setNombre(nombre);
            usuarioRepository.saveAndFlush(usuario);
        }
        mecanicoRepository.findByDniMecanico(usuario.getDni()).ifPresent(m -> {
            if (nombre != null) m.setNombreMecanico(nombre);
            if (tel != null) m.setTelefono(tel);
            mecanicoRepository.save(m);
        });
        almacenistaRepository.findByDniAlmacenista(usuario.getDni()).ifPresent(a -> {
            if (nombre != null) a.setNombreAlmacenista(nombre);
            if (tel != null) a.setTelefono(tel);
            almacenistaRepository.save(a);
        });
        if (nombre != null) {
            administradorRepository.findByDniAdministrador(usuario.getDni()).ifPresent(a -> {
                a.setNombreAdministrador(nombre);
                administradorRepository.save(a);
            });
        }
        auditoriaService.registrarAsiento("USUARIO_" + dni, usuario.getIdUsuario(), "DATOS_PERSONAL_ACTUALIZADOS", "APP");
        return MensajeGenericoResponse.builder()
                .exito(true)
                .mensaje("Usuario con DNI " + dni + " actualizado exitosamente")
                .dato(dni)
                .build();
    }
}
