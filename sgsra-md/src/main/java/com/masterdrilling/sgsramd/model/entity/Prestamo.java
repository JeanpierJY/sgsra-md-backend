package com.masterdrilling.sgsramd.model.entity;

import com.masterdrilling.sgsramd.model.enums.EstadoPrestamo;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

// Cabecera de asignacion y prestamo de herramientas
@Entity
@Table(name = "prestamo")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Prestamo {

    @Id
    @Column(name = "prestamo_num", length = 20)
    private String prestamoNum;

    @Column(name = "fecha_prestamo", nullable = false)
    private LocalDate fechaPrestamo;

    @Column(name = "hora_salida", nullable = false)
    private LocalTime horaSalida;

    @Enumerated(EnumType.STRING)
    @Column(name = "estado_prestamo", length = 20, nullable = false)
    @Builder.Default
    private EstadoPrestamo estadoPrestamo = EstadoPrestamo.ACTIVO;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "dni_almacenista", nullable = false)
    private Almacenista almacenista;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "dni_mecanico", nullable = false)
    private Mecanico mecanico;

    @OneToMany(mappedBy = "prestamo", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<PrestamoDetalle> detalles = new ArrayList<>();
}