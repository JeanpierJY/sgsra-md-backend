package com.masterdrilling.sgsramd.repository;

import com.masterdrilling.sgsramd.model.entity.Maquinaria;
import com.masterdrilling.sgsramd.model.enums.EstadoMaquinaria;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

// DAO para flota de perforadoras pesadas (RF15)
@Repository
public interface MaquinariaRepository extends JpaRepository<Maquinaria, String> {

    List<Maquinaria> findByEstadoOperativo(EstadoMaquinaria estadoOperativo);
}