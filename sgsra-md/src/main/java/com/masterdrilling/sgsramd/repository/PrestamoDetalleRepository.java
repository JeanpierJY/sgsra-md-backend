package com.masterdrilling.sgsramd.repository;

import com.masterdrilling.sgsramd.model.entity.PrestamoDetalle;
import com.masterdrilling.sgsramd.model.entity.PrestamoDetalleId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

// DAO para lineas y firmas de herramientas despachadas
@Repository
public interface PrestamoDetalleRepository extends JpaRepository<PrestamoDetalle, PrestamoDetalleId> {

    List<PrestamoDetalle> findByIdPrestamoNum(String prestamoNum);
}