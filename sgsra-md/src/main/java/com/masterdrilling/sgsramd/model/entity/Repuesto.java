package com.masterdrilling.sgsramd.model.entity;

import jakarta.persistence.*;
import lombok.*;

// Catalogo maestro de repuestos para maquinaria pesada
@Entity
@Table(name = "repuesto")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Repuesto {

    @Id
    @Column(name = "cod_parte", length = 30)
    private String codParte;

    @Column(name = "nombre_repuesto", length = 150, nullable = false)
    private String nombreRepuesto;

    @Column(name = "stock_actual", nullable = false)
    private Integer stockActual;

    @Column(name = "stock_minimo", nullable = false)
    private Integer stockMinimo;

    @Column(name = "descripcion", columnDefinition = "TEXT")
    private String descripcion;

    @Column(name = "activo", nullable = false)
    @Builder.Default
    private Boolean activo = true;
}