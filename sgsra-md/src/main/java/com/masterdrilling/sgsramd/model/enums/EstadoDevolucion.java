package com.masterdrilling.sgsramd.model.enums;

// Calificacion tecnica del retorno fisico de la herramienta (RF39, RF40)
public enum EstadoDevolucion {
    BUEN_ESTADO("Buen Estado"),
    CON_AVERIA("Con Averia"),
    INCOMPLETA("Incompleta");

    private final String descripcionSql;

    EstadoDevolucion(String descripcionSql) {
        this.descripcionSql = descripcionSql;
    }

    public String getDescripcionSql() {
        return descripcionSql;
    }

    public static EstadoDevolucion fromString(String valor) {
        if (valor == null) {
            throw new IllegalArgumentException("El estado de devolucion no puede ser nulo");
        }
        for (EstadoDevolucion ed : EstadoDevolucion.values()) {
            if (ed.descripcionSql.equalsIgnoreCase(valor.trim()) || ed.name().equalsIgnoreCase(valor.trim().replace(" ", "_"))) {
                return ed;
            }
        }
        throw new IllegalArgumentException("Estado de devolucion invalido: " + valor);
    }
}