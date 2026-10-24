package com.masterdrilling.sgsramd.repository;

import com.masterdrilling.sgsramd.model.entity.Mecanico;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

// DAO mecanico
public interface MecanicoRepository extends JpaRepository<Mecanico, String> {

    Optional<Mecanico> findByDniMecanico(String dniMecanico);
}