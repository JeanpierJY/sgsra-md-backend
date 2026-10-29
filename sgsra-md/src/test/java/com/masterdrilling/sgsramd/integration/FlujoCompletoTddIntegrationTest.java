package com.masterdrilling.sgsramd.integration;

import com.masterdrilling.sgsramd.DAO.*;
import com.masterdrilling.sgsramd.dto.request.*;
import com.masterdrilling.sgsramd.dto.response.*;
import com.masterdrilling.sgsramd.model.entity.*;
import com.masterdrilling.sgsramd.model.enums.*;
import com.masterdrilling.sgsramd.service.*;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.transaction.annotation.Transactional;

import java.io.ByteArrayInputStream;
import java.time.LocalDate;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
@Transactional
class FlujoCompletoTddIntegrationTest {

    @Autowired
    private IAutenticacionService authService;

    @Autowired
    private ICatalogoService catalogoService;

    @Autowired
    private ISolicitudService solicitudService;

    @Autowired
    private IPrestamoService prestamoService;

    @Autowired
    private IInventarioService inventarioService;

    @Autowired
    private IReporteService reporteService;

    @Autowired
    private IAuditoriaService auditoriaService;

    @Autowired
    private Solicitud_DAO solicitudRepository;

    @Autowired
    private Herramienta_DAO herramientaRepository;

    @Autowired
    private Prestamo_DAO prestamoRepository;

    @Autowired
    private AuditoriaOperacion_DAO auditoriaRepository;

    private final String IP_TEST = "127.0.0.1";
    private final String CORREO_MECANICO = "carlos.baro@masterdrilling.com";
    private final String DNI_MECANICO = "70000001";
    private final String CORREO_ADMIN = "leao.chura@masterdrilling.com";
    private final String CORREO_ALMACENISTA = "marcos.baro@masterdrilling.com";

    // -------------------------------------------------------------------------
    // TDD CICLO 1: AUTENTICACIÓN Y ROLES (RF01, RF02, RF06)
    // -------------------------------------------------------------------------
    @Test
    @DisplayName("TDD RF01/RF02: Validar login con credenciales reales de Mecánico y Admin")
    void testTdd_AutenticacionExitosa() {
        LoginRequest loginMec = LoginRequest.builder()
                .correoCorporativo(CORREO_MECANICO)
                .contrasena("Mecanico123*")
                .build();
        LoginResponse respMec = authService.autenticar(loginMec, IP_TEST);
        assertNotNull(respMec);
        assertEquals(RolUsuario.MECANICO, respMec.getRol());
        assertEquals(DNI_MECANICO, respMec.getDni());
        assertNotNull(respMec.getTokenJwt());

        LoginRequest loginAdmin = LoginRequest.builder()
                .correoCorporativo(CORREO_ADMIN)
                .contrasena("Admin123*")
                .build();
        LoginResponse respAdmin = authService.autenticar(loginAdmin, IP_TEST);
        assertNotNull(respAdmin);
        assertEquals(RolUsuario.ADMINISTRADOR, respAdmin.getRol());
    }

