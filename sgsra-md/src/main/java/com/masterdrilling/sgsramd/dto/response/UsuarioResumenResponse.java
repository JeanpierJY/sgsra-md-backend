package com.masterdrilling.sgsramd.dto.response;

import com.masterdrilling.sgsramd.model.enums.EstadoCuenta;
import com.masterdrilling.sgsramd.model.enums.RolUsuario;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

// DTO de salida para listado, busqueda y fiscalizacion administrativa de cuentas
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UsuarioResumenResponse {

    private Long idUsuario;
    private String dni;
    private String nombre;
    private String correoCorporativo;
    private RolUsuario rol;
    private EstadoCuenta estadoCuenta;
    private Integer intentosFallidos;
    private LocalDateTime creadoEn;
}