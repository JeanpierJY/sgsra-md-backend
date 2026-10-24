package com.masterdrilling.sgsramd.repository;

import com.masterdrilling.sgsramd.model.entity.RegistroDetalle;
import com.masterdrilling.sgsramd.model.entity.RegistroDetalleId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

// DAO para lineas de detalle de altas de herramientas
@Repository
public interface RegistroDetalleRepository extends JpaRepository<RegistroDetalle, RegistroDetalleId> {

    List<RegistroDetalle> findByIdRegistroNum(String registroNum);
}