-- ============================================================================
-- PROYECTO: SGSRA-MD (Master Drilling Perú S.A.)
-- SCRIPT DE INSERCION Y POBLACION DE DATOS DE PRUEBA REALISTAS
-- COMPATIBILIDAD: PostgreSQL 16+ / PostgreSQL 18 (Render Cloud DB)
-- ============================================================================
-- Este script puebla la base de datos con un escenario integral de mina:
-- 1. Usuarios Oficiales (Admin, Mecanico, Almacenista con claves admin, meca, alma)
-- 2. Maquinaria pesada (Raise Borers, Jumbos, Scooptrams)
-- 3. Repuestos con stocks normales y stocks criticos bajo el minimo
-- 4. Herramientas en todos sus estados: Disponible, Prestada, En Mora, En Mantenimiento, Extraviada
-- 5. Solicitudes historicas (hace 5 meses y 2 meses) y actuales (Pendientes, Aprobadas, Parciales, Rechazadas)
-- 6. Prestamos y Devoluciones reales (Activos, Moras, Cerrados con conformidad e incidencias)
-- 7. Notificaciones activas segmentadas por rol
-- 8. Trazabilidad criptografica de auditoria (SHA-256) y recuperacion de claves
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 0. LIMPIEZA TOTAL EN CASCADA (Permite re-ejecutar sin duplicados)
-- ----------------------------------------------------------------------------
TRUNCATE TABLE 
    devolucion_detalle, 
    devolucion, 
    prestamo_detalle, 
    prestamo, 
    detalle_rechazo, 
    dictamen_rechazo, 
    solicitud_detalle, 
    solicitud, 
    registro_detalle, 
    registro, 
    notificacion, 
    auditoria_operacion, 
    solicitud_recuperacion_clave, 
    herramienta, 
    repuesto, 
    maquinaria, 
    mecanico, 
    almacenista, 
    administrador, 
    usuario 
RESTART IDENTITY CASCADE;

-- ----------------------------------------------------------------------------
-- 1. USUARIOS SEMILLA OFICIALES
-- ----------------------------------------------------------------------------
-- Contraseñas BCrypt:
-- Admin:       leao.chura@masterdrilling.com    / pass: admin ($2a$10$SETRphAwaMIowSMY05fzae15b4lzZEG9kSOOnAoinuxztQIl.4e3i)
-- Mecanico:    carlos.baro@masterdrilling.com   / pass: meca  ($2a$10$iD7BzGlbX42.b2eXAm2Jj.yF28BJ5sxd2V2VZkqei8kRLiMo9gGpC)
-- Almacenista: marcos.baro@masterdrilling.com   / pass: alma  ($2a$10$Mhsh51WoSbSQ0Qm6f.o38.0qH3NZZZTksyMEGZCVdr3okakrwU292)

INSERT INTO usuario (id_usuario, dni, nombre, correo_corporativo, contrasena_hash, rol, estado_cuenta, intentos_fallidos, creado_en) VALUES
(1, '10293847', 'Leao Chura', 'leao.chura@masterdrilling.com', '$2a$10$SETRphAwaMIowSMY05fzae15b4lzZEG9kSOOnAoinuxztQIl.4e3i', 'ADMINISTRADOR', 'ACTIVO', 0, '2026-01-01 08:00:00'),
(2, '70000001', 'Carlos Mendoza Baro', 'carlos.baro@masterdrilling.com', '$2a$10$iD7BzGlbX42.b2eXAm2Jj.yF28BJ5sxd2V2VZkqei8kRLiMo9gGpC', 'MECANICO', 'ACTIVO', 0, '2026-01-01 08:00:00'),
(3, '70000002', 'Marcos Ramos Baro', 'marcos.baro@masterdrilling.com', '$2a$10$Mhsh51WoSbSQ0Qm6f.o38.0qH3NZZZTksyMEGZCVdr3okakrwU292', 'ALMACENISTA', 'ACTIVO', 0, '2026-01-01 08:00:00');

SELECT setval(pg_get_serial_sequence('usuario', 'id_usuario'), 3);

-- ----------------------------------------------------------------------------
-- 2. TABLAS DE ROLES ESPECIALIZADOS
-- ----------------------------------------------------------------------------
INSERT INTO administrador (dni_administrador, nombre_administrador, correo_corporativo) VALUES
('10293847', 'Leao Chura', 'leao.chura@masterdrilling.com');

INSERT INTO mecanico (dni_mecanico, nombre_mecanico, especialidad_mecanico, cargo_mecanico, telefono) VALUES
('70000001', 'Carlos Mendoza Baro', 'Sistemas Hidraulicos y Perforacion Raise Borer', 'Mecanico Especialista de Mina', '987654321');

INSERT INTO almacenista (dni_almacenista, nombre_almacenista, sede_asignada) VALUES
('70000002', 'Marcos Ramos Baro', 'Sede Mina Central - Panol Principal');

