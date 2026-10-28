package com.masterdrilling.sgsramd.DAO;

import com.masterdrilling.sgsramd.model.entity.PrestamoDetalle;
import com.masterdrilling.sgsramd.model.entity.PrestamoDetalleId;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

// DAO para lineas y firmas de herramientas despachadas
public interface PrestamoDetalle_DAO extends JpaRepository<PrestamoDetalle, PrestamoDetalleId> {

    List<PrestamoDetalle> findByIdPrestamoNum(String prestamoNum);
}