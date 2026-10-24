package com.masterdrilling.sgsramd.repository;

import com.masterdrilling.sgsramd.model.entity.DevolucionDetalle;
import com.masterdrilling.sgsramd.model.entity.DevolucionDetalleId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

// DAO para calificacion tecnica de herramientas retornadas (RF39)
@Repository
public interface DevolucionDetalleRepository extends JpaRepository<DevolucionDetalle, DevolucionDetalleId> {

    List<DevolucionDetalle> findByIdDevolucionNum(String devolucionNum);
}