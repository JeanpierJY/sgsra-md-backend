package com.masterdrilling.sgsramd.repository;

import com.masterdrilling.sgsramd.model.entity.DetalleRechazo;
import com.masterdrilling.sgsramd.model.entity.DetalleRechazoId;
import org.springframework.data.jpa.repository.JpaRepository;


import java.util.List;

// DAO para desglose de items no autorizados (RF26)

public interface DetalleRechazoRepository extends JpaRepository<DetalleRechazo, DetalleRechazoId> {

    List<DetalleRechazo> findByIdDictamenNum(String dictamenNum);
}