-- ----------------------------------------------------------------------------
-- 3. FLOTA DE MAQUINARIA PESADA
-- ----------------------------------------------------------------------------
INSERT INTO maquinaria (cod_maquinaria, modelo_maquinaria, serie_fabricante, estado_operativo) VALUES
('MD-RB-01', 'Raise Borer Rhino 1008 DC', 'SER-EPI-9901', 'OPERATIVA'),
('MD-RB-02', 'Raise Borer Rhino 2002 Standard', 'SER-MD-4402', 'OPERATIVA'),
('MD-RB-03', 'Perforadora Subterranea Rhino 1500', 'SER-EPI-2002', 'EN_MANTENIMIENTO'),
('MD-RB-04', 'Raise Borer Rhino 2008 Blindhole', 'SER-MD-8812', 'OPERATIVA'),
('MD-RB-05', 'Raise Borer Rhino 400 Boxhole', 'SER-MD-3319', 'OPERATIVA'),
('MD-JM-01', 'Jumbo Electrohidraulico Sandvik DD421', 'SER-SDK-5510', 'OPERATIVA'),
('MD-JM-02', 'Jumbo Frontal Epiroc Boomer 282', 'SER-EPI-6621', 'EN_MANTENIMIENTO'),
('MD-SC-01', 'Scooptram Epiroc ST14 14 Toneladas', 'SER-EPI-7714', 'OPERATIVA'),
('MD-SC-02', 'Cargador de Bajo Perfil Cat R1700K', 'SER-CAT-1702', 'OPERATIVA'),
('MD-DP-01', 'Dumper Subterraneo Epiroc MT42', 'SER-EPI-4201', 'INOPERATIVA'),
('MD-BL-01', 'Compresor de Aire Portatil Atlas Copco XATS 400', 'SER-AC-4001', 'OPERATIVA'),
('MD-GEN-01', 'Grupo Electrogeno Cummins QSK23 900 kVA', 'SER-CUM-9002', 'OPERATIVA');

-- ----------------------------------------------------------------------------
-- 4. CATALOGO MAESTRO DE REPUESTOS (25 Componentes, algunos en Stock Crítico)
-- ----------------------------------------------------------------------------
INSERT INTO repuesto (cod_parte, nombre_repuesto, stock_actual, stock_minimo, descripcion, activo, imagen_url) VALUES
('P-REX-024', 'Bomba de pistones axiales Rexroth A4VSO 125 DR', 8, 2, 'Bomba hidraulica principal de circuito cerrado para rotacion de cabeza', TRUE, '/uploads/repuestos/P-REX-024.png'),
('H-ESP-118', 'Manguera espiral 4SP 1 pulgada x 3000 PSI', 35, 5, 'Manguera de alta presion 400 bar para transmision hidraulica', TRUE, '/uploads/repuestos/P-PAR-101.png'),
('F-HYD-882', 'Filtro hidraulico de retorno 10 micras Hydac', 48, 10, 'Filtro de retorno de aceite para tanque principal con indicador', TRUE, '/uploads/repuestos/P-PAR-101.png'),
('K-SEL-340', 'Kit de sellos Viton de alta temperatura para cilindro', 22, 4, 'Sellos para cilindro elevador principal y estabilizadores hidraulicos', TRUE, '/uploads/repuestos/P-CAT-330.png'),
('V-ALL-111', 'Valvula de control direccional proporcional Rexroth', 12, 3, 'Modulo de mando electrohidraulico pilotado de 4 vias / 3 posiciones', TRUE, '/uploads/repuestos/P-REX-025.png'),
('B-CIL-501', 'Cilindro hidraulico de empuje y traccion Rhino 2002', 1, 2, 'Cilindro de carrera larga de avance de perforacion [STOCK CRITICO]', TRUE, '/uploads/repuestos/P-CAT-331.png'),
('E-ENG-902', 'Bomba de lubricacion de engranajes Lincoln Quicklub', 7, 2, 'Unidad de engrase automatico centralizado multipunto', TRUE, '/uploads/repuestos/P-REX-024.png'),
('R-ROD-065', 'Barra de perforacion 10 pulgadas x 5 pies MD Heavy', 38, 8, 'Barra de perforacion con rosca estandar DI-22 para raiseboring', TRUE, '/uploads/repuestos/P-CAT-330.png'),
('C-CUT-128', 'Cortador de carburo de tungsteno TCI 12-1/4 pulgada', 16, 4, 'Cortador montado en cabeza escariadora (Reamer head)', TRUE, '/uploads/repuestos/P-CAT-331.png'),
('M-MOT-440', 'Motor electrico trifasico ABB 250 kW 460V / 60Hz', 1, 1, 'Motor de accionamiento principal de rotacion con proteccion IP66', TRUE, '/uploads/repuestos/P-CAT-331.png'),
('F-AIR-102', 'Filtro separador aire-aceite Donaldson', 30, 6, 'Elemento separador para sistema neumatico del compresor auxiliar', TRUE, '/uploads/repuestos/P-DON-502.png'),
('S-SEN-088', 'Sensor de presion inductivo 0-600 bar Danfoss', 14, 3, 'Transmisor de presion con salida analogica 4-20mA', TRUE, '/uploads/repuestos/P-PAR-101.png'),
('S-TEM-045', 'Sensor de temperatura PT100 con vaina de acero inox', 20, 5, 'Sensor de monitoreo termico para cojinetes de caja reductora', TRUE, '/uploads/repuestos/P-PAR-101.png'),
('G-RED-701', 'Pinon planetario etapa secundaria para caja reductora', 6, 2, 'Engranaje tratado termicamente para multiplicador de torque', TRUE, '/uploads/repuestos/P-CAT-330.png'),
('A-ROD-305', 'Rodamiento de rodillos conicos Timken para spindle', 6, 2, 'Rodamiento de carga radial/axial combinada para eje principal', TRUE, '/uploads/repuestos/P-CAT-330.png'),
('J-RET-211', 'Reten laberinto de aceite para cabezal de perforacion', 41, 10, 'Sello mecanico de estanqueidad para evitar ingreso de detritos', TRUE, '/uploads/repuestos/P-PAR-101.png'),
('E-VAR-550', 'Variador de frecuencia Siemens Sinamics G120 200kW', 1, 2, 'Modulo inversor de potencia para RPM en cabeza [STOCK CRITICO]', TRUE, '/uploads/repuestos/P-REX-025.png'),
('C-CAB-004', 'Cable minero extra flexible 4x70 mm2 vulcanizado 1kV', 120, 25, 'Cable de alimentacion principal con blindaje antidesgarro', TRUE, '/uploads/repuestos/P-DON-502.png'),
('V-SEC-015', 'Valvula de seguridad y alivio de presion 350 bar Sun', 14, 3, 'Valvula cartucho con rosca UNF para proteccion de sobrecarga', TRUE, '/uploads/repuestos/P-REX-025.png'),
('N-BOQ-090', 'Boquilla aspersora de refrigeracion de cabeza 3/8 NPT', 56, 15, 'Boquilla de lavado a presion para enfriamiento de cortadores', TRUE, '/uploads/repuestos/P-DON-502.png'),
('F-COM-012', 'Filtro coalescente de combustible Racor 1000FH', 40, 8, 'Separador de agua y particulas para motor diesel auxiliar', TRUE, '/uploads/repuestos/P-DON-502.png'),
('K-FRE-104', 'Kit de pastillas de freno para malacate de servicio', 16, 4, 'Material de friccion de alta resistencia para winche de apoyo', TRUE, '/uploads/repuestos/P-CAT-330.png'),
('P-ACC-300', 'Acumulador de presion de nitrogeno 10L 330 bar Olaer', 5, 2, 'Vejiga de amortiguacion para pulsaciones del sistema hidraulico', TRUE, '/uploads/repuestos/P-REX-024.png'),
('T-TRA-055', 'Transductor de torque digital para columna de varillaje', 4, 1, 'Medidor dinamico de torsion en linea durante escariado', TRUE, '/uploads/repuestos/P-PAR-101.png'),
('B-GRA-200', 'Grasa sintetica para rodamientos pesados Mobilith SHC (Balde 18kg)', 25, 5, 'Grasa grado NLGI 2 con aditivos EP para alta vibracion', TRUE, '/uploads/repuestos/P-DON-502.png');

