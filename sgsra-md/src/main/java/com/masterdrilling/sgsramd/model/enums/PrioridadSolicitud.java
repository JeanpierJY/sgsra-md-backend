package com.masterdrilling.sgsramd.model.enums;

// Nivel de urgencia asignado por el mecanico (RF14)
public enum PrioridadSolicitud {
    BAJA,
    MEDIA,
    ALTA;

    public static PrioridadSolicitud fromString(String prioridad) {
        if (prioridad == null) {
            throw new IllegalArgumentException("La prioridad no puede ser nula");
        }
        for (PrioridadSolicitud p : PrioridadSolicitud.values()) {
            if (p.name().equalsIgnoreCase(prioridad.trim())) {
                return p;
            }
        }
        throw new IllegalArgumentException("Prioridad de solicitud invalida: " + prioridad);
    }
}