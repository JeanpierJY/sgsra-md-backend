package com.masterdrilling.sgsramd;

import com.masterdrilling.sgsramd.DAO.*;
import com.masterdrilling.sgsramd.dto.request.*;
import com.masterdrilling.sgsramd.dto.response.*;
import com.masterdrilling.sgsramd.model.entity.*;
import com.masterdrilling.sgsramd.model.enums.*;
import com.masterdrilling.sgsramd.service.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Component;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.time.LocalDate;
import java.util.*;

/**
 * CONSOLA DE TESTEO MANUAL INTERACTIVO Y VALIDACION FUNCIONAL E2E
 * Cubre el ciclo integral de negocio de Master Drilling segun RF01 - RF50:
 * - RF01/RF02/RF03: Autenticacion, sesion y control por roles
 * - RF07/RF08: Gestion y edicion de personal operativo
 * - RF09/RF10/RF11/RF12: Catalogo maestro de repuestos pesados y predictivo
 * - RF13/RF14/RF15/RF16/RF17: Carrito y registro formal de requerimientos
 * - RF19/RF20: Historial y trazabilidad cromatica de estados de solicitudes
 * - RF21/RF22/RF23/RF24/RF25/RF28: Bandeja de jefatura, aprobacion y rechazo
 * - RF29/RF30: Demanda analitica y exportacion ofimatica en Excel
 * - RF32: Mantenimiento y alta de piezas homologadas en catalogo
 * - RF33/RF34/RF35: Dashboard de pañol, escaneo QR y ficha de herramienta
 * - RF36/RF37/RF38/RF39/RF40/RF41/RF42/RF43/RF45: Salidas, retornos y extravios
 * - RF49: Bitacora de auditoria inmutable append-only sellada con SHA-256
 */
@Component
public class ManualTestingRunner implements CommandLineRunner {

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
    private Prestamo_DAO prestamoRepository;

    @Autowired
    private Herramienta_DAO herramientaRepository;

    @Autowired
    private Mecanico_DAO mecanicoRepository;

    @Autowired
    private Usuario_DAO usuarioRepository;

    @Autowired
    private Repuesto_DAO repuestoRepository;

    @Autowired
    private AuditoriaOperacion_DAO auditoriaRepository;

    @Autowired
    private PrestamoDetalle_DAO prestamoDetalleRepository;

    private final Scanner scanner = new Scanner(System.in);
    private final String ipLocal = "127.0.0.1";

    // Cuentas operativas identificadas y validadas en PostgreSQL
    private final String CORREO_MECANICO = "carlos.baro@masterdrilling.com";
    private final String DNI_MECANICO = "70000001";
    private final String CORREO_ADMIN = "leao.chura@masterdrilling.com";
    private final String CORREO_ALMACENISTA = "marcos.baro@masterdrilling.com";

    // RF13: Carrito de compras temporal en memoria
    private final Map<String, Integer> carritoRepuestos = new LinkedHashMap<>();

    @Override
    public void run(String... args) {
        // Ejecucion en hilo separado para permitir que Tomcat inicialice el puerto 8080
        new Thread(() -> {
            try {
                Thread.sleep(2000);
                menuPrincipal();
            } catch (Exception e) {
                System.out.println("Consola finalizada: " + e.getMessage());
            }
        }).start();
    }

    // RF02, RF08: Navegacion controlada segun rol operativo
    private void menuPrincipal() {
        while (true) {
            System.out.println("\n=========================================================");
            System.out.println("  SGSRA-MD: CONSOLA INTEGRAL MASTER DRILLING (RF01-RF50) ");
            System.out.println("=========================================================");
            System.out.println("1. [PANEL MECANICO]      -> Catalogo, Carrito, Pedidos, Herramientas, Perfil");
            System.out.println("2. [PANEL ADMINISTRADOR] -> Bandeja, Metricas, Auditoria, Personal, Catalogo");
            System.out.println("3. [PANEL ALMACENISTA]   -> Solicitudes Aprobadas, Dashboard, Despacho, Retorno");
            System.out.println("4. Salir (RF03 - Cierre de Sesion)");
            System.out.print("Seleccione una opcion (1-4): ");

            String opc = scanner.nextLine().trim();
            switch (opc) {
                case "1" -> flujoPanelMecanico();
                case "2" -> flujoPanelAdministrador();
                case "3" -> flujoPanelAlmacenista();
                case "4" -> {
                    System.out.println("Cerrando sesion interactiva. El servidor Spring Boot sigue activo.");
                    return;
                }
                default -> System.out.println("Opcion no valida.");
            }
        }
    }

    // =========================================================================
    // 1. PANEL MECANICO (RF09 - RF20, RF07)
    // =========================================================================
    private void flujoPanelMecanico() {
        while (true) {
            System.out.println("\n---------------------------------------------------------");
            System.out.println("      MODULO MECANICO: " + CORREO_MECANICO + " (DNI: " + DNI_MECANICO + ")");
            System.out.println("---------------------------------------------------------");
            System.out.println("1. Catalogo de Repuestos (RF09, RF10, RF11, RF12, RF13)");
            System.out.println("2. Mis Pedidos (RF14, RF15, RF16, RF17, RF19, RF20)");
            System.out.println("3. Herramientas Prestadas (RF36, RF40, RF41, RF43)");
            System.out.println("4. Mi Perfil (RF07)");
            System.out.println("5. Regresar al Menu Principal");
            System.out.print("Seleccione (1-5): ");

            String op = scanner.nextLine().trim();
            switch (op) {
                case "1" -> subMenuCatalogoMecanico();
                case "2" -> subMenuPedidosMecanico();
                case "3" -> listarHerramientasPrestadasMecanico();
                case "4" -> subMenuPerfilMecanico();
                case "5" -> { return; }
                default -> System.out.println("Opcion no valida.");
            }
        }
    }

