package com.masterdrilling.sgsramd.model.entity;

import com.masterdrilling.sgsramd.model.enums.EstadoDevolucion;
import jakarta.persistence.*;
import lombok.*;

// Inspeccion individual de herramientas devueltas
@Entity
@Table(name = "devolucion_detalle")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DevolucionDetalle {

    @EmbeddedId
    private DevolucionDetalleId id;

    @Column(name = "estado_herramienta", length = 50, nullable = false)
    private String estadoHerramienta;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("devolucionNum")
    @JoinColumn(name = "devolucion_num")
    private Devolucion devolucion;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "cod_herramienta", nullable = false)
    private Herramienta herramienta;

    public EstadoDevolucion getEstadoHerramientaEnum() {
        return EstadoDevolucion.fromString(this.estadoHerramienta);
    }

    public void setEstadoHerramientaEnum(EstadoDevolucion estado) {
        this.estadoHerramienta = estado.getDescripcionSql();
    }
}