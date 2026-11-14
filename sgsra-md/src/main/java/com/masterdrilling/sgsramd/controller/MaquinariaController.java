package com.masterdrilling.sgsramd.controller;

import com.masterdrilling.sgsramd.DAO.Maquinaria_DAO;
import com.masterdrilling.sgsramd.model.entity.Maquinaria;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

// MEC-05 / RF15: consulta de la flota para seleccionar la maquinaria al crear una solicitud
@RestController
@RequestMapping("/api/v1/maquinarias")
@RequiredArgsConstructor
public class MaquinariaController {

    private final Maquinaria_DAO maquinariaRepository;

    @GetMapping
    public ResponseEntity<List<Map<String, Object>>> buscar(@RequestParam(value = "termino", required = false) String termino) {
        List<Maquinaria> lista = (termino == null || termino.isBlank())
                ? maquinariaRepository.findAll()
                : maquinariaRepository.buscarPredictivo(termino.trim());
        // Operativas primero; luego por codigo
        return ResponseEntity.ok(lista.stream()
                .sorted(Comparator.comparing((Maquinaria m) -> m.getEstadoOperativo() == null ? 9 : m.getEstadoOperativo().ordinal())
                        .thenComparing(Maquinaria::getCodMaquinaria))
                .limit(30)
                .map(m -> {
                    Map<String, Object> fila = new LinkedHashMap<>();
                    fila.put("codMaquinaria", m.getCodMaquinaria());
                    fila.put("modeloMaquinaria", m.getModeloMaquinaria());
                    fila.put("serieFabricante", m.getSerieFabricante());
                    fila.put("estadoOperativo", m.getEstadoOperativo() == null ? null : m.getEstadoOperativo().name());
                    return fila;
                })
                .toList());
    }
}
