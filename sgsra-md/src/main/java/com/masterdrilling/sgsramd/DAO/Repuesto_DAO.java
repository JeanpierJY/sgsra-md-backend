package com.masterdrilling.sgsramd.DAO;

import com.masterdrilling.sgsramd.model.entity.Repuesto;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

// DAO para catalogo de repuestos y busqueda predictiva (RF09, RF10, RF32)
public interface Repuesto_DAO extends JpaRepository<Repuesto, String> {

    Optional<Repuesto> findByCodParteAndActivoTrue(String codParte);

    Page<Repuesto> findByActivoTrue(Pageable pageable);

    Page<Repuesto> findByActivoTrueOrderByCodParteAsc(Pageable pageable);

    @Query("SELECT r FROM Repuesto r WHERE r.activo = true AND " +
           "(LOWER(r.nombreRepuesto) LIKE LOWER(CONCAT('%', :termino, '%')) OR " +
           "LOWER(r.codParte) LIKE LOWER(CONCAT('%', :termino, '%'))) ORDER BY r.codParte")
    List<Repuesto> buscarPredictivo(@Param("termino") String termino);

    // MEC-01: unidades comprometidas en solicitudes aun no despachadas (no descuentan stock hasta la entrega)
    @Query("SELECT COALESCE(SUM(d.cantidadRepuesto), 0) FROM SolicitudDetalle d WHERE d.repuesto.codParte = :codParte " +
           "AND d.estadoItem <> com.masterdrilling.sgsramd.model.enums.EstadoItemSolicitud.RECHAZADO " +
           "AND d.solicitud.estadoSolicitud IN (com.masterdrilling.sgsramd.model.enums.EstadoSolicitud.PENDIENTE, " +
           "com.masterdrilling.sgsramd.model.enums.EstadoSolicitud.APROBADA, " +
           "com.masterdrilling.sgsramd.model.enums.EstadoSolicitud.APROBADA_PARCIAL)")
    Long sumarCantidadReservada(@Param("codParte") String codParte);

    @Query("SELECT r FROM Repuesto r WHERE r.activo = true AND r.stockActual <= r.stockMinimo")
    List<Repuesto> findRepuestosBajoStockMinimo();
}