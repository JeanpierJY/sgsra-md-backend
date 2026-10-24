package com.masterdrilling.sgsramd.model.entity;

import jakarta.persistence.*;
import lombok.*;

// Entidad de especializacion para el rol mecanico
@Entity
@Table(name = "mecanico")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Mecanico {

    @Id
    @Column(name = "dni_mecanico", length = 8)
    private String dniMecanico;

    @Column(name = "nombre_mecanico", length = 100, nullable = false)
    private String nombreMecanico;

    @Column(name = "especialidad_mecanico", length = 50, nullable = false)
    private String especialidadMecanico;

    @Column(name = "cargo_mecanico", length = 50, nullable = false)
    private String cargoMecanico;

    @Column(name = "telefono", length = 15)
    private String telefono;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "dni_mecanico", referencedColumnName = "dni", insertable = false, updatable = false)
    private Usuario usuario;
}