    private void subMenuCatalogoMecanico() {
        System.out.println("\n-- Catalogo de Piezas Pesadas --");
        System.out.println("1.1 Listar repuestos (RF09 - Paginado)");
        System.out.println("1.2 Buscar repuesto (RF10 - Predictivo)");
        System.out.println("1.3 Filtrar repuesto por tipo o marca (RF11)");
        System.out.println("1.4 Mostrar detalle tecnico de repuesto (RF12)");
        System.out.println("1.5 Anadir repuesto a Carrito (RF13)");
        System.out.print("Opcion: ");
        String sub = scanner.nextLine().trim();

        try {
            if ("1".equals(sub) || "1.1".equals(sub)) {
                // RF09: Visualizacion del catalogo maestro de repuestos pesados con paginacion
                Page<RepuestoResponse> cat = catalogoService.listarCatalogo(PageRequest.of(0, 10));
                System.out.println("Total repuestos en catalogo: " + cat.getTotalElements());
                for (RepuestoResponse r : cat.getContent()) {
                    System.out.printf(" -> [%s] %s | Stock: %d | Min: %d\n",
                            r.getCodParte(), r.getNombreRepuesto(), r.getStockActual(), r.getStockMinimo());
                }
            } else if ("2".equals(sub) || "1.2".equals(sub)) {
                // RF10: Buscador predictivo reactivo
                System.out.print("Termino a buscar (ej: Bomba, Filtro): ");
                String txt = scanner.nextLine().trim();
                List<RepuestoResponse> res = catalogoService.buscarPredictivo(txt);
                System.out.println("Coincidencias encontradas (" + res.size() + "):");
                for (RepuestoResponse r : res) {
                    System.out.printf(" -> [%s] %s | Stock: %d\n", r.getCodParte(), r.getNombreRepuesto(), r.getStockActual());
                }
            } else if ("3".equals(sub) || "1.3".equals(sub)) {
                // RF11: Filtrado selectivo por categoria/familia de componentes
                System.out.print("Filtro por tipo de componente (ej: Hidraulico, Filtro, Motor): ");
                String tipo = scanner.nextLine().trim();
                List<RepuestoResponse> res = catalogoService.buscarPredictivo(tipo);
                System.out.println("Repuestos filtrados (" + res.size() + "):");
                for (RepuestoResponse r : res) {
                    System.out.printf(" -> [%s] %s | Stock: %d\n", r.getCodParte(), r.getNombreRepuesto(), r.getStockActual());
                }
            } else if ("4".equals(sub) || "1.4".equals(sub)) {
                // RF12: Despliegue de ficha tecnica y especificaciones
                System.out.print("Codigo de Parte (ej: P-REX-024): ");
                String cod = scanner.nextLine().trim();
                RepuestoResponse r = catalogoService.obtenerPorCodigo(cod);
                System.out.println("FICHA TECNICA: " + r.getNombreRepuesto());
                System.out.println("Codigo:      " + r.getCodParte());
                System.out.println("Stock Actual:" + r.getStockActual());
                System.out.println("Stock Minimo:" + r.getStockMinimo());
                System.out.println("Descripcion: " + (r.getDescripcion() != null ? r.getDescripcion() : "Sin descripcion"));
            } else if ("5".equals(sub) || "1.5".equals(sub)) {
                // RF13: Carrito digital para agrupar multiples repuestos antes de formalizar la orden
                System.out.print("Codigo de Parte a agregar: ");
                String cod = scanner.nextLine().trim();
                RepuestoResponse r = catalogoService.obtenerPorCodigo(cod);
                System.out.print("Cantidad requerida (Stock actual " + r.getStockActual() + "): ");
                int cant = Integer.parseInt(scanner.nextLine().trim());
                if (cant <= 0) {
                    System.out.println("La cantidad debe ser mayor a 0.");
                    return;
                }
                carritoRepuestos.put(r.getCodParte(), carritoRepuestos.getOrDefault(r.getCodParte(), 0) + cant);
                System.out.println("Pieza anadida al carrito. Total componentes agrupados: " + carritoRepuestos.size());
            }
        } catch (Exception e) {
            System.out.println("Aviso: " + e.getMessage());
        }
    }

    private void subMenuPedidosMecanico() {
        System.out.println("\n-- Mis Pedidos --");
        System.out.println("2.1 Transmitir solicitud vinculada al carrito (RF14, RF15, RF16, RF17)");
        System.out.println("2.2 Historial y estado de solicitudes (RF19, RF20)");
        System.out.print("Opcion: ");
        String sub = scanner.nextLine().trim();

        try {
            if ("1".equals(sub) || "2.1".equals(sub)) {
                if (carritoRepuestos.isEmpty()) {
                    System.out.println("El carrito esta vacio. Primero agregue repuestos desde el catalogo.");
                    return;
                }

                // RF15: Vinculacion obligatoria de la orden al codigo de la maquinaria afectada
                System.out.print("Codigo de Maquinaria Afectada (Enter para MD-RB-01): ");
                String maq = scanner.nextLine().trim();
                if (maq.isEmpty()) maq = "MD-RB-01";

                // RF14: Seleccion de prioridad de requerimiento
                System.out.println("Seleccione Nivel de Urgencia (RF14):");
                System.out.println(" 1. BAJA");
                System.out.println(" 2. MEDIA");
                System.out.println(" 3. ALTA");
                System.out.print("Seleccion (1-3, defecto 3): ");
                String prioOpc = scanner.nextLine().trim();
                PrioridadSolicitud prioridad = switch (prioOpc) {
                    case "1" -> PrioridadSolicitud.BAJA;
                    case "2" -> PrioridadSolicitud.MEDIA;
                    default -> PrioridadSolicitud.ALTA;
                };

                // RF16: Campo de texto para justificar tecnicamente el cambio de pieza (>10 caracteres)
                System.out.print("Justificacion tecnica del cambio (RF16, >10 caracteres): ");
                String just = scanner.nextLine().trim();
                if (just.length() < 10) just = "Cambio correctivo urgente por parada de maquina en turno de operacion";

                List<SolicitudRepuestoRequest.ItemRepuestoRequest> items = new ArrayList<>();
                for (Map.Entry<String, Integer> entry : carritoRepuestos.entrySet()) {
                    items.add(new SolicitudRepuestoRequest.ItemRepuestoRequest(entry.getKey(), entry.getValue()));
                }

                SolicitudRepuestoRequest req = SolicitudRepuestoRequest.builder()
                        .codMaquinaria(maq)
                        .prioridad(prioridad)
                        .justificacionTecnica(just)
                        .items(items)
                        .build();

                // RF17: Envio instantaneo del requerimiento a administracion con estado PENDIENTE
                MensajeGenericoResponse res = solicitudService.registrarSolicitud(CORREO_MECANICO, req, ipLocal);
                System.out.println("EXITO (RF17): " + res.getMensaje() + " | Numero Solicitud: " + res.getDato());
                carritoRepuestos.clear();
            } else if ("2".equals(sub) || "2.2".equals(sub)) {
                // RF19/RF20: Historial personal cronologico con indicador de estado (Pendiente, Aprobada, Rechazada)
                Page<SolicitudResumenResponse> hist = solicitudService.listarHistorialMecanico(CORREO_MECANICO, PageRequest.of(0, 10));
                System.out.println("Historial de Solicitudes (" + hist.getTotalElements() + " registros):");
                for (SolicitudResumenResponse s : hist.getContent()) {
                    System.out.printf(" -> Num: %s | Maquina: %s | Prioridad: %s | Estado: [%s] | Fecha: %s\n",
                            s.getSolicitudNum(), s.getCodMaquinaria(), s.getPrioridad(), s.getEstado(), s.getFechaEmision());
                }
            }
        } catch (Exception e) {
            System.out.println("Aviso: " + e.getMessage());
        }
    }

