package com.masterdrilling.sgsramd.DAO;

import com.masterdrilling.sgsramd.model.entity.Mecanico;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

// DAO mecanico
public interface Mecanico_DAO extends JpaRepository<Mecanico, String> {

    Optional<Mecanico> findByDniMecanico(String dniMecanico);
}