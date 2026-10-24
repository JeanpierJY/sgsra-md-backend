package com.masterdrilling.sgsramd.model.enums;

// Situacion transaccional del prestamo de herramientas (RF36, RF40, RF43)
public enum EstadoPrestamo {
    ACTIVO,
    CERRADO,
    MORA;

    public static EstadoPrestamo fromString(String estado) {
        if (estado == null) {
            return ACTIVO;
        }
        for (EstadoPrestamo ep : EstadoPrestamo.values()) {
            if (ep.name().equalsIgnoreCase(estado.trim())) {
                return ep;
            }
        }
        throw new IllegalArgumentException("Estado de prestamo invalido: " + estado);
    }
}