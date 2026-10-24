package com.masterdrilling.sgsramd.model.enums;

// Dictamen individual por componente en aprobaciones parciales (RF26)
public enum EstadoItemSolicitud {
    PENDIENTE,
    APROBADO,
    RECHAZADO;

    public static EstadoItemSolicitud fromString(String estado) {
        if (estado == null) {
            return PENDIENTE;
        }
        for (EstadoItemSolicitud eis : EstadoItemSolicitud.values()) {
            if (eis.name().equalsIgnoreCase(estado.trim())) {
                return eis;
            }
        }
        throw new IllegalArgumentException("Estado de item invalido: " + estado);
    }
}