-- ----------------------------------------------------------------------------
-- 5. INVENTARIO DE HERRAMIENTAS EN PANOL (25 Herramientas en todos los Estados)
-- ----------------------------------------------------------------------------
-- Estados disponibles: 'Disponible', 'Prestada', 'En Mora', 'En Mantenimiento', 'Extraviada', 'Baja Tecnica'
INSERT INTO herramienta (cod_herramienta, nombre_herramienta, marca_herramienta, categoria, estado_actual, imagen_url) VALUES
('HER-TOR-004', 'Torquimetro Industrial 3/4 pulgada 100-600 Nm', 'Proto', 'Manuales', 'Prestada', '/uploads/herramientas/HER-TOR-004.png'),
('HER-TOR-005', 'Torquimetro de Zafe 1 pulgada 300-1500 Nm', 'Norbar', 'Manuales', 'En Mora', '/uploads/herramientas/HER-TOR-005.png'),
('HER-PIST-003', 'Pistola de impacto neumatica 1 pulgada Heavy Duty', 'Chicago Pneumatic', 'Neumaticas', 'Prestada', '/uploads/herramientas/HER-PIS-012.png'),
('HER-PIST-004', 'Pistola de impacto neumatica 3/4 pulgada', 'Ingersoll Rand', 'Neumaticas', 'Disponible', '/uploads/herramientas/HER-PIS-012.png'),
('HER-BOM-008', 'Bomba hidraulica manual de 2 etapas 700 bar', 'Enerpac', 'Hidraulicas', 'Prestada', '/uploads/herramientas/HER-ENE-008.png'),
('HER-BOM-009', 'Bomba hidraulica electrohidraulica portatil 700 bar', 'Enerpac', 'Hidraulicas', 'Disponible', '/uploads/herramientas/HER-ENE-008.png'),
('HER-MAN-022', 'Manometro digital de presion diferencial 0-700 bar', 'Wika', 'Manuales', 'En Mora', '/uploads/herramientas/HER-PIN-003.png'),
('HER-LLAV-015', 'Juego de llaves combinadas milimetricas 6-32mm (26 pzas)', 'Stanley FatMax', 'Manuales', 'Disponible', '/uploads/herramientas/HER-TOR-004.png'),
('HER-LLAV-016', 'Juego de llaves de golpe acodadas 36-65mm (10 pzas)', 'Williams', 'Manuales', 'Disponible', '/uploads/herramientas/HER-TOR-005.png'),
('HER-CIL-010', 'Cilindro hidraulico plano (Pancake) de 50 Toneladas', 'Enerpac', 'Hidraulicas', 'Disponible', '/uploads/herramientas/HER-ENE-008.png'),
('HER-EXT-002', 'Extractor mecanico e hidraulico de engranajes y poleas 20T', 'Posi Lock', 'Manuales', 'Disponible', '/uploads/herramientas/HER-TOR-004.png'),
('HER-MUL-001', 'Multimetro digital para mineria True RMS CAT IV 600V', 'Fluke 28-II', 'Electricas', 'Disponible', '/uploads/herramientas/HER-FLU-001.png'),
('HER-PIN-007', 'Pinza amperimetrica AC/DC 1000A con registro', 'Fluke 376 FC', 'Electricas', 'Disponible', '/uploads/herramientas/HER-PIN-003.png'),
('HER-MEG-003', 'Megohmetro digital de aislamiento hasta 5000V', 'Megger MIT515', 'Electricas', 'Disponible', '/uploads/herramientas/HER-FLU-001.png'),
('HER-AMI-005', 'Amoladora angular de 7 pulgadas 2400W Industrial', 'DeWalt', 'Electricas', 'En Mantenimiento', '/uploads/herramientas/HER-PIS-012.png'),
('HER-TAL-012', 'Rotomartillo electro-neumatico SDS-Max 1500W', 'Bosch Professional', 'Electricas', 'Disponible', '/uploads/herramientas/HER-PIS-012.png'),
('HER-ENG-001', 'Engrasadora neumatica para tambor de grasa 20kg', 'Graco', 'Neumaticas', 'Disponible', '/uploads/herramientas/HER-ENE-008.png'),
('HER-LAN-003', 'Lanza termica cortadora de pernos y pines atascados', 'Arcair', 'Neumaticas', 'Disponible', '/uploads/herramientas/HER-PIS-012.png'),
('HER-TIR-002', 'Tirfor / Cabrestante manual de cable 3.2 Toneladas', 'Tractel', 'Manuales', 'Disponible', '/uploads/herramientas/HER-TOR-005.png'),
('HER-TEC-008', 'Tecle de cadena de palanca 6 Toneladas x 3 metros', 'Elephant', 'Manuales', 'Disponible', '/uploads/herramientas/HER-ENE-008.png'),
('HER-PRE-004', 'Prensa hidraulica de taller portatil 30 Toneladas', 'BVA Hydraulics', 'Hidraulicas', 'En Mantenimiento', '/uploads/herramientas/HER-ENE-008.png'),
('HER-ALI-002', 'Alineador laser de poleas y acoplamientos de motor', 'SKF TKBA 40', 'Electricas', 'Disponible', '/uploads/herramientas/HER-PIN-003.png'),
('HER-CAL-006', 'Calibrador vernier digital resolucion 0.01mm x 300mm', 'Mitutoyo', 'Manuales', 'Disponible', '/uploads/herramientas/HER-TOR-004.png'),
('HER-TERM-01', 'Camara termografica infrarroja para diagnostico', 'FLIR E8-XT', 'Electricas', 'Disponible', '/uploads/herramientas/HER-FLU-001.png'),
('HER-LIN-014', 'Linterna antideflagrante intrinsecamente segura para tunel', 'Pelican 3715', 'Electricas', 'Extraviada', '/uploads/herramientas/HER-PIN-003.png');

