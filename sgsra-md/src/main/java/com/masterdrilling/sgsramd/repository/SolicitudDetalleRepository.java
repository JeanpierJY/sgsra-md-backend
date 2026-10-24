package com.masterdrilling.sgsramd.repository;

import com.masterdrilling.sgsramd.model.entity.SolicitudDetalle;
import com.masterdrilling.sgsramd.model.entity.SolicitudDetalleId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

// DAO para lineas y estadisticas de repuestos (RF13, RF22, RF29)
@Repository
public interface SolicitudDetalleRepository extends JpaRepository<SolicitudDetalle, SolicitudDetalleId> {

    List<SolicitudDetalle> findByIdSolicitudNum(String solicitudNum);

    // Consulta de agregacion para top de componentes mas demandados (RF29)
    @Query("SELECT sd.repuesto.codParte, sd.repuesto.nombreRepuesto, SUM(sd.cantidadRepuesto) " +
           "FROM SolicitudDetalle sd " +
           "WHERE sd.solicitud.fechaEmision BETWEEN :fechaInicio AND :fechaFin " +
           "GROUP BY sd.repuesto.codParte, sd.repuesto.nombreRepuesto " +
           "ORDER BY SUM(sd.cantidadRepuesto) DESC")
    List<Object[]> obtenerDemandaPorPeriodo(@Param("fechaInicio") LocalDate fechaInicio,
                                            @Param("fechaFin") LocalDate fechaFin);
}