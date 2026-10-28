package com.masterdrilling.sgsramd.DAO;

import com.masterdrilling.sgsramd.model.entity.Herramienta;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

// DAO para pañol, escaneo QR y dashboard de stock (RF33, RF34, RF35, RF45)

public interface Herramienta_DAO extends JpaRepository<Herramienta, String> {

    Optional<Herramienta> findByCodHerramienta(String codHerramienta);

    List<Herramienta> findByCategoria(String categoria);

    List<Herramienta> findByEstadoActual(String estadoActual);

    // Conteo optimizado para las tarjetas metricas del dashboard (RF33)
    @Query("SELECT h.estadoActual, COUNT(h) FROM Herramienta h GROUP BY h.estadoActual")
    List<Object[]> contarHerramientasPorEstado();

    @Query("SELECT COUNT(h) FROM Herramienta h WHERE h.estadoActual = 'Disponible'")
    long countDisponibles();

    @Query("SELECT COUNT(h) FROM Herramienta h WHERE h.estadoActual = 'En Mora'")
    long countEnMora();
}