    // RF36, RF40, RF41, RF42, RF43: Historial y estado integral de herramientas prestadas al mecanico
    private void listarHerramientasPrestadasMecanico() {
        System.out.println("\n-- Historial Integral de Herramientas Prestadas al Mecanico (RF36, RF40, RF41, RF43) --");
        try {
            // Consulta de prestamos asociados directamente al DNI sin restriccion de estado
            List<Prestamo> prestamos = prestamoRepository.findAll().stream()
                    .filter(p -> p.getMecanico() != null && DNI_MECANICO.equals(p.getMecanico().getDniMecanico()))
                    .toList();

            if (prestamos.isEmpty()) {
                System.out.println("Usted no registra movimientos ni prestamos de herramientas en el historico.");
                return;
            }

            for (Prestamo p : prestamos) {
                System.out.printf(" -> Prestamo: %s | Estado Prestamo: [%s] | Fecha Salida: %s %s\n",
                        p.getPrestamoNum(), p.getEstadoPrestamo(), p.getFechaPrestamo(), p.getHoraSalida());

                // Resolucion explicita de detalles mediante DAO para evitar errores de sesion Lazy
                List<PrestamoDetalle> detalles = prestamoDetalleRepository.findByIdPrestamoNum(p.getPrestamoNum());
                for (PrestamoDetalle d : detalles) {
                    String estadoFisicoActual = herramientaRepository.findByCodHerramienta(d.getHerramienta().getCodHerramienta())
                            .map(Herramienta::getEstadoActual)
                            .orElse(d.getEstadoHerramienta());

                    System.out.printf("     * [%s] %s | Estado Entrega: %s | Estado Actual en Taller: [%s]\n",
                            d.getHerramienta().getCodHerramienta(), 
                            d.getNombreHerramienta(), 
                            d.getEstadoHerramienta(), 
                            estadoFisicoActual);
                }
            }
        } catch (Exception e) {
            System.out.println("Aviso al consultar herramientas: " + e.getMessage());
        }
    }

    // RF07: Consulta y edicion de perfil basico del operario
    private void subMenuPerfilMecanico() {
        System.out.println("\n-- Mi Perfil (RF07) --");
        System.out.println("4.1 Mostrar informacion");
        System.out.println("4.2 Editar informacion de contacto");
        System.out.print("Opcion: ");
        String sub = scanner.nextLine().trim();

        try {
            if ("1".equals(sub) || "4.1".equals(sub)) {
                Optional<Mecanico> optM = mecanicoRepository.findByDniMecanico(DNI_MECANICO);
                if (optM.isPresent()) {
                    Mecanico m = optM.get();
                    System.out.println("DNI:          " + m.getDniMecanico());
                    System.out.println("Nombre:       " + m.getNombreMecanico());
                    System.out.println("Especialidad: " + m.getEspecialidadMecanico());
                    System.out.println("Cargo:        " + m.getCargoMecanico());
                    System.out.println("Telefono:     " + (m.getTelefono() != null ? m.getTelefono() : "No registrado"));
                    System.out.println("Correo:       " + CORREO_MECANICO);
                }
            } else if ("2".equals(sub) || "4.2".equals(sub)) {
                System.out.print("Nuevo Nombre Completo: ");
                String nom = scanner.nextLine().trim();
                System.out.print("Nuevo Telefono (9 digitos): ");
                String tel = scanner.nextLine().trim();

                ActualizarPerfilRequest req = ActualizarPerfilRequest.builder()
                        .nombre(nom)
                        .telefono(tel)
                        .build();

                MensajeGenericoResponse res = authService.actualizarPerfil(CORREO_MECANICO, req);
                System.out.println("RESULTADO (RF07): " + res.getMensaje());
            }
        } catch (Exception e) {
            System.out.println("Aviso: " + e.getMessage());
        }
    }

    // =========================================================================
    // 2. PANEL ADMINISTRADOR (RF21 - RF32, RF07, RF49)
    // =========================================================================
    private void flujoPanelAdministrador() {
        while (true) {
            System.out.println("\n---------------------------------------------------------");
            System.out.println("      MODULO ADMINISTRADOR (JEFE DE TALLER): " + CORREO_ADMIN);
            System.out.println("---------------------------------------------------------");
            System.out.println("1. Bandeja de Solicitudes (RF21, RF22, RF23, RF24, RF25, RF28, RF31)");
            System.out.println("2. Metricas y Reportes (RF29, RF30)");
            System.out.println("3. Auditoria Inalterable (RF49)");
            System.out.println("4. Gestionar Personal (RF07, RF08)");
            System.out.println("5. Gestionar Catalogo de Repuestos (RF32)");
            System.out.println("6. Regresar al Menu Principal");
            System.out.print("Seleccione (1-6): ");

            String op = scanner.nextLine().trim();
            switch (op) {
                case "1" -> subMenuBandejaAdmin();
                case "2" -> subMenuMetricasAdmin();
                case "3" -> subMenuAuditoriaAdmin();
                case "4" -> subMenuPersonalAdmin();
                case "5" -> subMenuGestionCatalogoAdmin();
                case "6" -> { return; }
                default -> System.out.println("Opcion no valida.");
            }
        }
    }

