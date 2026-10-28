package com.masterdrilling.sgsramd.DAO;

import com.masterdrilling.sgsramd.model.entity.Administrador;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

// DAO para jefatura administrativa de taller mina

public interface Administrador_DAO extends JpaRepository<Administrador, String> {

    Optional<Administrador> findByDniAdministrador(String dniAdministrador);
}