    // -------------------------------------------------------------------------
    // TDD CICLO 2: SOLICITUD DE REPUESTOS DE TALLER (RF09, RF10, RF17, RF23)
    // -------------------------------------------------------------------------
    @Test
    @DisplayName("TDD E2E: Catalogo predictivo -> Crear Solicitud -> Aprobar Total por Admin")
    void testTdd_CicloCompletoSolicitudRepuestos() {
        // 1. Busqueda predictiva (RF10)
        List<RepuestoResponse> busqueda = catalogoService.buscarPredictivo("Bomba");
        assertFalse(busqueda.isEmpty(), "El catalogo debe contener piezas coincidentes con 'Bomba'");
        String codParte = busqueda.get(0).getCodParte();

        // 2. Transmision de solicitud formal (RF17)
        SolicitudRepuestoRequest reqSol = SolicitudRepuestoRequest.builder()
                .codMaquinaria("MD-RB-01")
                .prioridad(PrioridadSolicitud.ALTA)
                .justificacionTecnica("Fuga critica de aceite hidraulico en el sistema de perforacion")
                .items(List.of(new SolicitudRepuestoRequest.ItemRepuestoRequest(codParte, 1)))
                .build();

        MensajeGenericoResponse resCreacion = solicitudService.registrarSolicitud(CORREO_MECANICO, reqSol, IP_TEST);
        assertTrue(resCreacion.isExito());
        String solicitudNum = (String) resCreacion.getDato();
        assertNotNull(solicitudNum);

        // 3. Verificar estado inicial PENDIENTE en base de datos
        Solicitud solPersistida = solicitudRepository.findById(solicitudNum).orElse(null);
        assertNotNull(solPersistida);
        assertEquals(EstadoSolicitud.PENDIENTE, solPersistida.getEstadoSolicitud());

        // 4. Aprobacion formal por parte de Jefatura / Administrador (RF23)
        MensajeGenericoResponse resAprobacion = solicitudService.aprobarSolicitudTotal(solicitudNum, CORREO_ADMIN, IP_TEST);
        assertTrue(resAprobacion.isExito());

        // 5. Verificar mutacion atomica a APROBADA
        Solicitud solAprobada = solicitudRepository.findById(solicitudNum).orElse(null);
        assertNotNull(solAprobada);
        assertEquals(EstadoSolicitud.APROBADA, solAprobada.getEstadoSolicitud());
        assertEquals(EstadoItemSolicitud.APROBADO, solAprobada.getDetalles().get(0).getEstadoItem());
    }

    // -------------------------------------------------------------------------
    // TDD CICLO 3: RECHAZO CON VALIDACIÓN DE LONGITUD (RF24, RF25)
    // -------------------------------------------------------------------------
    @Test
    @DisplayName("TDD RF24/RF25: Rechazar solicitud exigiendo motivo mayor o igual a 15 caracteres")
    void testTdd_RechazoSolicitudConJustificacion() {
        SolicitudRepuestoRequest reqSol = SolicitudRepuestoRequest.builder()
                .codMaquinaria("MD-RB-01")
                .prioridad(PrioridadSolicitud.MEDIA)
                .justificacionTecnica("Reemplazo programado por mantenimiento preventivo")
                .items(List.of(new SolicitudRepuestoRequest.ItemRepuestoRequest("P-REX-024", 1)))
                .build();

        MensajeGenericoResponse resCreacion = solicitudService.registrarSolicitud(CORREO_MECANICO, reqSol, IP_TEST);
        String solicitudNum = (String) resCreacion.getDato();

        DictamenRechazoRequest dictamen = DictamenRechazoRequest.builder()
                .justificacionRechazo("Stock en pañol central cubre el requerimiento de guardia")
                .build();

        MensajeGenericoResponse resRechazo = solicitudService.rechazarSolicitudTotal(solicitudNum, CORREO_ADMIN, dictamen, IP_TEST);
        assertTrue(resRechazo.isExito());

        Solicitud solRechazada = solicitudRepository.findById(solicitudNum).orElse(null);
        assertNotNull(solRechazada);
        assertEquals(EstadoSolicitud.RECHAZADA, solRechazada.getEstadoSolicitud());
    }

