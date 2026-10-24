package com.masterdrilling.sgsramd.model.enums;

// Ciclo de vida transaccional del requerimiento de repuestos (RF20, RF23, RF24, RF26, RF28)
public enum EstadoSolicitud {
    PENDIENTE,
    APROBADA,
    APROBADA_PARCIAL,
    RECHAZADA,
    ORDEN_CONTACTADA;

    public static EstadoSolicitud fromString(String estado) {
        if (estado == null) {
            return PENDIENTE;
        }
        String clean = estado.trim().toUpperCase().replace(" ", "_");
        for (EstadoSolicitud es : EstadoSolicitud.values()) {
            if (es.name().equals(clean)) {
                return es;
            }
        }
        throw new IllegalArgumentException("Estado de solicitud invalido: " + estado);
    }
}