-- ----------------------------------------------------------------------------
-- 6. SOLICITUDES DE REPUESTOS (Historicas 5 y 2 meses atrás, y Actuales)
-- ----------------------------------------------------------------------------
-- A. Históricas de hace 5 meses (Junio 2026):
-- SOL-2026-0001: ENTREGADA
INSERT INTO solicitud (solicitud_num, fecha_emision, hora_emision, prioridad_solicitud, justificacion_tecnica, estado_solicitud, dni_mecanico, cod_maquina) VALUES
('SOL-2026-0001', '2026-06-15', '08:30:00', 'ALTA', 'Mantenimiento preventivo mayor de 1000 horas y recambio de filtros de rotacion en Raise Borer Rhino 1008 DC.', 'ENTREGADA', '70000001', 'MD-RB-01');

INSERT INTO solicitud_detalle (solicitud_num, item, cantidad_repuesto, cod_parte, estado_item) VALUES
('SOL-2026-0001', 1, 1, 'P-REX-024', 'APROBADO'),
('SOL-2026-0001', 2, 2, 'F-HYD-882', 'APROBADO');

-- SOL-2026-0002: RECHAZADA (Con Dictamen y Detalle de Rechazo formal)
INSERT INTO solicitud (solicitud_num, fecha_emision, hora_emision, prioridad_solicitud, justificacion_tecnica, estado_solicitud, dni_mecanico, cod_maquina) VALUES
('SOL-2026-0002', '2026-06-28', '14:15:00', 'MEDIA', 'Reemplazo preventivo de variador de frecuencia por fluctuaciones reportadas en Jumbo Sandvik.', 'RECHAZADA', '70000001', 'MD-JM-01');

