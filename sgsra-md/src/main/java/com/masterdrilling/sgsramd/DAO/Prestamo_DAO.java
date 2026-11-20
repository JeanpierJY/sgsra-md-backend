package com.masterdrilling.sgsramd.DAO;

import com.masterdrilling.sgsramd.model.entity.Prestamo;
import com.masterdrilling.sgsramd.model.enums.EstadoPrestamo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

// DAO para custodia y trazabilidad de herramientas (RF36, RF42, RF43)
public interface Prestamo_DAO extends JpaRepository<Prestamo, String> {

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

    // Identifica todos los prestamos de un mecanico especifico ordenados por fecha
    @Query("SELECT p FROM Prestamo p WHERE p.mecanico.dniMecanico = :dniMecanico ORDER BY p.fechaPrestamo DESC, p.horaSalida DESC")
    List<Prestamo> listarPorMecanico(@Param("dniMecanico") String dniMecanico);

    // Rastreo de bitacora para imputacion de herramientas extraviadas al ultimo custodio (RF42)
    @Query(value = "SELECT p.dni_mecanico FROM prestamo p " +
           "JOIN prestamo_detalle d ON p.prestamo_num = d.prestamo_num " +
           "WHERE d.cod_herramienta = :codHerramienta " +
           "ORDER BY p.fecha_prestamo DESC, p.hora_salida DESC LIMIT 1", nativeQuery = true)
    Optional<String> findUltimoMecanicoCustodio(@Param("codHerramienta") String codHerramienta);
}