package com.masterdrilling.sgsramd.repository;

import com.masterdrilling.sgsramd.model.entity.Registro;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

// DAO para fichas de alta formal de herramientas en pañol (RF44)
@Repository
public interface RegistroRepository extends JpaRepository<Registro, String> {
}