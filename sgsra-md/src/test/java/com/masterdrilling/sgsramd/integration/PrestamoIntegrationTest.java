package com.masterdrilling.sgsramd.integration;

import com.masterdrilling.sgsramd.dto.request.DevolucionHerramientaRequest;
import com.masterdrilling.sgsramd.dto.request.RegistrarPrestamoRequest;
import com.masterdrilling.sgsramd.dto.response.MensajeGenericoResponse;
import com.masterdrilling.sgsramd.model.entity.Herramienta;
import com.masterdrilling.sgsramd.model.entity.Prestamo;
import com.masterdrilling.sgsramd.model.enums.EstadoDevolucion;
import com.masterdrilling.sgsramd.model.enums.EstadoHerramienta;
import com.masterdrilling.sgsramd.model.enums.EstadoPrestamo;
import com.masterdrilling.sgsramd.repository.HerramientaRepository;
import com.masterdrilling.sgsramd.repository.PrestamoRepository;
import com.masterdrilling.sgsramd.service.IPrestamoService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

// Prueba de integracion completa para ciclo de vida de prestamo y retorno fisico contra BD real
@SpringBootTest
@Transactional
class PrestamoIntegrationTest {

    @Autowired
    private IPrestamoService prestamoService;

    @Autowired
    private PrestamoRepository prestamoRepository;

    @Autowired
    private HerramientaRepository herramientaRepository;

    @Test
    @DisplayName("Debe despachar prestamo, mutar herramienta a Prestada y luego devolverla actualizando a Disponible")
    void testCicloCompletoPrestamoYDevolucion() {
        // 1. Registro de Prestamo
        RegistrarPrestamoRequest prestamoReq = RegistrarPrestamoRequest.builder()
                .dniMecanico("75859812")
                .codigosHerramienta(List.of("HER-TOR-004"))
                .firmaMecanico("FIRMA_DIGITAL_INTEGRACION")
                .build();

        MensajeGenericoResponse resPrestamo = prestamoService.registrarPrestamo(
                "marcos.ramos@masterdrilling.com", prestamoReq, "127.0.0.1");

        assertNotNull(resPrestamo);
        assertTrue(resPrestamo.isExito());
        String prestamoNum = (String) resPrestamo.getDato();

        // Validar persistencia de salida en base de datos
        Prestamo prestamoGuardado = prestamoRepository.findById(prestamoNum).orElse(null);
        assertNotNull(prestamoGuardado);
        assertEquals(EstadoPrestamo.ACTIVO, prestamoGuardado.getEstadoPrestamo());

        Herramienta herramientaEnPrestamo = herramientaRepository.findByCodHerramienta("HER-TOR-004").orElse(null);
        assertNotNull(herramientaEnPrestamo);
        assertEquals(EstadoHerramienta.PRESTADA.getDescripcionSql(), herramientaEnPrestamo.getEstadoActual());

        // 2. Registro de Devolucion Fisica
        DevolucionHerramientaRequest.ItemDevolucionRequest itemDev = DevolucionHerramientaRequest.ItemDevolucionRequest.builder()
                .codHerramienta("HER-TOR-004")
                .estadoFisico(EstadoDevolucion.BUEN_ESTADO)
                .build();

        DevolucionHerramientaRequest devolucionReq = DevolucionHerramientaRequest.builder()
                .prestamoNum(prestamoNum)
                .detalleIncidencia("Devolucion en turno sin observaciones")
                .items(List.of(itemDev))
                .build();

        MensajeGenericoResponse resDevolucion = prestamoService.registrarDevolucion(
                "marcos.ramos@masterdrilling.com", devolucionReq, "127.0.0.1");

        assertNotNull(resDevolucion);
        assertTrue(resDevolucion.isExito());

        // Validar liberacion de responsabilidad y retorno a estado Disponible
        Prestamo prestamoCerrado = prestamoRepository.findById(prestamoNum).orElse(null);
        assertNotNull(prestamoCerrado);
        assertEquals(EstadoPrestamo.CERRADO, prestamoCerrado.getEstadoPrestamo());

        Herramienta herramientaRetornada = herramientaRepository.findByCodHerramienta("HER-TOR-004").orElse(null);
        assertNotNull(herramientaRetornada);
        assertEquals(EstadoHerramienta.DISPONIBLE.getDescripcionSql(), herramientaRetornada.getEstadoActual());
    }
}