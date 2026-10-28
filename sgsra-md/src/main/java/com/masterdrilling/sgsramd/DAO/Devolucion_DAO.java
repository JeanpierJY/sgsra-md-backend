package com.masterdrilling.sgsramd.DAO;

import com.masterdrilling.sgsramd.model.entity.Devolucion;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

// DAO para actas de recepcion fisica de herramientas (RF38, RF40)

public interface Devolucion_DAO extends JpaRepository<Devolucion, String> {

    Optional<Devolucion> findByPrestamoPrestamoNum(String prestamoNum);
}