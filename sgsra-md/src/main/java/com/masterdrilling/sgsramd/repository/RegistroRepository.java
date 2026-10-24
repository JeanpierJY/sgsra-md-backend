package com.masterdrilling.sgsramd.repository;

import com.masterdrilling.sgsramd.model.entity.Registro;
import org.springframework.data.jpa.repository.JpaRepository;

// DAO para fichas de alta formal de herramientas en pañol (RF44)
public interface RegistroRepository extends JpaRepository<Registro, String> {
}