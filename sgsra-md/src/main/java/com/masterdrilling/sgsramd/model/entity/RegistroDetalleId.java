package com.masterdrilling.sgsramd.model.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.io.Serializable;

// Llave compuesta para registro_detalle (registro_num, item)
@Embeddable
@Data
@NoArgsConstructor
@AllArgsConstructor
public class RegistroDetalleId implements Serializable {

    @Column(name = "registro_num", length = 20)
    private String registroNum;

    @Column(name = "item")
    private Integer item;
}