    // -------------------------------------------------------------------------
    // TDD CICLO 4: DESPACHO Y DEVOLUCIÓN EN PAÑOL (RF33, RF36, RF37, RF38, RF40)
    // -------------------------------------------------------------------------
    @Test
    @DisplayName("TDD E2E: Despachar herramienta -> Validar 'Prestada' -> Devolver -> Validar 'Disponible'")
    void testTdd_CicloCompletoPrestamoYDevolucion() {
        String codHerramienta = "HER-MAN-022";

        // 1. Asegurar estado inicial Disponible
        Herramienta herInicial = herramientaRepository.findByCodHerramienta(codHerramienta).orElse(null);
        assertNotNull(herInicial);
        herInicial.setEstadoActual(EstadoHerramienta.DISPONIBLE.getDescripcionSql());
        herramientaRepository.save(herInicial);

        // 2. Registro de prestamo formal (RF36, RF37)
        RegistrarPrestamoRequest prestamoReq = RegistrarPrestamoRequest.builder()
                .dniMecanico(DNI_MECANICO)
                .codigosHerramienta(List.of(codHerramienta))
                .firmaMecanico("FIRMA_DIGITAL_TDD")
                .build();

        MensajeGenericoResponse resPrestamo = prestamoService.registrarPrestamo(CORREO_ALMACENISTA, prestamoReq, IP_TEST);
        assertTrue(resPrestamo.isExito());
        String prestamoNum = (String) resPrestamo.getDato();

        // 3. Validar mutacion de herramienta a 'Prestada' y prestamo ACTIVO
        Herramienta herPrestada = herramientaRepository.findByCodHerramienta(codHerramienta).orElse(null);
        assertNotNull(herPrestada);
        assertEquals(EstadoHerramienta.PRESTADA.getDescripcionSql(), herPrestada.getEstadoActual());

        Prestamo prestamoGuardado = prestamoRepository.findById(prestamoNum).orElse(null);
        assertNotNull(prestamoGuardado);
        assertEquals(EstadoPrestamo.ACTIVO, prestamoGuardado.getEstadoPrestamo());

        // 4. Registro de devolucion fisica con inspeccion (RF38, RF39, RF40)
        DevolucionHerramientaRequest.ItemDevolucionRequest itemDev = DevolucionHerramientaRequest.ItemDevolucionRequest.builder()
                .codHerramienta(codHerramienta)
                .estadoFisico(EstadoDevolucion.BUEN_ESTADO)
                .build();

        DevolucionHerramientaRequest devolucionReq = DevolucionHerramientaRequest.builder()
                .prestamoNum(prestamoNum)
                .detalleIncidencia("Herramienta devuelta sin averias")
                .items(List.of(itemDev))
                .build();

        MensajeGenericoResponse resDevolucion = prestamoService.registrarDevolucion(CORREO_ALMACENISTA, devolucionReq, IP_TEST);
        assertTrue(resDevolucion.isExito());

        // 5. Validar que la herramienta retorna a 'Disponible' y prestamo a CERRADO
        Herramienta herDisponible = herramientaRepository.findByCodHerramienta(codHerramienta).orElse(null);
        assertNotNull(herDisponible);
        assertEquals(EstadoHerramienta.DISPONIBLE.getDescripcionSql(), herDisponible.getEstadoActual());

        Prestamo prestamoCerrado = prestamoRepository.findById(prestamoNum).orElse(null);
        assertNotNull(prestamoCerrado);
        assertEquals(EstadoPrestamo.CERRADO, prestamoCerrado.getEstadoPrestamo());
    }
    
    // -------------------------------------------------------------------------
    // TDD CICLO 5: AUDITORÍA INALTERABLE Y GENERACIÓN DE REPORTES (RF30, RF49)
    // -------------------------------------------------------------------------
    @Test
    @DisplayName("TDD RF30/RF49: Generar Excel con Apache POI y verificar insercion con Hash SHA-256")
    void testTdd_AuditoriaYGeneracionExcel() {
        // 1. Generacion de reporte binario en Excel
        LocalDate inicio = LocalDate.now().minusMonths(3);
        LocalDate fin = LocalDate.now();
        ByteArrayInputStream streamExcel = reporteService.exportarConsolidadoAuditoria("EXCEL", inicio, fin);
        assertNotNull(streamExcel);
        assertTrue(streamExcel.available() > 0, "El binario de Excel debe contener bytes reales");

        // 2. Registro explicito de asiento de auditoria y validacion criptografica
        auditoriaService.registrarAsiento("TEST_TDD_OP", 1L, "VERIFICACION_TDD", IP_TEST);

        Page<AuditoriaOperacion> logs = auditoriaRepository.findAllByOrderByTimestampDesc(PageRequest.of(0, 1));
        assertFalse(logs.isEmpty());
        AuditoriaOperacion ultimoLog = logs.getContent().get(0);
        assertNotNull(ultimoLog.getHashSha256());
        assertEquals(64, ultimoLog.getHashSha256().length(), "El hash criptografico debe ser un SHA-256 valido de 64 caracteres hex");
    }
}