package com.masterdrilling.sgsramd.model.enums;

// Estado operativo y de custodia del activo en panol (RF33, RF37, RF40, RF41, RF43)
public enum EstadoHerramienta {
    DISPONIBLE("Disponible"),
    PRESTADA("Prestada"),
    EN_MORA("En Mora"),
    EN_MANTENIMIENTO("En Mantenimiento"),
    EXTRAVIADA("Extraviada"),
    BAJA_TECNICA("Baja Tecnica");

    private final String descripcionSql;

    EstadoHerramienta(String descripcionSql) {
        this.descripcionSql = descripcionSql;
    }

    public String getDescripcionSql() {
        return descripcionSql;
    }

    public static EstadoHerramienta fromString(String valor) {
        if (valor == null) {
            throw new IllegalArgumentException("El estado de herramienta no puede ser nulo");
        }
        for (EstadoHerramienta e : EstadoHerramienta.values()) {
            if (e.descripcionSql.equalsIgnoreCase(valor.trim()) || e.name().equalsIgnoreCase(valor.trim().replace(" ", "_"))) {
                return e;
            }
        }
        throw new IllegalArgumentException("Estado de herramienta invalido: " + valor);
    }
}