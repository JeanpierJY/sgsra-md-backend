package com.masterdrilling.sgsramd.dto.request;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

// Alta de nuevo componente en el catalogo maestro (RF32)
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CrearRepuestoRequest {

    @NotBlank(message = "El codigo de parte es obligatorio")
    @Size(max = 30, message = "El codigo de parte no puede superar 30 caracteres")
    private String codParte;

    @NotBlank(message = "El nombre del repuesto es obligatorio")
    @Size(max = 150, message = "El nombre no puede superar 150 caracteres")
    private String nombreRepuesto;

    @NotNull(message = "El stock actual es obligatorio")
    @Min(value = 0, message = "El stock inicial no puede ser negativo")
    private Integer stockActual;

    @NotNull(message = "El stock minimo es obligatorio")
    @Min(value = 0, message = "El stock de seguridad no puede ser negativo")
    private Integer stockMinimo;

    private String descripcion;
}