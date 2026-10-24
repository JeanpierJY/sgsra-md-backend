package com.masterdrilling.sgsramd.model.entity;

import jakarta.persistence.*;
import lombok.*;

// Detalle de activos incluidos en el alta formal
@Entity
@Table(name = "registro_detalle")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RegistroDetalle {

    @EmbeddedId
    private RegistroDetalleId id;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("registroNum")
    @JoinColumn(name = "registro_num")
    private Registro registro;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "cod_herramienta", nullable = false)
    private Herramienta herramienta;
}