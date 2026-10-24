package com.masterdrilling.sgsramd.model.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.io.Serializable;

// Llave compuesta para detalle_rechazo (dictamen_num, item)
@Embeddable
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DetalleRechazoId implements Serializable {

    @Column(name = "dictamen_num", length = 20)
    private String dictamenNum;

    @Column(name = "item")
    private Integer item;
}