INSERT INTO solicitud_detalle (solicitud_num, item, cantidad_repuesto, cod_parte, estado_item) VALUES
('SOL-2026-0002', 1, 1, 'E-VAR-550', 'RECHAZADO');

INSERT INTO dictamen_rechazo (dictamen_num, ref_solicitud_num, fecha_evaluacion, justificacion_rechazo, dni_administrador) VALUES
('DIC-2026-0001', 'SOL-2026-0002', '2026-06-29', 'No procede el cambio total de variador. La revision electrica indica unicamente calibracion de parametros de entrada.', '10293847');

INSERT INTO detalle_rechazo (dictamen_num, item, cod_parte, cantidad_rechazada, motivo_especifico_item) VALUES
('DIC-2026-0001', 1, 'E-VAR-550', 1, 'Componente operable tras reseteo termico; reservar variador en almacen central.');

-- B. Históricas de hace 2 meses (Septiembre 2026):
-- SOL-2026-0003: APROBADA_PARCIAL (Kit de sellos aprobado, cilindro rechazado)
INSERT INTO solicitud (solicitud_num, fecha_emision, hora_emision, prioridad_solicitud, justificacion_tecnica, estado_solicitud, dni_mecanico, cod_maquina) VALUES
('SOL-2026-0003', '2026-09-10', '09:45:00', 'ALTA', 'Overhaul de sellos y cilindro de empuje para Raise Borer Rhino 2002 Standard antes de tiro piloto.', 'APROBADA_PARCIAL', '70000001', 'MD-RB-02');

INSERT INTO solicitud_detalle (solicitud_num, item, cantidad_repuesto, cod_parte, estado_item) VALUES
('SOL-2026-0003', 1, 2, 'K-SEL-340', 'APROBADO'),
('SOL-2026-0003', 2, 1, 'B-CIL-501', 'RECHAZADO');

INSERT INTO dictamen_rechazo (dictamen_num, ref_solicitud_num, fecha_evaluacion, justificacion_rechazo, dni_administrador) VALUES
('DIC-2026-0002', 'SOL-2026-0003', '2026-09-11', 'Se aprueban sellos Viton. Se deniega cilindro completo por encontrarse en stock de seguridad reservado a contingencias criticas.', '10293847');

INSERT INTO detalle_rechazo (dictamen_num, item, cod_parte, cantidad_rechazada, motivo_especifico_item) VALUES
('DIC-2026-0002', 2, 'B-CIL-501', 1, 'Solo queda 1 unidad en panol y esta asignada a perforadora en servicio activo.');

-- SOL-2026-0004: APROBADA
INSERT INTO solicitud (solicitud_num, fecha_emision, hora_emision, prioridad_solicitud, justificacion_tecnica, estado_solicitud, dni_mecanico, cod_maquina) VALUES
('SOL-2026-0004', '2026-09-22', '11:20:00', 'MEDIA', 'Recambio planificado de cortadores TCI y boquillas de refrigeracion para cabeza escariadora.', 'APROBADA', '70000001', 'MD-RB-04');

INSERT INTO solicitud_detalle (solicitud_num, item, cantidad_repuesto, cod_parte, estado_item) VALUES
('SOL-2026-0004', 1, 2, 'C-CUT-128', 'APROBADO'),
('SOL-2026-0004', 2, 4, 'N-BOQ-090', 'APROBADO');

-- C. Solicitudes Actuales (Noviembre 2026 - Casos de prueba interactivos):
-- SOL-2026-0005: PENDIENTE (Alta prioridad, para que el Admin la evalue o apruebe)
INSERT INTO solicitud (solicitud_num, fecha_emision, hora_emision, prioridad_solicitud, justificacion_tecnica, estado_solicitud, dni_mecanico, cod_maquina) VALUES
('SOL-2026-0005', '2026-11-18', '07:45:00', 'ALTA', 'Falla repentina en bomba de lubricacion Lincoln Quicklub. Riesgo inminente de amarre en engranajes de perforadora Rhino 1500.', 'PENDIENTE', '70000001', 'MD-RB-03');

INSERT INTO solicitud_detalle (solicitud_num, item, cantidad_repuesto, cod_parte, estado_item) VALUES
('SOL-2026-0005', 1, 1, 'E-ENG-902', 'PENDIENTE'),
('SOL-2026-0005', 2, 2, 'B-GRA-200', 'PENDIENTE');

-- SOL-2026-0006: PENDIENTE (Media prioridad)
INSERT INTO solicitud (solicitud_num, fecha_emision, hora_emision, prioridad_solicitud, justificacion_tecnica, estado_solicitud, dni_mecanico, cod_maquina) VALUES
('SOL-2026-0006', '2026-11-19', '10:30:00', 'MEDIA', 'Reposicion de mangueras hidraulicas 4SP y sensores de presion danados por desprendimiento menor de roca en frente de avance.', 'PENDIENTE', '70000001', 'MD-JM-02');

