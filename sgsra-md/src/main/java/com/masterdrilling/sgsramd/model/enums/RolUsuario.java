package com.masterdrilling.sgsramd.model.enums;

// Definicion de roles de usuario para la aplicacion
public enum RolUsuario {
    MECANICO,
    ALMACENISTA,
    ADMINISTRADOR;

    public static RolUsuario fromString(String rol) {
        if (rol == null) {
            throw new IllegalArgumentException("El rol no puede ser nulo");
        }
        for (RolUsuario r : RolUsuario.values()) {
            if (r.name().equalsIgnoreCase(rol.trim())) {
                return r;
            }
        }
        throw new IllegalArgumentException("Rol de usuario invalido: " + rol);
    }
}