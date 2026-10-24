package com.masterdrilling.sgsramd.repository;

import com.masterdrilling.sgsramd.model.entity.Prestamo;
import com.masterdrilling.sgsramd.model.enums.EstadoPrestamo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

// DAO para custodia y trazabilidad de herramientas (RF36, RF42, RF43)
@Repository
public interface PrestamoRepository extends JpaRepository<Prestamo, String> {

    List<Prestamo> findByMecanicoDniMecanicoAndEstadoPrestamo(String dniMecanico, EstadoPrestamo estadoPrestamo);

    // Validacion de cupo: cuenta cuantas herramientas tiene activas el mecanico (limite 5)
    @Query("SELECT COUNT(pd) FROM PrestamoDetalle pd " +
           "WHERE pd.prestamo.mecanico.dniMecanico = :dniMecanico " +
           "AND pd.prestamo.estadoPrestamo = 'ACTIVO'")
    long contarHerramientasActivasPorMecanico(@Param("dniMecanico") String dniMecanico);

    // Verifica si el mecanico tiene alguna herramienta retenida con plazo vencido (RF36 Ex1)
    @Query("SELECT COUNT(p) FROM Prestamo p " +
           "WHERE p.mecanico.dniMecanico = :dniMecanico " +
           "AND p.estadoPrestamo = 'MORA'")
    long contarPrestamosEnMoraPorMecanico(@Param("dniMecanico") String dniMecanico);

    // Identifica el ultimo prestamo activo asociado a una herramienta fisica para devolucion
    @Query("SELECT p FROM Prestamo p JOIN p.detalles d " +
           "WHERE d.herramienta.codHerramienta = :codHerramienta " +
           "AND p.estadoPrestamo IN ('ACTIVO', 'MORA')")
    Optional<Prestamo> findPrestamoActivoByHerramienta(@Param("codHerramienta") String codHerramienta);

    // Rastreo de bitacora para imputacion de herramientas extraviadas al ultimo custodio (RF42)
    @Query("SELECT p.mecanico.dniMecanico FROM Prestamo p JOIN p.detalles d " +
           "WHERE d.herramienta.codHerramienta = :codHerramienta " +
           "ORDER BY p.fechaPrestamo DESC, p.horaSalida DESC LIMIT 1")
    Optional<String> findUltimoMecanicoCustodio(@Param("codHerramienta") String codHerramienta);
}