INSERT INTO solicitud_detalle (solicitud_num, item, cantidad_repuesto, cod_parte, estado_item) VALUES
('SOL-2026-0006', 1, 4, 'H-ESP-118', 'PENDIENTE'),
('SOL-2026-0006', 2, 1, 'S-SEN-088', 'PENDIENTE');

-- SOL-2026-0007: APROBADA (Lista para que el Almacenista la entregue)
INSERT INTO solicitud (solicitud_num, fecha_emision, hora_emision, prioridad_solicitud, justificacion_tecnica, estado_solicitud, dni_mecanico, cod_maquina) VALUES
('SOL-2026-0007', '2026-11-20', '08:00:00', 'ALTA', 'Recambio urgente de rodamientos Timken y retenes laberinto de eje principal para Rhino 1008 DC.', 'APROBADA', '70000001', 'MD-RB-01');

INSERT INTO solicitud_detalle (solicitud_num, item, cantidad_repuesto, cod_parte, estado_item) VALUES
('SOL-2026-0007', 1, 2, 'A-ROD-305', 'APROBADO'),
('SOL-2026-0007', 2, 4, 'J-RET-211', 'APROBADO');

-- ----------------------------------------------------------------------------
-- 7. CICLO DE PRESTAMOS Y DEVOLUCIONES DE HERRAMIENTAS
-- ----------------------------------------------------------------------------
-- A. Prestamo Historico Cerrado (Hace 5 meses):
INSERT INTO prestamo (prestamo_num, fecha_prestamo, hora_salida, dni_almacenista, dni_mecanico, estado_prestamo) VALUES
('PRE-2026-0001', '2026-06-15', '09:00:00', '70000002', '70000001', 'CERRADO');

INSERT INTO prestamo_detalle (prestamo_num, item, cod_herramienta, nombre_herramienta, estado_herramienta, hora_retorno, firma_mecanico) VALUES
('PRE-2026-0001', 1, 'HER-LLAV-015', 'Juego de llaves combinadas milimetricas 6-32mm', 'Devuelto Conforme', '17:30:00', 'FIRMA_BASE64_CARLOS_BARO_CONFORME_01'),
('PRE-2026-0001', 2, 'HER-MUL-001', 'Multimetro digital para mineria True RMS', 'Devuelto Conforme', '17:30:00', 'FIRMA_BASE64_CARLOS_BARO_CONFORME_02');

INSERT INTO devolucion (devolucion_num, fecha_devolucion, hora_retorno, detalle_incidencia, prestamo_num, dni_almacenista, dni_mecanico) VALUES
('DEV-2026-0001', '2026-06-15', '17:30:00', 'Retorno conforme al termino de guardia diurna. Herramientas limpias.', 'PRE-2026-0001', '70000002', '70000001');

INSERT INTO devolucion_detalle (devolucion_num, item, cod_herramienta, estado_herramienta) VALUES
('DEV-2026-0001', 1, 'HER-LLAV-015', 'Buen Estado'),
('DEV-2026-0001', 2, 'HER-MUL-001', 'Buen Estado');

-- B. Prestamo Historico Cerrado (Hace 2 meses):
INSERT INTO prestamo (prestamo_num, fecha_prestamo, hora_salida, dni_almacenista, dni_mecanico, estado_prestamo) VALUES
('PRE-2026-0002', '2026-09-10', '08:15:00', '70000002', '70000001', 'CERRADO');

INSERT INTO prestamo_detalle (prestamo_num, item, cod_herramienta, nombre_herramienta, estado_herramienta, hora_retorno, firma_mecanico) VALUES
('PRE-2026-0002', 1, 'HER-EXT-002', 'Extractor mecanico e hidraulico de engranajes 20T', 'Devuelto Conforme', '18:00:00', 'FIRMA_BASE64_CARLOS_BARO_CONFORME_03'),
('PRE-2026-0002', 2, 'HER-CAL-006', 'Calibrador vernier digital resolucion 0.01mm', 'Devuelto Conforme', '18:00:00', 'FIRMA_BASE64_CARLOS_BARO_CONFORME_04');

INSERT INTO devolucion (devolucion_num, fecha_devolucion, hora_retorno, detalle_incidencia, prestamo_num, dni_almacenista, dni_mecanico) VALUES
('DEV-2026-0002', '2026-09-10', '18:00:00', 'Extractor presenta desgaste superficial regular por uso en polea.', 'PRE-2026-0002', '70000002', '70000001');

INSERT INTO devolucion_detalle (devolucion_num, item, cod_herramienta, estado_herramienta) VALUES
('DEV-2026-0002', 1, 'HER-EXT-002', 'Buen Estado'),
('DEV-2026-0002', 2, 'HER-CAL-006', 'Buen Estado');

-- C. Prestamo ACTIVO (Actualmente en uso por el Mecanico - Herramientas 'Prestada'):
INSERT INTO prestamo (prestamo_num, fecha_prestamo, hora_salida, dni_almacenista, dni_mecanico, estado_prestamo) VALUES
('PRE-2026-0003', '2026-11-20', '07:15:00', '70000002', '70000001', 'ACTIVO');