    private void subMenuBandejaAdmin() {
        System.out.println("\n-- Bandeja de Solicitudes --");
        System.out.println("1.1 Listar solicitudes (Evaluar o Consultar)");
        System.out.println("1.2 Listar solicitudes con filtro por estado / fecha (RF31)");
        System.out.print("Opcion: ");
        String sub = scanner.nextLine().trim();

        try {
            if ("1".equals(sub) || "1.1".equals(sub)) {
                // RF21: Bandeja unificada de solicitudes entrantes
                List<SolicitudResumenResponse> pend = solicitudService.listarBandejaAdministrador(EstadoSolicitud.PENDIENTE);
                System.out.println("Solicitudes Pendientes (" + pend.size() + "):");
                for (SolicitudResumenResponse s : pend) {
                    System.out.printf(" -> Num: %s | Mecanico: %s | Maquina: %s | Prioridad: %s\n",
                            s.getSolicitudNum(), s.getNombreMecanico(), s.getCodMaquinaria(), s.getPrioridad());
                }

                System.out.println("\nAcciones disponibles:");
                System.out.println(" 1. Aprobar solicitud integramente (RF23)");
                System.out.println(" 2. Desaprobar / Rechazar solicitud (RF24, RF25)");
                System.out.println(" 3. Mostrar detalle de la solicitud (RF22)");
                System.out.println(" 4. Volver");
                System.out.print("Seleccion (1-4): ");
                String acc = scanner.nextLine().trim();

                if ("1".equals(acc)) {
                    // RF23: Aprobacion total con despacho de notificacion push
                    System.out.print("Numero de solicitud a aprobar: ");
                    String num = scanner.nextLine().trim();
                    MensajeGenericoResponse res = solicitudService.aprobarSolicitudTotal(num, CORREO_ADMIN, ipLocal);
                    System.out.println("RESULTADO (RF23): " + res.getMensaje());
                } else if ("2".equals(acc)) {
                    // RF24, RF25: Rechazo obligatorio con justificacion tecnica minima de 15 caracteres
                    System.out.print("Numero de solicitud a desaprobar: ");
                    String num = scanner.nextLine().trim();
                    System.out.print("Justificacion obligatoria de rechazo (RF25, minimo 15 caracteres): ");
                    String just = scanner.nextLine().trim();
                    if (just.length() < 15) just = "Stock en panol cubre la necesidad inmediata del taller mina";

                    DictamenRechazoRequest req = DictamenRechazoRequest.builder()
                            .justificacionRechazo(just)
                            .build();
                    MensajeGenericoResponse res = solicitudService.rechazarSolicitudTotal(num, CORREO_ADMIN, req, ipLocal);
                    System.out.println("RESULTADO (RF24): " + res.getMensaje());
                } else if ("3".equals(acc)) {
                    // RF22: Vista detallada de componentes solicitados por el mecanico
                    System.out.print("Numero de solicitud a consultar: ");
                    String num = scanner.nextLine().trim();
                    DetalleSolicitudResponse d = solicitudService.obtenerDetalleSolicitud(num);
                    System.out.println("EXPEDIENTE: " + d.getSolicitudNum() + " | Estado: " + d.getEstado());
                    System.out.println("Mecanico:   " + d.getNombreMecanico() + " (DNI: " + d.getDniMecanico() + ")");
                    System.out.println("Maquinaria: " + d.getCodMaquinaria() + " (" + d.getModeloMaquinaria() + ")");
                    System.out.println("Causa:      " + d.getJustificacionTecnica());
                    System.out.println("Piezas Solicitadas:");
                    for (DetalleSolicitudResponse.ItemDetalleResponse item : d.getRepuestos()) {
                        System.out.printf("   * [%s] %s | Cantidad: %d | Estado: %s\n",
                                item.getCodParte(), item.getNombreRepuesto(), item.getCantidadSolicitada(), item.getEstadoItem());
                    }
                    if (d.getRechazo() != null) {
                        System.out.println("DICTAMEN RECHAZO: " + d.getRechazo().getJustificacionRechazo());
                    }
                }
            } else if ("2".equals(sub) || "1.2".equals(sub)) {
                // RF31: Filtros de auditoria y busqueda multicriterio
                System.out.println("Filtrar por Estado: 1. PENDIENTE | 2. APROBADA | 3. RECHAZADA | 4. ORDEN_CONTACTADA | 5. TODAS");
                String estOpc = scanner.nextLine().trim();
                EstadoSolicitud estado = switch (estOpc) {
                    case "1" -> EstadoSolicitud.PENDIENTE;
                    case "2" -> EstadoSolicitud.APROBADA;
                    case "3" -> EstadoSolicitud.RECHAZADA;
                    case "4" -> EstadoSolicitud.ORDEN_CONTACTADA;
                    default -> null;
                };

                List<SolicitudResumenResponse> filtradas = solicitudService.listarBandejaAdministrador(estado);
                System.out.println("Solicitudes encontradas (" + filtradas.size() + "):");
                for (SolicitudResumenResponse s : filtradas) {
                    System.out.printf(" -> Num: %s | %s | Maquina: %s | Estado: [%s] | Fecha: %s\n",
                            s.getSolicitudNum(), s.getNombreMecanico(), s.getCodMaquinaria(), s.getEstado(), s.getFechaEmision());
                }
            }
        } catch (Exception e) {
            System.out.println("Aviso: " + e.getMessage());
        }
    }

    private void subMenuMetricasAdmin() {
        System.out.println("\n-- Metricas y Reportes Oficiales --");
        System.out.println("2.1 Mostrar metricas de repuestos solicitados (RF29)");
        System.out.println("2.2 Descargar metrica / reporte consolidado en PDF");
        System.out.println("2.3 Descargar metrica / reporte consolidado en Excel (RF30)");
        System.out.print("Opcion: ");
        String sub = scanner.nextLine().trim();

        try {
            LocalDate inicio = LocalDate.now().minusMonths(6);
            LocalDate fin = LocalDate.now();

            if ("1".equals(sub) || "2.1".equals(sub)) {
                // RF29: Graficos estadisticos y metricas de piezas mas demandadas
                List<EstadisticaDemandaResponse> metricas = reporteService.obtenerTopRepuestosDemandados(inicio, fin);
                System.out.println("Top Repuestos mas demandados en los ultimos 180 dias:");
                for (EstadisticaDemandaResponse m : metricas) {
                    System.out.printf(" -> [%s] %s | Total Solicitado: %d unidades\n",
                            m.getCodParte(), m.getNombreRepuesto(), m.getCantidadTotalSolicitada());
                }
            } else if ("2".equals(sub) || "2.2".equals(sub)) {
                // RF30: Exportacion ofimatica limpia
                System.out.println("Generando exportacion tabular estructurada (CSV / PDF)...");
                descargarArchivoConsolidadoFisico("CSV", "Reporte_Metricas_SGSRA_MD.csv");
            } else if ("3".equals(sub) || "2.3".equals(sub)) {
                // RF30: Descarga fisica directa en formato Excel (.xlsx) a la carpeta sgsra-md-backend
                descargarArchivoConsolidadoFisico("EXCEL", "Reporte_Consolidado_SGSRA_MD.xlsx");
            }
        } catch (Exception e) {
            System.out.println("Aviso: " + e.getMessage());
        }
    }

