package com.masterdrilling.sgsramd.service.impl;

import com.masterdrilling.sgsramd.DAO.Repuesto_DAO;
import com.masterdrilling.sgsramd.dto.request.ActualizarRepuestoRequest;
import com.masterdrilling.sgsramd.dto.request.CrearRepuestoRequest;
import com.masterdrilling.sgsramd.dto.response.MensajeGenericoResponse;
import com.masterdrilling.sgsramd.dto.response.RepuestoResponse;
import com.masterdrilling.sgsramd.exception.BadRequestException;
import com.masterdrilling.sgsramd.exception.RecursoNoEncontradoException;
import com.masterdrilling.sgsramd.model.entity.Repuesto;
import com.masterdrilling.sgsramd.service.ICatalogoService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class CatalogoServiceImpl implements ICatalogoService {

    private final Repuesto_DAO repuestoRepository;

    @Override
    @Transactional(readOnly = true)
    public Page<RepuestoResponse> listarCatalogo(Pageable pageable) {
        return repuestoRepository.findByActivoTrue(pageable)
                .map(this::mapearAResponse);
    }

    @Override
    @Transactional(readOnly = true)
    public List<RepuestoResponse> buscarPredictivo(String termino) {
        if (termino == null || termino.trim().length() < 3) {
            return List.of();
        }
        return repuestoRepository.buscarPredictivo(termino.trim())
                .stream()
                .map(this::mapearAResponse)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public RepuestoResponse obtenerPorCodigo(String codParte) {
        Repuesto repuesto = repuestoRepository.findByCodParteAndActivoTrue(codParte)
                .orElseThrow(() -> new RecursoNoEncontradoException("Repuesto no encontrado con codigo: " + codParte));
        return mapearAResponse(repuesto);
    }

    @Override
    @Transactional
    public RepuestoResponse registrarRepuesto(CrearRepuestoRequest request) {
        if (repuestoRepository.existsById(request.getCodParte().trim())) {
            throw new BadRequestException("El codigo de parte ya se encuentra registrado en el sistema");
        }

        Repuesto nuevo = Repuesto.builder()
                .codParte(request.getCodParte().trim().toUpperCase())
                .nombreRepuesto(request.getNombreRepuesto().trim())
                .stockActual(request.getStockActual())
                .stockMinimo(request.getStockMinimo())
                .descripcion(request.getDescripcion())
                .activo(true)
                .build();

        return mapearAResponse(repuestoRepository.save(nuevo));
    }

    private RepuestoResponse mapearAResponse(Repuesto r) {
        return RepuestoResponse.builder()
                .codParte(r.getCodParte())
                .nombreRepuesto(r.getNombreRepuesto())
                .stockActual(r.getStockActual())
                .stockMinimo(r.getStockMinimo())
                .descripcion(r.getDescripcion())
                .activo(r.getActivo())
                .build();
    }

    @Override
    @Transactional
    public RepuestoResponse actualizarRepuesto(String codParte, ActualizarRepuestoRequest request) {
        Repuesto rep = repuestoRepository.findById(codParte.trim())
                .orElseThrow(() -> new RecursoNoEncontradoException("Repuesto no encontrado: " + codParte));

        rep.setNombreRepuesto(request.getNombreRepuesto().trim());
        rep.setStockActual(request.getStockActual());
        rep.setStockMinimo(request.getStockMinimo());
        if (request.getDescripcion() != null) {
            rep.setDescripcion(request.getDescripcion().trim());
        }

        return mapearAResponse(repuestoRepository.save(rep));
    }

    @Override
    @Transactional
    public MensajeGenericoResponse cambiarEstadoRepuesto(String codParte, boolean activo) {
        Repuesto rep = repuestoRepository.findById(codParte.trim())
                .orElseThrow(() -> new RecursoNoEncontradoException("Repuesto no encontrado: " + codParte));

        rep.setActivo(activo);
        repuestoRepository.save(rep);

        return MensajeGenericoResponse.builder()
                .exito(true)
                .mensaje("Estado de repuesto " + codParte + " actualizado a: " + (activo ? "HABILITADO" : "DESHABILITADO"))
                .dato(rep.getActivo())
                .build();
    }
}