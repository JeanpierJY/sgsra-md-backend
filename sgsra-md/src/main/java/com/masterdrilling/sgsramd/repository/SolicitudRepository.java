package com.masterdrilling.sgsramd.repository;

import com.masterdrilling.sgsramd.model.entity.Solicitud;
import com.masterdrilling.sgsramd.model.enums.EstadoSolicitud;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

// DAO para cabecera de solicitudes de piezas (RF17, RF19, RF21, RF29, RF31)
@Repository
public interface SolicitudRepository extends JpaRepository<Solicitud, String> {

    Page<Solicitud> findByMecanicoDniMecanicoOrderByFechaEmisionDescHoraEmisionDesc(String dniMecanico, Pageable pageable);

    List<Solicitud> findByEstadoSolicitudOrderByFechaEmisionDescHoraEmisionDesc(EstadoSolicitud estadoSolicitud);

    @Query("SELECT s FROM Solicitud s WHERE " +
           "(:estado IS NULL OR s.estadoSolicitud = :estado) AND " +
           "(:fechaInicio IS NULL OR s.fechaEmision >= :fechaInicio) AND " +
           "(:fechaFin IS NULL OR s.fechaEmision <= :fechaFin) AND " +
           "(:codMaquina IS NULL OR s.maquinaria.codMaquinaria = :codMaquina) " +
           "ORDER BY s.fechaEmision DESC, s.horaEmision DESC")
    Page<Solicitud> filtrarMulticriterioAuditoria(
            @Param("estado") EstadoSolicitud estado,
            @Param("fechaInicio") LocalDate fechaInicio,
            @Param("fechaFin") LocalDate fechaFin,
            @Param("codMaquina") String codMaquina,
            Pageable pageable
    );

    @Query("SELECT COUNT(s) FROM Solicitud s WHERE s.estadoSolicitud = :estado")
    long countByEstadoSolicitud(@Param("estado") EstadoSolicitud estado);

    @Query("SELECT MAX(s.solicitudNum) FROM Solicitud s WHERE s.solicitudNum LIKE CONCAT('SOL-', :anio, '-%')")
    String findUltimoCorrelativoPorAnio(@Param("anio") String anio);
}