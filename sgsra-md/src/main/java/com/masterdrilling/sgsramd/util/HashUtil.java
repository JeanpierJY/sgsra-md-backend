package com.masterdrilling.sgsramd.util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

// Utilidad criptografica para generacion de firmas SHA-256 en auditoria inalterable (RF49)
public final class HashUtil {

    private HashUtil() {
    }

    public static String generarHashSha256(String entrada) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hashBytes = digest.digest(entrada.getBytes(StandardCharsets.UTF_8));
            StringBuilder hexString = new StringBuilder();
            for (byte b : hashBytes) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) {
                    hexString.append('0');
                }
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("Error al inicializar algoritmo SHA-256", e);
        }
    }
}