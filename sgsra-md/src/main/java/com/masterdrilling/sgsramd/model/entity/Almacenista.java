package com.masterdrilling.sgsramd.model.entity;

import jakarta.persistence.*;
import lombok.*;

// Entidad para el rol almacenista
@Entity
@Table(name = "almacenista")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Almacenista {

    @Id
    @Column(name = "dni_almacenista", length = 8)
    private String dniAlmacenista;

    @Column(name = "nombre_almacenista", length = 100, nullable = false)
    private String nombreAlmacenista;

    @Column(name = "sede_asignada", length = 50, nullable = false)
    private String sedeAsignada;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "dni_almacenista", referencedColumnName = "dni", insertable = false, updatable = false)
    private Usuario usuario;
}