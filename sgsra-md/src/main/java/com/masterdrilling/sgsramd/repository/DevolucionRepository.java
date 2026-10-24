package com.masterdrilling.sgsramd.repository;

import com.masterdrilling.sgsramd.model.entity.Devolucion;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

// DAO para actas de recepcion fisica de herramientas (RF38, RF40)

public interface DevolucionRepository extends JpaRepository<Devolucion, String> {

    Optional<Devolucion> findByPrestamoPrestamoNum(String prestamoNum);
}