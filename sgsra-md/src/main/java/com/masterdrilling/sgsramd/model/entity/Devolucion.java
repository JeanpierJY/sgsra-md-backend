package com.masterdrilling.sgsramd.model.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

// Cierre formal y recepcion fisica de herramientas
@Entity
@Table(name = "devolucion")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Devolucion {

    @Id
    @Column(name = "devolucion_num", length = 20)
    private String devolucionNum;

    @Column(name = "fecha_devolucion", nullable = false)
    private LocalDate fechaDevolucion;

    @Column(name = "hora_retorno", nullable = false)
    private LocalTime horaRetorno;

    @Column(name = "detalle_incidencia", columnDefinition = "TEXT")
    private String detalleIncidencia;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "prestamo_num", nullable = false)
    private Prestamo prestamo;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "dni_almacenista", nullable = false)
    private Almacenista almacenista;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "dni_mecanico", nullable = false)
    private Mecanico mecanico;

    @OneToMany(mappedBy = "devolucion", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<DevolucionDetalle> detalles = new ArrayList<>();
}