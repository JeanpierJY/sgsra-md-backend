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

    @Query("SELECT a FROM AuditoriaOperacion a WHERE " +
           "(CAST(:idOperacion AS string) IS NULL OR a.idOperacion = :idOperacion) AND " +
           "(CAST(:fechaInicio AS java.time.LocalDateTime) IS NULL OR a.timestamp >= :fechaInicio) AND " +
           "(CAST(:fechaFin AS java.time.LocalDateTime) IS NULL OR a.timestamp <= :fechaFin) " +
           "ORDER BY a.timestamp DESC")
    Page<AuditoriaOperacion> filtrarAuditoria(
            @Param("idOperacion") String idOperacion,
            @Param("fechaInicio") LocalDateTime fechaInicio,
            @Param("fechaFin") LocalDateTime fechaFin,
            Pageable pageable
    );
}