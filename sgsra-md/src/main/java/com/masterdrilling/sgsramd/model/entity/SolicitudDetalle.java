package com.masterdrilling.sgsramd.model.entity;

import com.masterdrilling.sgsramd.model.enums.EstadoItemSolicitud;
import jakarta.persistence.*;
import lombok.*;

// Detalle de piezas solicitadas en un requerimiento
@Entity
@Table(name = "solicitud_detalle")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SolicitudDetalle {

    @EmbeddedId
    private SolicitudDetalleId id;

    @Column(name = "cantidad_repuesto", nullable = false)
    private Integer cantidadRepuesto;

    @Enumerated(EnumType.STRING)
    @Column(name = "estado_item", length = 20, nullable = false)
    @Builder.Default
    private EstadoItemSolicitud estadoItem = EstadoItemSolicitud.PENDIENTE;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("solicitudNum")
    @JoinColumn(name = "solicitud_num")
    private Solicitud solicitud;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "cod_parte", nullable = false)
    private Repuesto repuesto;
}