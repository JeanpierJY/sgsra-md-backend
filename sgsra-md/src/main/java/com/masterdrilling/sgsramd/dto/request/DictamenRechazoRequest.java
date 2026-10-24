package com.masterdrilling.sgsramd.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

// Resolucion de denegacion total de solicitud por parte de administracion (RF24, RF25)
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DictamenRechazoRequest {

    @NotBlank(message = "El motivo de rechazo es obligatorio")
    @Size(min = 15, max = 300, message = "El motivo de rechazo debe contener entre 15 y 300 caracteres")
    private String justificacionRechazo;
}