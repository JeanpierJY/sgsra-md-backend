package com.masterdrilling.sgsramd.DAO;

import com.masterdrilling.sgsramd.model.entity.SolicitudRecuperacionClave;
import com.masterdrilling.sgsramd.model.enums.EstadoRecuperacion;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

// DAO de solicitudes de recuperacion de contrasena (RF06)
public interface SolicitudRecuperacionClave_DAO extends JpaRepository<SolicitudRecuperacionClave, Long> {

    List<SolicitudRecuperacionClave> findByEstadoOrderByFechaSolicitudAsc(EstadoRecuperacion estado);

    List<SolicitudRecuperacionClave> findAllByOrderByFechaSolicitudDesc();

    boolean existsByDniSolicitanteAndEstado(String dniSolicitante, EstadoRecuperacion estado);
}

