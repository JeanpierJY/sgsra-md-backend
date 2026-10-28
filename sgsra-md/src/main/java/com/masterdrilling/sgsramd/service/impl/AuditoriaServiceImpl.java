package com.masterdrilling.sgsramd.service.impl;

import com.masterdrilling.sgsramd.DAO.AuditoriaOperacion_DAO;
import com.masterdrilling.sgsramd.dto.response.AuditoriaResponse;
import com.masterdrilling.sgsramd.model.entity.AuditoriaOperacion;
import com.masterdrilling.sgsramd.service.IAuditoriaService;
import com.masterdrilling.sgsramd.util.HashUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class AuditoriaServiceImpl implements IAuditoriaService {

    private final AuditoriaOperacion_DAO auditoriaRepository;

    @Override
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void registrarAsiento(String idOperacion, Long idUsuario, String accion, String ipOrigen) {
        LocalDateTime ahora = LocalDateTime.now();
        String payloadParaHash = String.format("%s|%d|%s|%s|%s", idOperacion, idUsuario, accion, ipOrigen, ahora);
        String hash = HashUtil.generarHashSha256(payloadParaHash);

        AuditoriaOperacion registro = AuditoriaOperacion.builder()
                .idOperacion(idOperacion)
                .idUsuario(idUsuario)
                .accion(accion)
                .ipOrigen(ipOrigen)
                .timestamp(ahora)
                .hashSha256(hash)
                .build();

        auditoriaRepository.save(registro);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<AuditoriaResponse> consultarBitacora(String idOperacion, LocalDateTime fechaInicio, LocalDateTime fechaFin, Pageable pageable) {
        return auditoriaRepository.filtrarAuditoria(idOperacion, fechaInicio, fechaFin, pageable)
                .map(a -> AuditoriaResponse.builder()
                        .idAuditoria(a.getIdAuditoria())
                        .idOperacion(a.getIdOperacion())
                        .idUsuario(a.getIdUsuario())
                        .accion(a.getAccion())
                        .ipOrigen(a.getIpOrigen())
                        .timestamp(a.getTimestamp())
                        .hashSha256(a.getHashSha256())
                        .build());
    }
}