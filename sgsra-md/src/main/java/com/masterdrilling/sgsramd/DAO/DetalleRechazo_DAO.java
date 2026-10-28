package com.masterdrilling.sgsramd.DAO;

import com.masterdrilling.sgsramd.model.entity.DetalleRechazo;
import com.masterdrilling.sgsramd.model.entity.DetalleRechazoId;
import org.springframework.data.jpa.repository.JpaRepository;


import java.util.List;

// DAO para desglose de items no autorizados (RF26)

public interface DetalleRechazo_DAO extends JpaRepository<DetalleRechazo, DetalleRechazoId> {

    List<DetalleRechazo> findByIdDictamenNum(String dictamenNum);
}