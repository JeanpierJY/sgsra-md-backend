package com.masterdrilling.sgsramd.model.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalTime;

// Desglose de herramientas asignadas con registro de custodio y firma
@Entity
@Table(name = "prestamo_detalle")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PrestamoDetalle {

    @EmbeddedId
    private PrestamoDetalleId id;

    @Column(name = "nombre_herramienta", length = 150, nullable = false)
    private String nombreHerramienta;

    @Column(name = "estado_herramienta", length = 50, nullable = false)
    private String estadoHerramienta;

    @Column(name = "hora_retorno")
    private LocalTime horaRetorno;

    @Column(name = "firma_mecanico", columnDefinition = "TEXT", nullable = false)
    private String firmaMecanico;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("prestamoNum")
    @JoinColumn(name = "prestamo_num")
    private Prestamo prestamo;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "cod_herramienta", nullable = false)
    private Herramienta herramienta;
}