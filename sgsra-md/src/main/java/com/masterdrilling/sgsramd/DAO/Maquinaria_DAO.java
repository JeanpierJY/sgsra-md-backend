package com.masterdrilling.sgsramd.DAO;

import com.masterdrilling.sgsramd.model.entity.Maquinaria;
import com.masterdrilling.sgsramd.model.enums.EstadoMaquinaria;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

// DAO para flota de perforadoras pesadas (RF15)
public interface Maquinaria_DAO extends JpaRepository<Maquinaria, String> {

    List<Maquinaria> findByEstadoOperativo(EstadoMaquinaria estadoOperativo);

    // MEC-05: busqueda predictiva por codigo, modelo o serie
    @org.springframework.data.jpa.repository.Query("SELECT m FROM Maquinaria m WHERE "
            + "LOWER(m.codMaquinaria) LIKE LOWER(CONCAT('%', :termino, '%')) OR "
            + "LOWER(m.modeloMaquinaria) LIKE LOWER(CONCAT('%', :termino, '%')) OR "
            + "LOWER(m.serieFabricante) LIKE LOWER(CONCAT('%', :termino, '%')) ORDER BY m.codMaquinaria")
    List<Maquinaria> buscarPredictivo(@org.springframework.data.repository.query.Param("termino") String termino);
}