package com.masterdrilling.sgsramd.repository;

import com.masterdrilling.sgsramd.model.entity.Almacenista;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

// DAO para exposicion 
@Repository
public interface AlmacenistaRepository extends JpaRepository<Almacenista, String> {

    Optional<Almacenista> findByDniAlmacenista(String dniAlmacenista);
}