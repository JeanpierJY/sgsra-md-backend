package com.masterdrilling.sgsramd.model.entity;

import com.masterdrilling.sgsramd.model.enums.EstadoSolicitud;
import com.masterdrilling.sgsramd.model.enums.PrioridadSolicitud;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

// Cabecera de requerimiento de repuestos
@Entity
@Table(name = "solicitud")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Solicitud {

    @Id
    @Column(name = "solicitud_num", length = 20)
    private String solicitudNum;

    @Column(name = "fecha_emision", nullable = false)
    private LocalDate fechaEmision;

    @Column(name = "hora_emision", nullable = false)
    private LocalTime horaEmision;

    @Enumerated(EnumType.STRING)
    @Column(name = "prioridad_solicitud", length = 20, nullable = false)
    private PrioridadSolicitud prioridadSolicitud;

    @Column(name = "justificacion_tecnica", columnDefinition = "TEXT", nullable = false)
    private String justificacionTecnica;

    @Enumerated(EnumType.STRING)
    @Column(name = "estado_solicitud", length = 20, nullable = false)
    @Builder.Default
    private EstadoSolicitud estadoSolicitud = EstadoSolicitud.PENDIENTE;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "dni_mecanico", nullable = false)
    private Mecanico mecanico;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "cod_maquina", nullable = false)
    private Maquinaria maquinaria;

    @OneToMany(mappedBy = "solicitud", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<SolicitudDetalle> detalles = new ArrayList<>();
}