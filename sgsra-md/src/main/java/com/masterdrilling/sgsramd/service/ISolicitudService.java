package com.masterdrilling.sgsramd.service;

import com.masterdrilling.sgsramd.dto.request.AprobacionParcialRequest;
import com.masterdrilling.sgsramd.dto.request.ContactarProveedorRequest;
import com.masterdrilling.sgsramd.dto.request.DictamenRechazoRequest;
import com.masterdrilling.sgsramd.dto.request.SolicitudRepuestoRequest;
import com.masterdrilling.sgsramd.dto.response.DetalleSolicitudResponse;
import com.masterdrilling.sgsramd.dto.response.MensajeGenericoResponse;
import com.masterdrilling.sgsramd.dto.response.SolicitudResumenResponse;
import com.masterdrilling.sgsramd.model.enums.EstadoSolicitud;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;

// Contrato de aprobacion, rechazo y requerimientos (RF13-RF28)
public interface ISolicitudService {
    MensajeGenericoResponse registrarSolicitud(String correoMecanico, SolicitudRepuestoRequest request, String ipOrigen);
    Page<SolicitudResumenResponse> listarHistorialMecanico(String correoMecanico, Pageable pageable);
    List<SolicitudResumenResponse> listarBandejaAdministrador(EstadoSolicitud estado);
    DetalleSolicitudResponse obtenerDetalleSolicitud(String solicitudNum);
    MensajeGenericoResponse aprobarSolicitudTotal(String solicitudNum, String ipOrigen);
    MensajeGenericoResponse rechazarSolicitudTotal(String solicitudNum, String correoAdmin, DictamenRechazoRequest request, String ipOrigen);
    MensajeGenericoResponse aprobarSolicitudParcial(String solicitudNum, String correoAdmin, AprobacionParcialRequest request, String ipOrigen);
    MensajeGenericoResponse marcarOrdenContactada(String solicitudNum, ContactarProveedorRequest request, String ipOrigen);
}