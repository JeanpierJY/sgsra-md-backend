package com.masterdrilling.sgsramd.model.entity;

import jakarta.persistence.*;
import lombok.*;

// Justificacion de rechazo
@Entity
@Table(name = "detalle_rechazo")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DetalleRechazo {

    @EmbeddedId
    private DetalleRechazoId id;

    @Column(name = "cantidad_rechazada", nullable = false)
    private Integer cantidadRechazada;

    @Column(name = "motivo_especifico_item", length = 255, nullable = false)
    private String motivoEspecificoItem;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("dictamenNum")
    @JoinColumn(name = "dictamen_num")
    private DictamenRechazo dictamenRechazo;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "cod_parte", nullable = false)
    private Repuesto repuesto;
}