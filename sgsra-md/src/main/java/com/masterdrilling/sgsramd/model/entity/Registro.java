package com.masterdrilling.sgsramd.model.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

// Ficha de ingreso e incorporacion de nuevas herramientas al inventario
@Entity
@Table(name = "registro")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Registro {

    @Id
    @Column(name = "registro_num", length = 20)
    private String registroNum;

    @Column(name = "fecha_ingreso", nullable = false)
    private LocalDate fechaIngreso;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "dni_almacenista", nullable = false)
    private Almacenista almacenista;

    @OneToMany(mappedBy = "registro", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<RegistroDetalle> detalles = new ArrayList<>();
}