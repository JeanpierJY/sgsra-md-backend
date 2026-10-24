package com.masterdrilling.sgsramd.repository;

import com.masterdrilling.sgsramd.model.entity.Administrador;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

// DAO para jefatura administrativa de taller mina

public interface AdministradorRepository extends JpaRepository<Administrador, String> {

    Optional<Administrador> findByDniAdministrador(String dniAdministrador);
}