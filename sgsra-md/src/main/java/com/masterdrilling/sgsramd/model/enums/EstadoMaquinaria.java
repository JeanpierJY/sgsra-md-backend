package com.masterdrilling.sgsramd.model.enums;

// Condicion fisica y operativa de la flota pesada (RF15)
public enum EstadoMaquinaria {
    OPERATIVA,
    EN_MANTENIMIENTO,
    INOPERATIVA,
    BAJA;

    public static EstadoMaquinaria fromString(String estado) {
        if (estado == null) {
            throw new IllegalArgumentException("El estado de maquinaria no puede ser nulo");
        }
        for (EstadoMaquinaria em : EstadoMaquinaria.values()) {
            if (em.name().equalsIgnoreCase(estado.trim())) {
                return em;
            }
        }
        throw new IllegalArgumentException("Estado de maquinaria invalido: " + estado);
    }
}