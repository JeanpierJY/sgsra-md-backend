package com.masterdrilling.sgsramd.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

// Declaracion formal de extravio de herramienta (RF41, RF42)
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ReporteExtravioRequest {

    @NotBlank(message = "El codigo de herramienta extraviada es obligatorio")
    private String codHerramienta;

    @NotBlank(message = "Debe describir las circunstancias del extravio")
    @Size(min = 10, max = 300, message = "La explicacion debe tener entre 10 y 300 caracteres")
    private String motivoExtravio;
}