    // RF30: Escritura fisica del binario en la carpeta sgsra-md-backend
    private void descargarArchivoConsolidadoFisico(String formato, String nombreArchivo) {
        try {
            LocalDate inicio = LocalDate.now().minusMonths(6);
            LocalDate fin = LocalDate.now();
            ByteArrayInputStream in = reporteService.exportarConsolidadoAuditoria(formato, inicio, fin);

            File dirRaiz = new File("..").getCanonicalFile();
            if (!dirRaiz.getName().contains("sgsra-md-backend")) {
                dirRaiz = new File(".").getCanonicalFile();
            }
            File archivoDestino = new File(dirRaiz, nombreArchivo);

            try (FileOutputStream out = new FileOutputStream(archivoDestino)) {
                byte[] buffer = new byte[1024];
                int len;
                while ((len = in.read(buffer)) != -1) {
                    out.write(buffer, 0, len);
                }
            }
            System.out.println("ARCHIVO GENERADO CON EXITO (RF30):");
            System.out.println("Ruta fisica: " + archivoDestino.getAbsolutePath());
            System.out.println("Tamano:      " + archivoDestino.length() + " bytes");
        } catch (Exception e) {
            System.out.println("Error al descargar archivo: " + e.getMessage());
        }
    }

    // RF49: Bitacora inalterable append-only sellada con Hash SHA-256
    private void subMenuAuditoriaAdmin() {
        System.out.println("\n-- Bitacora Inalterable de Auditoria (RF49) --");
        System.out.println("3.1 Mostrar lista de logs (Criptografia SHA-256)");
        try {
            Page<AuditoriaOperacion> logs = auditoriaRepository.findAllByOrderByTimestampDesc(PageRequest.of(0, 10));
            System.out.println("Total de eventos auditados: " + logs.getTotalElements());
            for (AuditoriaOperacion a : logs.getContent()) {
                System.out.printf(" -> [%s] %s | Op: %s | User: %s | Hash: %s\n",
                        a.getTimestamp(), a.getAccion(), a.getIdOperacion(), a.getIdUsuario(),
                        a.getHashSha256().substring(0, 20) + "...");
            }
        } catch (Exception e) {
            System.out.println("Aviso: " + e.getMessage());
        }
    }

    // RF07, RF08: Gestion y fiscalizacion de personal operativo por DNI
    private void subMenuPersonalAdmin() {
        System.out.println("\n-- Gestionar Personal (RF07, RF08) --");
        System.out.println("4.1 Listar personal registrado");
        System.out.println("4.2 Crear usuario y asignar contrasena desde el panel");
        System.out.println("4.3 Editar usuario por DNI (Sin permiso para editar contrasena)");
        System.out.println("4.4 Habilitar / Deshabilitar usuario por DNI (Seleccion 1 / 2)");
        System.out.print("Opcion: ");
        String sub = scanner.nextLine().trim();

        try {
            if ("1".equals(sub) || "4.1".equals(sub)) {
                Page<UsuarioResumenResponse> users = authService.listarUsuarios(null, PageRequest.of(0, 15));
                System.out.println("Personal en BD (" + users.getTotalElements() + "):");
                for (UsuarioResumenResponse u : users.getContent()) {
                    System.out.printf(" -> DNI: %s | %s | %s | Rol: %s | Estado: %s\n",
                            u.getDni(), u.getNombre(), u.getCorreoCorporativo(), u.getRol(), u.getEstadoCuenta());
                }
            } else if ("2".equals(sub) || "4.2".equals(sub)) {
                System.out.print("DNI (8 digitos exactos): ");
                String dni = scanner.nextLine().trim();
                System.out.print("Nombre Completo: ");
                String nom = scanner.nextLine().trim();
                System.out.print("Correo Corporativo (@masterdrilling.com): ");
                String cor = scanner.nextLine().trim();
                System.out.print("Contrasena a asignar: ");
                String pass = scanner.nextLine().trim();

                System.out.println("Seleccione Rol (1. MECANICO, 2. ALMACENISTA, 3. ADMINISTRADOR): ");
                String rolOpc = scanner.nextLine().trim();
                RolUsuario rol = switch (rolOpc) {
                    case "2" -> RolUsuario.ALMACENISTA;
                    case "3" -> RolUsuario.ADMINISTRADOR;
                    default -> RolUsuario.MECANICO;
                };

                CrearUsuarioRequest req = CrearUsuarioRequest.builder()
                        .dni(dni)
                        .nombre(nom)
                        .correoCorporativo(cor)
                        .contrasena(pass)
                        .rol(rol)
                        .especialidad("Mantenimiento Mina")
                        .cargo("Tecnico Operativo")
                        .sedeAsignada("Sede Lurin")
                        .build();

                MensajeGenericoResponse res = authService.registrarUsuario(req, ipLocal);
                System.out.println("RESULTADO: " + res.getMensaje());
            } else if ("3".equals(sub) || "4.3".equals(sub)) {
                System.out.print("DNI del usuario a editar: ");
                String dni = scanner.nextLine().trim();
                Usuario user = usuarioRepository.findByDni(dni)
                        .orElseThrow(() -> new RuntimeException("Usuario no encontrado con DNI: " + dni));

                System.out.println("Editando a: " + user.getNombre() + " (" + user.getCorreoCorporativo() + ")");
                System.out.print("Nuevo Nombre Completo (Enter para mantener): ");
                String nom = scanner.nextLine().trim();
                if (!nom.isEmpty()) user.setNombre(nom);

                System.out.print("Nuevo Telefono (Enter para omitir): ");
                String tel = scanner.nextLine().trim();

                usuarioRepository.save(user);

                mecanicoRepository.findByDniMecanico(dni).ifPresent(m -> {
                    if (!nom.isEmpty()) m.setNombreMecanico(nom);
                    if (!tel.isEmpty()) m.setTelefono(tel);
                    mecanicoRepository.save(m);
                });

                System.out.println("Usuario actualizado exitosamente por DNI.");
            } else if ("4".equals(sub) || "4.4".equals(sub)) {
                System.out.print("DNI del usuario a modificar: ");
                String dni = scanner.nextLine().trim();
                Usuario user = usuarioRepository.findByDni(dni)
                        .orElseThrow(() -> new RuntimeException("Usuario no encontrado con DNI: " + dni));

                System.out.println("Usuario: " + user.getNombre() + " | Estado actual: " + user.getEstadoCuenta());
                System.out.println("Seleccion: 1. Habilitar (ACTIVO) | 2. Deshabilitar (INACTIVO)");
                String estOpc = scanner.nextLine().trim();
                EstadoCuenta nuevoEstado = "2".equals(estOpc) ? EstadoCuenta.INACTIVO : EstadoCuenta.ACTIVO;

                MensajeGenericoResponse res = authService.cambiarEstadoCuenta(user.getIdUsuario(), nuevoEstado, ipLocal);
                System.out.println("RESULTADO: " + res.getMensaje());
            }
        } catch (Exception e) {
            System.out.println("Aviso: " + e.getMessage());
        }
    }

