package com.masterdrilling.sgsramd.model.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.LocalDateTime;

// [H-GEN-03] Imagenes subidas (repuestos, herramientas, perfiles, selfies) persistidas en PostgreSQL.
// El disco de Render es efimero: los archivos en /uploads se perdian en cada reinicio o redeploy.
@Entity
@Table(name = "archivo_almacenado")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ArchivoAlmacenado {

    // Ruta publica relativa sin el prefijo /uploads/ (ej: "perfiles/3f2a...jpg")
    @Id
    @Column(name = "ruta", length = 200)
    private String ruta;

    @Column(name = "content_type", length = 60, nullable = false)
    private String contentType;

    @JdbcTypeCode(SqlTypes.VARBINARY)
    @Column(name = "datos", columnDefinition = "bytea", nullable = false)
    private byte[] datos;

    @Column(name = "tamano_bytes", nullable = false)
    private Long tamanoBytes;

    @Column(name = "fecha_subida", nullable = false)
    @Builder.Default
    private LocalDateTime fechaSubida = LocalDateTime.now();
}
