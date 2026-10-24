package com.masterdrilling.sgsramd.dto.request;

import com.masterdrilling.sgsramd.model.enums.CategoriaHerramienta;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

// Alta formal de nueva herramienta y generacion de codigo QR (RF44)
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RegistrarHerramientaRequest {

    @NotBlank(message = "El codigo de identificacion de herramienta es obligatorio")
    @Pattern(regexp = "^[A-Z0-9\\-]+$", message = "El codigo solo puede contener caracteres alfanumericos y guiones")
    @Size(max = 30, message = "El codigo no puede superar 30 caracteres")
    private String codHerramienta;

    @NotBlank(message = "El nombre tecnico de la herramienta es obligatorio")
    @Size(max = 150, message = "El nombre no puede superar 150 caracteres")
    private String nombreHerramienta;

    @NotBlank(message = "La marca de la herramienta es obligatoria")
    @Size(max = 50, message = "La marca no puede superar 50 caracteres")
    private String marcaHerramienta;

    @NotNull(message = "Debe seleccionar una categoria tecnica valida")
    private CategoriaHerramienta categoria;
}