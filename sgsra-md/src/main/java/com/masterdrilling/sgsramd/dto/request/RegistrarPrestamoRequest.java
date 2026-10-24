package com.masterdrilling.sgsramd.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Pattern;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

// Asignacion y despacho de herramientas en panol (RF36)
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RegistrarPrestamoRequest {

    @NotBlank(message = "El DNI del mecanico solicitante es obligatorio")
    @Pattern(regexp = "^[0-9]{8}$", message = "El DNI del mecanico debe tener 8 digitos")
    private String dniMecanico;

    @NotEmpty(message = "Debe indicar al menos una herramienta a prestar")
    private List<String> codigosHerramienta;

    @NotBlank(message = "La firma de recepcion del mecanico es obligatoria")
    private String firmaMecanico;
}