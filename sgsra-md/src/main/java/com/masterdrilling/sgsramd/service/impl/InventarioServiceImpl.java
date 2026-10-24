package com.masterdrilling.sgsramd.service.impl;

import com.masterdrilling.sgsramd.dto.request.RegistrarHerramientaRequest;
import com.masterdrilling.sgsramd.dto.response.DashboardStockResponse;
import com.masterdrilling.sgsramd.dto.response.FichaHerramientaResponse;
import com.masterdrilling.sgsramd.exception.BadRequestException;
import com.masterdrilling.sgsramd.exception.RecursoNoEncontradoException;
import com.masterdrilling.sgsramd.model.entity.*;
import com.masterdrilling.sgsramd.model.enums.CategoriaHerramienta;
import com.masterdrilling.sgsramd.model.enums.EstadoHerramienta;
import com.masterdrilling.sgsramd.repository.*;
import com.masterdrilling.sgsramd.service.IInventarioService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class InventarioServiceImpl implements IInventarioService {

    private final HerramientaRepository herramientaRepository;
    private final AlmacenistaRepository almacenistaRepository;
    private final UsuarioRepository usuarioRepository;
    private final RegistroRepository registroRepository;

    @Override
    @Transactional(readOnly = true)
    public DashboardStockResponse obtenerMetricasDashboard() {
        List<Object[]> resultados = herramientaRepository.contarHerramientasPorEstado();
        long disponibles = 0;
        long prestadas = 0;
        long enMora = 0;
        long enMantenimiento = 0;
        long extraviadas = 0;

        for (Object[] fila : resultados) {
            String estado = (String) fila[0];
            long cuenta = ((Number) fila[1]).longValue();

            if ("Disponible".equalsIgnoreCase(estado)) disponibles = cuenta;
            else if ("Prestada".equalsIgnoreCase(estado)) prestadas = cuenta;
            else if ("En Mora".equalsIgnoreCase(estado)) enMora = cuenta;
            else if ("En Mantenimiento".equalsIgnoreCase(estado)) enMantenimiento = cuenta;
            else if ("Extraviada".equalsIgnoreCase(estado)) extraviadas = cuenta;
        }

        return DashboardStockResponse.builder()
                .totalDisponibles(disponibles)
                .totalPrestadas(prestadas)
                .totalEnMora(enMora)
                .totalEnMantenimiento(enMantenimiento)
                .totalExtraviadas(extraviadas)
                .build();
    }

    @Override
    @Transactional(readOnly = true)
    public FichaHerramientaResponse consultarHerramientaPorCodigo(String codHerramienta) {
        Herramienta h = herramientaRepository.findByCodHerramienta(codHerramienta.trim())
                .orElseThrow(() -> new RecursoNoEncontradoException("Herramienta no registrada en panol: " + codHerramienta));
        return mapearAFicha(h);
    }

    @Override
    @Transactional(readOnly = true)
    public List<FichaHerramientaResponse> listarHerramientasPorCategoria(CategoriaHerramienta categoria) {
        List<Herramienta> lista = (categoria == null) 
                ? herramientaRepository.findAll() 
                : herramientaRepository.findByCategoria(categoria.getDescripcionSql());
        return lista.stream().map(this::mapearAFicha).toList();
    }

    @Override
    @Transactional
    public FichaHerramientaResponse registrarNuevaHerramienta(RegistrarHerramientaRequest request, String correoAlmacenista) {
        if (herramientaRepository.existsById(request.getCodHerramienta().trim())) {
            throw new BadRequestException("El codigo de serie de herramienta ya se encuentra registrado");
        }

        Usuario usuario = usuarioRepository.findByCorreoCorporativo(correoAlmacenista)
                .orElseThrow(() -> new RecursoNoEncontradoException("Almacenista no encontrado"));

        Almacenista alm = almacenistaRepository.findByDniAlmacenista(usuario.getDni())
                .orElseThrow(() -> new RecursoNoEncontradoException("Ficha de almacenista no existe"));

        Herramienta nueva = Herramienta.builder()
                .codHerramienta(request.getCodHerramienta().trim().toUpperCase())
                .nombreHerramienta(request.getNombreHerramienta().trim())
                .marcaHerramienta(request.getMarcaHerramienta().trim())
                .categoria(request.getCategoria().getDescripcionSql())
                .estadoActual(EstadoHerramienta.DISPONIBLE.getDescripcionSql())
                .build();

        Herramienta persistida = herramientaRepository.save(nueva);

        // Registro de alta formal
        String regNum = "REG-" + System.currentTimeMillis();
        Registro reg = Registro.builder()
                .registroNum(regNum)
                .fechaIngreso(LocalDate.now())
                .almacenista(alm)
                .detalles(new ArrayList<>())
                .build();

        RegistroDetalle rd = RegistroDetalle.builder()
                .id(new RegistroDetalleId(regNum, 1))
                .registro(reg)
                .herramienta(persistida)
                .build();

        reg.getDetalles().add(rd);
        registroRepository.save(reg);

        return mapearAFicha(persistida);
    }

    private FichaHerramientaResponse mapearAFicha(Herramienta h) {
        return FichaHerramientaResponse.builder()
                .codHerramienta(h.getCodHerramienta())
                .nombreHerramienta(h.getNombreHerramienta())
                .marcaHerramienta(h.getMarcaHerramienta())
                .categoria(h.getCategoria())
                .estadoActual(h.getEstadoActual())
                .build();
    }
}