INSERT INTO prestamo_detalle (prestamo_num, item, cod_herramienta, nombre_herramienta, estado_herramienta, hora_retorno, firma_mecanico) VALUES
('PRE-2026-0003', 1, 'HER-TOR-004', 'Torquimetro Industrial 3/4 pulgada 100-600 Nm', 'En Uso en Galeria 450', NULL, 'FIRMA_DIGITAL_CARLOS_BARO_ACTIVO_TOR'),
('PRE-2026-0003', 2, 'HER-PIST-003', 'Pistola de impacto neumatica 1 pulgada Heavy Duty', 'En Uso en Galeria 450', NULL, 'FIRMA_DIGITAL_CARLOS_BARO_ACTIVO_PIS'),
('PRE-2026-0003', 3, 'HER-BOM-008', 'Bomba hidraulica manual de 2 etapas 700 bar', 'En Uso en Galeria 450', NULL, 'FIRMA_DIGITAL_CARLOS_BARO_ACTIVO_BOM');

-- D. Prestamo EN MORA (Vencido hace 2 dias sin devolver - Herramientas 'En Mora'):
INSERT INTO prestamo (prestamo_num, fecha_prestamo, hora_salida, dni_almacenista, dni_mecanico, estado_prestamo) VALUES
('PRE-2026-0004', '2026-11-18', '08:00:00', '70000002', '70000001', 'MORA');

INSERT INTO prestamo_detalle (prestamo_num, item, cod_herramienta, nombre_herramienta, estado_herramienta, hora_retorno, firma_mecanico) VALUES
('PRE-2026-0004', 1, 'HER-TOR-005', 'Torquimetro de Zafe 1 pulgada 300-1500 Nm', 'Retraso de Entrega > 48h', NULL, 'FIRMA_DIGITAL_CARLOS_BARO_MORA_01'),
('PRE-2026-0004', 2, 'HER-MAN-022', 'Manometro digital de presion diferencial 0-700 bar', 'Retraso de Entrega > 48h', NULL, 'FIRMA_DIGITAL_CARLOS_BARO_MORA_02');

-- E. Prestamo con Incidencia de Perdida / Herramienta 'Extraviada':
INSERT INTO prestamo (prestamo_num, fecha_prestamo, hora_salida, dni_almacenista, dni_mecanico, estado_prestamo) VALUES
('PRE-2026-0005', '2026-10-05', '08:30:00', '70000002', '70000001', 'CERRADO');

INSERT INTO prestamo_detalle (prestamo_num, item, cod_herramienta, nombre_herramienta, estado_herramienta, hora_retorno, firma_mecanico) VALUES
('PRE-2026-0005', 1, 'HER-LIN-014', 'Linterna antideflagrante intrinsecamente segura para tunel', 'Extraviada en pozo de perforacion', '18:00:00', 'FIRMA_DIGITAL_CARLOS_BARO_PERDIDA');

INSERT INTO devolucion (devolucion_num, fecha_devolucion, hora_retorno, detalle_incidencia, prestamo_num, dni_almacenista, dni_mecanico) VALUES
('DEV-2026-0003', '2026-10-05', '18:00:00', 'Mecanico reporta caida accidental de linterna al tiro inundado de la chimenea 4. Inaccesible.', 'PRE-2026-0005', '70000002', '70000001');

INSERT INTO devolucion_detalle (devolucion_num, item, cod_herramienta, estado_herramienta) VALUES
('DEV-2026-0003', 1, 'HER-LIN-014', 'Con Averia');

-- ----------------------------------------------------------------------------
-- 8. REGISTRO DE ALTA DE HERRAMIENTAS (Trazabilidad de Ingreso al Pañol)
-- ----------------------------------------------------------------------------
INSERT INTO registro (registro_num, fecha_ingreso, dni_almacenista) VALUES
('REG-2026-0001', '2026-01-10', '70000002');

INSERT INTO registro_detalle (registro_num, item, cod_herramienta) VALUES
('REG-2026-0001', 1, 'HER-TOR-004'),
('REG-2026-0001', 2, 'HER-TOR-005'),
('REG-2026-0001', 3, 'HER-PIST-003'),
('REG-2026-0001', 4, 'HER-BOM-008');

-- ----------------------------------------------------------------------------
-- 9. BANDEJA DE NOTIFICACIONES ACTIVAS (Segmentadas por Rol)
-- ----------------------------------------------------------------------------
-- Notificaciones para el Mecánico (Carlos Baro):
INSERT INTO notificacion (dni_destinatario, rol_destinatario, titulo, mensaje, tipo_alerta, leida, fecha_creacion) VALUES
('70000001', 'MECANICO', 'Solicitud Aprobada', 'Su solicitud SOL-2026-0007 ha sido APROBADA por Administracion. Puede acercarse al panol a retirar los repuestos.', 'APROBACION', FALSE, '2026-11-20 08:05:00'),
('70000001', 'MECANICO', 'Alerta de Mora en Devolucion', 'Tiene el prestamo PRE-2026-0004 con herramientas vencidas (Torquimetro Norbar y Manometro Wika). Regularice la entrega.', 'MORA', FALSE, '2026-11-19 18:00:00'),
('70000001', 'MECANICO', 'Solicitud Parcialmente Aprobada', 'Su solicitud SOL-2026-0003 fue evaluada con Dictamen DIC-2026-0002 (Sellos Viton aprobados).', 'INFO', TRUE, '2026-09-11 10:00:00');

