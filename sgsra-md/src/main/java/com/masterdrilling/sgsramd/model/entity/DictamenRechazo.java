package com.masterdrilling.sgsramd.model.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

// Registro administrativo de rechazo formal
@Entity
@Table(name = "dictamen_rechazo")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DictamenRechazo {

    @Id
    @Column(name = "dictamen_num", length = 20)
    private String dictamenNum;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "ref_solicitud_num", referencedColumnName = "solicitud_num", nullable = false)
    private Solicitud solicitud;

    @Column(name = "fecha_evaluacion", nullable = false)
    private LocalDate fechaEvaluacion;

    @Column(name = "justificacion_rechazo", columnDefinition = "TEXT", nullable = false)
    private String justificacionRechazo;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "dni_administrador", nullable = false)
    private Administrador administrador;

    @OneToMany(mappedBy = "dictamenRechazo", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<DetalleRechazo> detallesRechazo = new ArrayList<>();
}