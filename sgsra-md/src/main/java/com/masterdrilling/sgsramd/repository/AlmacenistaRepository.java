package com.masterdrilling.sgsramd.repository;

import com.masterdrilling.sgsramd.model.entity.Almacenista;
import org.springframework.data.jpa.repository.JpaRepository;


import java.util.Optional;

// DAO para exposicion 
public interface AlmacenistaRepository extends JpaRepository<Almacenista, String> {

    Optional<Almacenista> findByDniAlmacenista(String dniAlmacenista);
}