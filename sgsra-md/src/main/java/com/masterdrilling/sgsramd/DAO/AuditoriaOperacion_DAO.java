package com.masterdrilling.sgsramd.DAO;

import com.masterdrilling.sgsramd.model.entity.AuditoriaOperacion;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;


import java.time.LocalDateTime;

// DAO inalterable append-only para auditoria y sellado SHA-256 (RF49)

public interface AuditoriaOperacion_DAO extends JpaRepository<AuditoriaOperacion, Long> {

    Page<AuditoriaOperacion> findAllByOrderByTimestampDesc(Pageable pageable);

    // ADM-02: sin CAST de parametros nulos (PostgreSQL lanzaba 42P18 y la app mostraba datos de respaldo)
    @Query("SELECT a FROM AuditoriaOperacion a WHERE a.timestamp >= :fechaInicio AND a.timestamp <= :fechaFin " +
           "ORDER BY a.timestamp DESC")
    Page<AuditoriaOperacion> filtrarPorFechas(
            @Param("fechaInicio") LocalDateTime fechaInicio,
            @Param("fechaFin") LocalDateTime fechaFin,
            Pageable pageable
    );

    @Query("SELECT a FROM AuditoriaOperacion a WHERE a.timestamp >= :fechaInicio AND a.timestamp <= :fechaFin AND " +
           "(LOWER(a.idOperacion) LIKE LOWER(CONCAT('%', :termino, '%')) OR LOWER(a.accion) LIKE LOWER(CONCAT('%', :termino, '%'))) " +
           "ORDER BY a.timestamp DESC")
    Page<AuditoriaOperacion> filtrarPorTermino(
            @Param("termino") String termino,
            @Param("fechaInicio") LocalDateTime fechaInicio,
            @Param("fechaFin") LocalDateTime fechaFin,
            Pageable pageable
    );
}
