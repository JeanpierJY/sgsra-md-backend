package com.masterdrilling.sgsramd.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

// Marcado de requerimiento como orden contactada con cotizacion formal (RF28)
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ContactarProveedorRequest {

    @NotBlank(message = "El numero de cotizacion formal del proveedor es obligatorio")
    private String codigoCotizacion;
}