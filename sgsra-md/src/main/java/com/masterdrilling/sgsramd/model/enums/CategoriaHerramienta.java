package com.masterdrilling.sgsramd.model.enums;

// Segmentacion tecnica en el inventario del panol (RF45)
public enum CategoriaHerramienta {
    ELECTRICAS("Electricas"),
    HIDRAULICAS("Hidraulicas"),
    NEUMATICAS("Neumaticas"),
    MANUALES("Manuales");

    private final String descripcionSql;

    CategoriaHerramienta(String descripcionSql) {
        this.descripcionSql = descripcionSql;
    }

    public String getDescripcionSql() {
        return descripcionSql;
    }

    public static CategoriaHerramienta fromString(String valor) {
        if (valor == null) {
            throw new IllegalArgumentException("La categoria no puede ser nula");
        }
        for (CategoriaHerramienta c : CategoriaHerramienta.values()) {
            if (c.descripcionSql.equalsIgnoreCase(valor.trim()) || c.name().equalsIgnoreCase(valor.trim())) {
                return c;
            }
        }
        throw new IllegalArgumentException("Categoria de herramienta invalida: " + valor);
    }
}