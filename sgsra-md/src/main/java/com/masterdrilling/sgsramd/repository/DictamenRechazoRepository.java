package com.masterdrilling.sgsramd.repository;

import com.masterdrilling.sgsramd.model.entity.DictamenRechazo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

// DAO para resoluciones administrativas de rechazo (RF24, RF25)
@Repository
public interface DictamenRechazoRepository extends JpaRepository<DictamenRechazo, String> {

    Optional<DictamenRechazo> findBySolicitudSolicitudNum(String solicitudNum);
}