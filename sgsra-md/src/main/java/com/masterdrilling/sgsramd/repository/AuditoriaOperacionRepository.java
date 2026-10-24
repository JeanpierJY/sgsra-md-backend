package com.masterdrilling.sgsramd.repository;

import com.masterdrilling.sgsramd.model.entity.AuditoriaOperacion;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;

// DAO inalterable append-only para auditoria y sellado SHA-256 (RF49)
@Repository
public interface AuditoriaOperacionRepository extends JpaRepository<AuditoriaOperacion, Long> {

    Page<AuditoriaOperacion> findAllByOrderByTimestampDesc(Pageable pageable);

    @Query("SELECT a FROM AuditoriaOperacion a WHERE " +
           "(:idOperacion IS NULL OR a.idOperacion = :idOperacion) AND " +
           "(:fechaInicio IS NULL OR a.timestamp >= :fechaInicio) AND " +
           "(:fechaFin IS NULL OR a.timestamp <= :fechaFin) " +
           "ORDER BY a.timestamp DESC")
    Page<AuditoriaOperacion> filtrarAuditoria(
            @Param("idOperacion") String idOperacion,
            @Param("fechaInicio") LocalDateTime fechaInicio,
            @Param("fechaFin") LocalDateTime fechaFin,
            Pageable pageable
    );
}