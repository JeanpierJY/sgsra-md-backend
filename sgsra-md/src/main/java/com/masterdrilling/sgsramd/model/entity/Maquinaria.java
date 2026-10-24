package com.masterdrilling.sgsramd.model.entity;

import com.masterdrilling.sgsramd.model.enums.EstadoMaquinaria;
import jakarta.persistence.*;
import lombok.*;

// Entidad que representa la tabla "maquinaria" en la base de datos
@Entity
@Table(name = "maquinaria")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Maquinaria {

    @Id
    @Column(name = "cod_maquinaria", length = 20)
    private String codMaquinaria;

    @Column(name = "modelo_maquinaria", length = 100, nullable = false)
    private String modeloMaquinaria;

    @Column(name = "serie_fabricante", length = 50)
    private String serieFabricante;

    @Enumerated(EnumType.STRING)
    @Column(name = "estado_operativo", length = 20, nullable = false)
    private EstadoMaquinaria estadoOperativo;
}