    // RF32: Alta y modificacion de componentes homologados en catalogo
    private void subMenuGestionCatalogoAdmin() {
        System.out.println("\n-- Gestionar Catalogo de Repuestos (RF32) --");
        System.out.println("5.1 Listar catalogo");
        System.out.println("5.2 Crear repuesto (con informacion de proveedores homologados - RF27)");
        System.out.println("5.3 Editar repuesto (Nombre, stock, descripcion)");
        System.out.println("5.4 Habilitar / Deshabilitar Repuesto (Baja tecnica)");
        System.out.print("Opcion: ");
        String sub = scanner.nextLine().trim();

        try {
            if ("1".equals(sub) || "5.1".equals(sub)) {
                Page<RepuestoResponse> cat = catalogoService.listarCatalogo(PageRequest.of(0, 15));
                for (RepuestoResponse r : cat.getContent()) {
                    System.out.printf(" -> [%s] %s | Stock: %d | Min: %d | Activo: %s\n",
                            r.getCodParte(), r.getNombreRepuesto(), r.getStockActual(), r.getStockMinimo(), r.getActivo());
                }
            } else if ("2".equals(sub) || "5.2".equals(sub)) {
                // RF27: Visualizacion de enlaces y datos de contacto con proveedores homologados
                System.out.println("\nPROVEEDORES HOMOLOGADOS DISPONIBLES (RF27):");
                System.out.println(" 1. Bosch Rexroth Peru S.A.  | Contacto: +51 984 123 456 (ventas@rexroth.pe)");
                System.out.println(" 2. Enerpac Industrial S.A.  | Contacto: +51 998 765 432 (soporte@enerpac.pe)");
                System.out.println(" 3. Parker Hannifin Corp.    | Contacto: +51 971 334 556 (atencion@parker.com)");
                System.out.println(" 4. Donaldson Filtration Ltd | Contacto: +51 955 889 001 (filtros@donaldson.com)");
                System.out.println(" 5. Festo Neumatica Peru     | Contacto: +51 944 556 778 (pedidos@festo.pe)");

                System.out.print("Codigo de Parte (ej: VALV-RET-099): ");
                String cod = scanner.nextLine().trim();
                System.out.print("Nombre del Repuesto: ");
                String nom = scanner.nextLine().trim();
                System.out.print("Stock Actual inicial: ");
                int stock = Integer.parseInt(scanner.nextLine().trim());
                System.out.print("Stock Minimo de seguridad: ");
                int stockMin = Integer.parseInt(scanner.nextLine().trim());
                System.out.print("Descripcion tecnica: ");
                String desc = scanner.nextLine().trim();

                CrearRepuestoRequest req = CrearRepuestoRequest.builder()
                        .codParte(cod)
                        .nombreRepuesto(nom)
                        .stockActual(stock)
                        .stockMinimo(stockMin)
                        .descripcion(desc)
                        .build();

                RepuestoResponse res = catalogoService.registrarRepuesto(req);
                System.out.println("Repuesto creado exitosamente en BD (RF32): " + res.getCodParte());
            } else if ("3".equals(sub) || "5.3".equals(sub)) {
                System.out.print("Codigo de Parte del repuesto a editar: ");
                String cod = scanner.nextLine().trim();
                Repuesto rep = repuestoRepository.findById(cod)
                        .orElseThrow(() -> new RuntimeException("Repuesto no encontrado con codigo: " + cod));

                System.out.println("Repuesto: " + rep.getNombreRepuesto() + " | Stock actual: " + rep.getStockActual());
                System.out.print("Nuevo Nombre (Enter para mantener): ");
                String nom = scanner.nextLine().trim();
                if (!nom.isEmpty()) rep.setNombreRepuesto(nom);

                System.out.print("Nuevo Stock Actual (Enter para mantener): ");
                String stStr = scanner.nextLine().trim();
                if (!stStr.isEmpty()) rep.setStockActual(Integer.parseInt(stStr));

                System.out.print("Nuevo Stock Minimo (Enter para mantener): ");
                String smStr = scanner.nextLine().trim();
                if (!smStr.isEmpty()) rep.setStockMinimo(Integer.parseInt(smStr));

                System.out.print("Nueva Descripcion (Enter para mantener): ");
                String desc = scanner.nextLine().trim();
                if (!desc.isEmpty()) rep.setDescripcion(desc);

                repuestoRepository.save(rep);
                System.out.println("Repuesto actualizado exitosamente.");
            } else if ("4".equals(sub) || "5.4".equals(sub)) {
                System.out.print("Codigo de Parte: ");
                String cod = scanner.nextLine().trim();
                Repuesto rep = repuestoRepository.findById(cod)
                        .orElseThrow(() -> new RuntimeException("Repuesto no encontrado"));

                System.out.println("Estado actual de " + rep.getCodParte() + ": " + (rep.getActivo() ? "HABILITADO" : "DESHABILITADO"));
                System.out.println("Seleccion: 1. Habilitar | 2. Deshabilitar (Baja)");
                String st = scanner.nextLine().trim();
                rep.setActivo("1".equals(st));
                repuestoRepository.save(rep);
                System.out.println("Estado de repuesto actualizado exitosamente.");
            }
        } catch (Exception e) {
            System.out.println("Aviso: " + e.getMessage());
        }
    }

