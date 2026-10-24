package com.masterdrilling.sgsramd.model.enums;

// Define el estado operativo y de bloqueo de la cuenta de usuario (RF06)
public enum EstadoCuenta {
    ACTIVO,
    BLOQUEADO,
    INACTIVO;

    public static EstadoCuenta fromString(String estado) {
        if (estado == null) {
            return ACTIVO;
        }
        for (EstadoCuenta e : EstadoCuenta.values()) {
            if (e.name().equalsIgnoreCase(estado.trim())) {
                return e;
            }
        }
        throw new IllegalArgumentException("Estado de cuenta invalido: " + estado);
    }
}