package com.masterdrilling.sgsramd.DAO;

import com.masterdrilling.sgsramd.model.entity.Maquinaria;
import com.masterdrilling.sgsramd.model.enums.EstadoMaquinaria;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

// DAO para flota de perforadoras pesadas (RF15)
public interface Maquinaria_DAO extends JpaRepository<Maquinaria, String> {

    List<Maquinaria> findByEstadoOperativo(EstadoMaquinaria estadoOperativo);
}