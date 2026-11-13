package com.masterdrilling.sgsramd.model.entity;

import com.masterdrilling.sgsramd.model.enums.EstadoRecuperacion;
import com.masterdrilling.sgsramd.model.enums.RolUsuario;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

// Solicitud de recuperacion de contrasena emitida por un Mecanico o Almacenista
// y resuelta (aprobada o rechazada) por un Administrador (RF06)
@Entity
@Table(name = "solicitud_recuperacion_clave")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SolicitudRecuperacionClave {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_recuperacion")
    private Long idRecuperacion;

    @Column(name = "dni_solicitante", length = 8, nullable = false)
    private String dniSolicitante;

    @Column(name = "nombre_solicitante", length = 100, nullable = false)
    private String nombreSolicitante;

    @Column(name = "correo_solicitante", length = 100, nullable = false)
    private String correoSolicitante;

    @Enumerated(EnumType.STRING)
    @Column(name = "rol_solicitante", length = 20, nullable = false)
    private RolUsuario rolSolicitante;

    @Column(name = "motivo", columnDefinition = "TEXT")
    private String motivo;

    @Enumerated(EnumType.STRING)
    @Column(name = "estado", length = 20, nullable = false)
    @Builder.Default
    private EstadoRecuperacion estado = EstadoRecuperacion.PENDIENTE;

    @Column(name = "fecha_solicitud", nullable = false)
    @Builder.Default
    private LocalDateTime fechaSolicitud = LocalDateTime.now();

    @Column(name = "fecha_resolucion")
    private LocalDateTime fechaResolucion;

    @Column(name = "dni_administrador", length = 8)
    private String dniAdministrador;

    @Column(name = "observacion_admin", columnDefinition = "TEXT")
    private String observacionAdmin;
}

