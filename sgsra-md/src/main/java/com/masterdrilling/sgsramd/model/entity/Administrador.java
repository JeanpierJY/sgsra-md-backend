package com.masterdrilling.sgsramd.model.entity;

import jakarta.persistence.*;
import lombok.*;

// Entidad para el rol administrador
@Entity
@Table(name = "administrador")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Administrador {

    @Id
    @Column(name = "dni_administrador", length = 8)
    private String dniAdministrador;

    @Column(name = "nombre_administrador", length = 100, nullable = false)
    private String nombreAdministrador;

    @Column(name = "correo_corporativo", length = 100, nullable = false)
    private String correoCorporativo;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "dni_administrador", referencedColumnName = "dni", insertable = false, updatable = false)
    private Usuario usuario;
}