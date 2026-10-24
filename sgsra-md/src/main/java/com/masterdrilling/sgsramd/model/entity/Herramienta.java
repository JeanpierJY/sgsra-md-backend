package com.masterdrilling.sgsramd.model.entity;

import com.masterdrilling.sgsramd.model.enums.CategoriaHerramienta;
import com.masterdrilling.sgsramd.model.enums.EstadoHerramienta;
import jakarta.persistence.*;
import lombok.*;

// Activo y herramienta controlada en panol
@Entity
@Table(name = "herramienta")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Herramienta {

    @Id
    @Column(name = "cod_herramienta", length = 30)
    private String codHerramienta;

    @Column(name = "nombre_herramienta", length = 150, nullable = false)
    private String nombreHerramienta;

    @Column(name = "marca_herramienta", length = 50, nullable = false)
    private String marcaHerramienta;

    @Column(name = "categoria", length = 30, nullable = false)
    private String categoria;

    @Column(name = "estado_actual", length = 30, nullable = false)
    private String estadoActual;

    public CategoriaHerramienta getCategoriaEnum() {
        return CategoriaHerramienta.fromString(this.categoria);
    }

    public void setCategoriaEnum(CategoriaHerramienta cat) {
        this.categoria = cat.getDescripcionSql();
    }

    public EstadoHerramienta getEstadoActualEnum() {
        return EstadoHerramienta.fromString(this.estadoActual);
    }

    public void setEstadoActualEnum(EstadoHerramienta estado) {
        this.estadoActual = estado.getDescripcionSql();
    }
}