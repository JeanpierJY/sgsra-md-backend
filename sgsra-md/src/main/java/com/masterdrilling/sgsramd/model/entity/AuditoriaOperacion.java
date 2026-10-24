package com.masterdrilling.sgsramd.model.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

// Registro inalterablecon sello criptografico
@Entity
@Table(name = "auditoria_operacion")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AuditoriaOperacion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_auditoria")
    private Long idAuditoria;

    @Column(name = "id_operacion", length = 50, nullable = false)
    private String idOperacion;

    @Column(name = "id_usuario")
    private Long idUsuario;

    @Column(name = "accion", length = 50, nullable = false)
    private String accion;

    @Column(name = "ip_origen", length = 45, nullable = false)
    private String ipOrigen;

    @Column(name = "timestamp", nullable = false)
    @Builder.Default
    private LocalDateTime timestamp = LocalDateTime.now();

    @Column(name = "hash_sha256", length = 64, nullable = false)
    private String hashSha256;
}