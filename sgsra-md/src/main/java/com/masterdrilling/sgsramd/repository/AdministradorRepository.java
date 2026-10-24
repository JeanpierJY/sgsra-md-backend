package com.masterdrilling.sgsramd.repository;

import com.masterdrilling.sgsramd.model.entity.Administrador;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

// DAO para jefatura administrativa de taller mina
@Repository
public interface AdministradorRepository extends JpaRepository<Administrador, String> {

    Optional<Administrador> findByDniAdministrador(String dniAdministrador);
}