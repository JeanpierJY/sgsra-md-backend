package com.masterdrilling.sgsramd.DAO;

import com.masterdrilling.sgsramd.model.entity.Registro;
import org.springframework.data.jpa.repository.JpaRepository;

// DAO para fichas de alta formal de herramientas en pañol (RF44)
public interface Registro_DAO extends JpaRepository<Registro, String> {
}