    // =========================================================================
    // 3. PANEL ALMACENISTA (RF33 - RF45)
    // =========================================================================
    private void flujoPanelAlmacenista() {
        while (true) {
            System.out.println("\n---------------------------------------------------------");
            System.out.println("   MODULO ALMACENISTA (PANOL): " + CORREO_ALMACENISTA);
            System.out.println("---------------------------------------------------------");
            System.out.println("1. Bandeja de Solicitudes APROBADAS (Entrega de Repuestos)");
            System.out.println("2. Control y Listado de Prestamos Activos (RF36, RF43)");
            System.out.println("3. Dashboard de Stock de Herramientas (RF33)");
            System.out.println("4. Catalogo de Herramientas del Panol (RF34, RF35, RF45)");
            System.out.println("5. Despacho / Prestamo de Herramienta por DNI (RF36, RF37)");
            System.out.println("6. Recepcion y Devolucion Fisica de Herramienta (RF38, RF39, RF40)");
            System.out.println("7. Reportar Herramienta como Extraviada (RF41, RF42)");
            System.out.println("8. Regresar al Menu Principal");
            System.out.print("Seleccione (1-8): ");

            String op = scanner.nextLine().trim();
            switch (op) {
                case "1" -> listarSolicitudesAprobadasParaAlmacen();
                case "2" -> listarTodosLosPrestamosHerramientas();
                case "3" -> mostrarDashboardHerramientas();
                case "4" -> subMenuCatalogoHerramientas();
                case "5" -> registrarPrestamoHerramienta();
                case "6" -> registrarDevolucionHerramienta();
                case "7" -> reportarExtravioHerramienta();
                case "8" -> { return; }
                default -> System.out.println("Opcion no valida.");
            }
        }
    }

    // Requerimientos Aprobados para retiro fisico de piezas de repuesto
    private void listarSolicitudesAprobadasParaAlmacen() {
        System.out.println("\n-- Requerimientos de Repuestos Aprobados para Despacho --");
        try {
            List<SolicitudResumenResponse> aprobadas = solicitudService.listarBandejaAdministrador(EstadoSolicitud.APROBADA);
            if (aprobadas.isEmpty()) {
                System.out.println("No hay solicitudes aprobadas pendientes de entrega.");
                return;
            }
            System.out.println("Solicitudes Autorizadas (" + aprobadas.size() + "):");
            for (SolicitudResumenResponse s : aprobadas) {
                System.out.printf(" -> Num: %s | Mecanico: %s | Maquina: %s | Prioridad: %s\n",
                        s.getSolicitudNum(), s.getNombreMecanico(), s.getCodMaquinaria(), s.getPrioridad());
            }
            System.out.print("Ingrese Num de solicitud para ver piezas a entregar (o Enter para volver): ");
            String num = scanner.nextLine().trim();
            if (!num.isEmpty()) {
                DetalleSolicitudResponse d = solicitudService.obtenerDetalleSolicitud(num);
                System.out.println("DESPACHO AUTORIZADO PARA MECANICO: " + d.getNombreMecanico());
                for (DetalleSolicitudResponse.ItemDetalleResponse it : d.getRepuestos()) {
                    System.out.printf("   * Cantidad: %d | Codigo: %s | %s\n",
                            it.getCantidadSolicitada(), it.getCodParte(), it.getNombreRepuesto());
                }
            }
        } catch (Exception e) {
            System.out.println("Aviso: " + e.getMessage());
        }
    }

    // RF36, RF43: Control y listado integral de prestamos de herramientas con formato unificado
    private void listarTodosLosPrestamosHerramientas() {
        System.out.println("\n-- Registro y Control de Prestamos de Herramientas --");
        try {
            List<Prestamo> prestamos = prestamoRepository.findAll();
            if (prestamos.isEmpty()) {
                System.out.println("No existen registros de prestamos en el historico.");
                return;
            }

            System.out.println("Prestamos Registrados (" + prestamos.size() + "):");
            for (Prestamo p : prestamos) {
                String dniMec = (p.getMecanico() != null) ? p.getMecanico().getDniMecanico() : "DESCONOCIDO";
                String nombreMec = mecanicoRepository.findByDniMecanico(dniMec)
                        .map(Mecanico::getNombreMecanico)
                        .orElse("Mecanico no registrado");

                List<PrestamoDetalle> detalles = prestamoDetalleRepository.findByIdPrestamoNum(p.getPrestamoNum());
                StringBuilder herramientasStr = new StringBuilder();
                for (int i = 0; i < detalles.size(); i++) {
                    PrestamoDetalle d = detalles.get(i);
                    herramientasStr.append(d.getHerramienta().getCodHerramienta())
                            .append(" (").append(d.getNombreHerramienta()).append(")");
                    if (i < detalles.size() - 1) {
                        herramientasStr.append(", ");
                    }
                }

                System.out.printf(" -> [%s] %s (DNI: %s) | Herramientas: %s | Estado: [%s] | Fecha: %s\n",
                        p.getPrestamoNum(),
                        nombreMec,
                        dniMec,
                        herramientasStr.isEmpty() ? "Sin items" : herramientasStr.toString(),
                        p.getEstadoPrestamo(),
                        p.getFechaPrestamo());
            }
        } catch (Exception e) {
            System.out.println("Aviso al consultar prestamos: " + e.getMessage());
        }
    }

    // RF33: Tablero y contadores de stock actual de herramientas de taller
    private void mostrarDashboardHerramientas() {
        System.out.println("\n-- Dashboard de Stock de Herramientas en Panol (RF33) --");
        try {
            DashboardStockResponse dash = inventarioService.obtenerMetricasDashboard();
            System.out.println("Disponibles en Estante:  " + dash.getTotalDisponibles());
            System.out.println("Prestadas a Mecanicos:   " + dash.getTotalPrestadas());
            System.out.println("En Retraso / Mora:       " + dash.getTotalEnMora());
            System.out.println("En Taller Mantenimiento: " + dash.getTotalEnMantenimiento());
            System.out.println("Extraviadas:             " + dash.getTotalExtraviadas());
        } catch (Exception e) {
            System.out.println("Aviso: " + e.getMessage());
        }
    }