-- Notificaciones para el Almacenista (Marcos Baro):
INSERT INTO notificacion (dni_destinatario, rol_destinatario, titulo, mensaje, tipo_alerta, leida, fecha_creacion) VALUES
('70000002', 'ALMACENISTA', 'Alerta de Retraso de Herramienta', 'El mecanico Carlos Baro no ha retornado el torquimetro HER-TOR-005 ni el manometro HER-MAN-022 del prestamo PRE-2026-0004.', 'MORA', FALSE, '2026-11-19 18:00:00'),
('70000002', 'ALMACENISTA', 'Stock Minimo Critico', 'El repuesto B-CIL-501 (Cilindro hidraulico Rhino 2002) ha alcanzado el stock critico de 1 unidad (Minimo: 2).', 'STOCK_MINIMO', FALSE, '2026-11-20 07:00:00'),
('70000002', 'ALMACENISTA', 'Stock Minimo Critico', 'El repuesto E-VAR-550 (Variador de frecuencia Siemens) cuenta con solo 1 unidad en stock.', 'STOCK_MINIMO', FALSE, '2026-11-20 07:01:00'),
('70000002', 'ALMACENISTA', 'Reporte de Extravio', 'Se ha registrado formalmente el extravio de la herramienta HER-LIN-014 en operacion de campo.', 'EXTRAVIO', TRUE, '2026-10-05 18:30:00');

-- Notificaciones para el Administrador (Leao Chura):
INSERT INTO notificacion (dni_destinatario, rol_destinatario, titulo, mensaje, tipo_alerta, leida, fecha_creacion) VALUES
('10293847', 'ADMINISTRADOR', 'Nueva Solicitud Pendiente URGENTE', 'El mecanico Carlos Baro ha emitido la solicitud SOL-2026-0005 con prioridad ALTA para la maquina MD-RB-03.', 'SOLICITUD', FALSE, '2026-11-18 07:46:00'),
('10293847', 'ADMINISTRADOR', 'Nueva Solicitud Pendiente', 'Se encuentra pendiente de evaluacion la solicitud SOL-2026-0006 con prioridad MEDIA.', 'SOLICITUD', FALSE, '2026-11-19 10:31:00'),
('10293847', 'ADMINISTRADOR', 'Alerta de Stocks Criticos', 'Existen 2 componentes bajo el umbral de stock minimo que requieren orden de compra prioritaria.', 'STOCK_MINIMO', FALSE, '2026-11-20 07:05:00');

-- ----------------------------------------------------------------------------
-- 10. AUDITORIA CRIPTOGRAFICA (Hash SHA-256 de Operaciones Clave)
-- ----------------------------------------------------------------------------
INSERT INTO auditoria_operacion (id_operacion, id_usuario, accion, ip_origen, timestamp, hash_sha256) VALUES
('OP-AUTH-001', 1, 'INICIO_SESION_ADMIN', '192.168.1.100', '2026-11-20 07:30:00', 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'),
('OP-SOL-005', 2, 'CREACION_SOLICITUD', '192.168.1.105', '2026-11-18 07:45:00', 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3'),
('OP-SOL-007', 1, 'APROBACION_SOLICITUD', '192.168.1.100', '2026-11-20 08:00:00', '8f434346648f6b96df89dda901c5176b10a6d83961dd3c1ac88b59b2dc327aa4'),
('OP-PRES-003', 3, 'DESPACHO_PRESTAMO_HERRAMIENTAS', '192.168.1.102', '2026-11-20 07:15:00', 'b5a2c9b149b64f1002b83d0b0ef82e830abb051415a5daec0692762211ab374c');

-- ----------------------------------------------------------------------------
-- 11. SOLICITUDES DE RECUPERACION DE CLAVE (Pruebas de Seguridad RF06)
-- ----------------------------------------------------------------------------
INSERT INTO solicitud_recuperacion_clave (dni_solicitante, nombre_solicitante, correo_solicitante, rol_solicitante, motivo, estado, fecha_solicitud, fecha_resolucion, dni_administrador, observacion_admin, foto_selfie_url) VALUES
('70000001', 'Carlos Mendoza Baro', 'carlos.baro@masterdrilling.com', 'MECANICO', 'Olvido de credencial tras cambio de guardia en campamento', 'PENDIENTE', '2026-11-20 06:30:00', NULL, NULL, NULL, '/uploads/selfies/selfie_carlos_baro.jpg'),
('70000002', 'Marcos Ramos Baro', 'marcos.baro@masterdrilling.com', 'ALMACENISTA', 'Bloqueo temporal de terminal de panol por intentos fallidos', 'APROBADA', '2026-10-14 09:00:00', '2026-10-14 09:30:00', '10293847', 'Identidad verificada con DNI y biometria facial conforme.', '/uploads/selfies/selfie_marcos_baro.jpg');
