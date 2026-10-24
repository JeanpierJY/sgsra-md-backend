package com.masterdrilling.sgsramd.repository;

import com.masterdrilling.sgsramd.model.entity.Mecanico;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

// DAO mecanico
@Repository
public interface MecanicoRepository extends JpaRepository<Mecanico, String> {

    Optional<Mecanico> findByDniMecanico(String dniMecanico);
}