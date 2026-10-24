package com.masterdrilling.sgsramd.model.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.io.Serializable;

// Llave compuesta para prestamo_detalle (prestamo_num, item)
@Embeddable
@Data
@NoArgsConstructor
@AllArgsConstructor
public class PrestamoDetalleId implements Serializable {

    @Column(name = "prestamo_num", length = 20)
    private String prestamoNum;

    @Column(name = "item")
    private Integer item;
}