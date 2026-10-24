package com.masterdrilling.sgsramd.model.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.io.Serializable;

// Llave compuesta para solicitud_detalle (solicitud_num, item)
@Embeddable
@Data
@NoArgsConstructor
@AllArgsConstructor
public class SolicitudDetalleId implements Serializable {

    @Column(name = "solicitud_num", length = 20)
    private String solicitudNum;

    @Column(name = "item")
    private Integer item;
}