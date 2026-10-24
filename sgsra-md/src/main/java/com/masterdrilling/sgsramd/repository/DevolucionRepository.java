package com.masterdrilling.sgsramd.repository;

import com.masterdrilling.sgsramd.model.entity.Devolucion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

// DAO para actas de recepcion fisica de herramientas (RF38, RF40)
@Repository
public interface DevolucionRepository extends JpaRepository<Devolucion, String> {

    Optional<Devolucion> findByPrestamoPrestamoNum(String prestamoNum);
}