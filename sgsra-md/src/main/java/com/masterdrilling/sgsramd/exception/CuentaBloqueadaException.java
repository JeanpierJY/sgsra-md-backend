package com.masterdrilling.sgsramd.exception;

// RF04 / RF06: cuenta bloqueada temporal (con segundos restantes) o permanentemente
public class CuentaBloqueadaException extends RuntimeException {

    private final long segundosRestantes;
    private final boolean bloqueoPermanente;

    public CuentaBloqueadaException(String mensaje) {
        this(mensaje, 0, true);
    }

    public CuentaBloqueadaException(String mensaje, long segundosRestantes, boolean bloqueoPermanente) {
        super(mensaje);
        this.segundosRestantes = segundosRestantes;
        this.bloqueoPermanente = bloqueoPermanente;
    }

    public long getSegundosRestantes() {
        return segundosRestantes;
    }

    public boolean isBloqueoPermanente() {
        return bloqueoPermanente;
    }
}
