package com.masterdrilling.sgsramd.model.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.io.Serializable;

// Llave compuesta para devolucion_detalle (devolucion_num, item)
@Embeddable
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DevolucionDetalleId implements Serializable {

    @Column(name = "devolucion_num", length = 20)
    private String devolucionNum;

    @Column(name = "item")
    private Integer item;
}