    private void subMenuCatalogoHerramientas() {
        System.out.println("\n-- Catalogo de Herramientas del Panol (RF45) --");
        System.out.println("1. Listar todas las herramientas");
        System.out.println("2. Consultar herramienta por codigo (Simulacion Escaneo QR - RF34, RF35)");
        System.out.println("3. Filtrar herramientas por Categoria (Manuales, Hidraulicas, Neumaticas, Electricas)");
        System.out.print("Opcion: ");
        String sub = scanner.nextLine().trim();

        try {
            if ("1".equals(sub)) {
                List<FichaHerramientaResponse> lista = inventarioService.listarHerramientasPorCategoria(null);
                System.out.println("Herramientas Registradas (" + lista.size() + "):");
                for (FichaHerramientaResponse h : lista) {
                    System.out.printf(" -> [%s] %s | Marca: %s | Categoria: %s | Estado: [%s]\n",
                            h.getCodHerramienta(), h.getNombreHerramienta(), h.getMarcaHerramienta(), h.getCategoria(), h.getEstadoActual());
                }
            } else if ("2".equals(sub)) {
                // RF34, RF35: Reconocimiento y muestra de ficha tras lectura QR
                System.out.print("Ingrese Codigo QR de la herramienta (ej: HER-TOR-004): ");
                String cod = scanner.nextLine().trim();
                FichaHerramientaResponse h = inventarioService.consultarHerramientaPorCodigo(cod);
                System.out.println("FICHA DE ACTIVO (RF35):");
                System.out.println("Codigo:    " + h.getCodHerramienta());
                System.out.println("Nombre:    " + h.getNombreHerramienta());
                System.out.println("Marca:     " + h.getMarcaHerramienta());
                System.out.println("Categoria: " + h.getCategoria());
                System.out.println("Estado:    " + h.getEstadoActual());
            } else if ("3".equals(sub)) {
                // RF45: Filtros de inventario por familias tecnicas
                System.out.println("Seleccione Categoria (1. Manuales, 2. Hidraulicas, 3. Neumaticas, 4. Electricas): ");
                String catOpc = scanner.nextLine().trim();
                CategoriaHerramienta cat = switch (catOpc) {
                    case "2" -> CategoriaHerramienta.HIDRAULICAS;
                    case "3" -> CategoriaHerramienta.NEUMATICAS;
                    case "4" -> CategoriaHerramienta.ELECTRICAS;
                    default -> CategoriaHerramienta.MANUALES;
                };

                List<FichaHerramientaResponse> lista = inventarioService.listarHerramientasPorCategoria(cat);
                System.out.println("Herramientas en Categoria " + cat.name() + " (" + lista.size() + "):");
                for (FichaHerramientaResponse h : lista) {
                    System.out.printf(" -> [%s] %s | Estado: [%s]\n", h.getCodHerramienta(), h.getNombreHerramienta(), h.getEstadoActual());
                }
            }
        } catch (Exception e) {
            System.out.println("Aviso: " + e.getMessage());
        }
    }

    // RF36, RF37: Registro de prestamo asignando mecanico y cambio automatico a 'Prestada'
    private void registrarPrestamoHerramienta() {
        System.out.println("\n-- Despacho Formal de Herramienta a Mecanico (RF36) --");
        try {
            System.out.print("DNI del Mecanico receptor (Enter para " + DNI_MECANICO + "): ");
            String dni = scanner.nextLine().trim();
            if (dni.isEmpty()) dni = DNI_MECANICO;

            System.out.print("Codigo de Herramienta a despachar (Enter para HER-TOR-004): ");
            String cod = scanner.nextLine().trim();
            if (cod.isEmpty()) cod = "HER-TOR-004";

            RegistrarPrestamoRequest req = RegistrarPrestamoRequest.builder()
                    .dniMecanico(dni)
                    .codigosHerramienta(List.of(cod))
                    .firmaMecanico("FIRMA_DIGITAL_RECEPCION_OK")
                    .build();

            MensajeGenericoResponse res = prestamoService.registrarPrestamo(CORREO_ALMACENISTA, req, ipLocal);
            System.out.println("EXITO (RF37): " + res.getMensaje() + " | Codigo Prestamo: " + res.getDato());
        } catch (Exception e) {
            System.out.println("Aviso: " + e.getMessage());
        }
    }

    // RF38, RF39, RF40: Retorno fisico, calificacion tecnica y transicion a 'Disponible' o 'En Mantenimiento'
    private void registrarDevolucionHerramienta() {
        System.out.println("\n-- Recepcion e Inspeccion Fisica de Herramienta (RF38, RF39) --");
        try {
            System.out.print("Numero de Prestamo (ej: PRES-...): ");
            String pres = scanner.nextLine().trim();

            System.out.print("Codigo de Herramienta devuelta (ej: HER-TOR-004): ");
            String cod = scanner.nextLine().trim();
            if (cod.isEmpty()) cod = "HER-TOR-004";

            System.out.println("Calificacion del estado fisico de retorno (RF39):");
            System.out.println(" 1. BUEN ESTADO (Pasa a Disponible - RF40)");
            System.out.println(" 2. CON AVERIA (Pasa a En Mantenimiento - RF40 Ex1)");
            System.out.println(" 3. INCOMPLETA (Requiere informe tecnico)");
            System.out.print("Seleccion (1-3): ");
            String estOpc = scanner.nextLine().trim();

            EstadoDevolucion estadoFisico = switch (estOpc) {
                case "2" -> EstadoDevolucion.CON_AVERIA;
                case "3" -> EstadoDevolucion.INCOMPLETA;
                default -> EstadoDevolucion.BUEN_ESTADO;
            };

            System.out.print("Detalle de inspeccion o averia: ");
            String obs = scanner.nextLine().trim();

            DevolucionHerramientaRequest.ItemDevolucionRequest item = DevolucionHerramientaRequest.ItemDevolucionRequest.builder()
                    .codHerramienta(cod)
                    .estadoFisico(estadoFisico)
                    .build();

            DevolucionHerramientaRequest req = DevolucionHerramientaRequest.builder()
                    .prestamoNum(pres)
                    .detalleIncidencia(obs)
                    .items(List.of(item))
                    .build();

            MensajeGenericoResponse res = prestamoService.registrarDevolucion(CORREO_ALMACENISTA, req, ipLocal);
            System.out.println("EXITO (RF40): " + res.getMensaje());
        } catch (Exception e) {
            System.out.println("Aviso: " + e.getMessage());
        }
    }

    // RF41, RF42: Reporte manual de extravio y asociacion automatica al ultimo custodio de la bitacora
    private void reportarExtravioHerramienta() {
        System.out.println("\n-- Reportar Herramienta como Extraviada (RF41, RF42) --");
        try {
            System.out.print("Codigo de Herramienta extraviada: ");
            String cod = scanner.nextLine().trim();
            System.out.print("Motivo o circunstancias del extravio (minimo 10 caracteres): ");
            String mot = scanner.nextLine().trim();
            if (mot.length() < 10) mot = "Herramienta extraviada en labor subterranea mina";

            ReporteExtravioRequest req = ReporteExtravioRequest.builder()
                    .codHerramienta(cod)
                    .motivoExtravio(mot)
                    .build();

            MensajeGenericoResponse res = prestamoService.reportarHerramientaExtraviada(CORREO_ALMACENISTA, req, ipLocal);
            System.out.println("RESULTADO (RF42): " + res.getMensaje() + " | Responsabilidad imputada a: " + res.getDato());
        } catch (Exception e) {
            System.out.println("Aviso: " + e.getMessage());
        }
    }
}