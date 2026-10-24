package com.masterdrilling.sgsramd.repository;

import com.masterdrilling.sgsramd.model.entity.Repuesto;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

// DAO para catalogo de repuestos y busqueda predictiva (RF09, RF10, RF32)
public interface RepuestoRepository extends JpaRepository<Repuesto, String> {

    Optional<Repuesto> findByCodParteAndActivoTrue(String codParte);

    Page<Repuesto> findByActivoTrue(Pageable pageable);

    @Query("SELECT r FROM Repuesto r WHERE r.activo = true AND " +
           "(LOWER(r.nombreRepuesto) LIKE LOWER(CONCAT('%', :termino, '%')) OR " +
           "LOWER(r.codParte) LIKE LOWER(CONCAT('%', :termino, '%')))")
    List<Repuesto> buscarPredictivo(@Param("termino") String termino);

    @Query("SELECT r FROM Repuesto r WHERE r.activo = true AND r.stockActual <= r.stockMinimo")
    List<Repuesto> findRepuestosBajoStockMinimo();
}