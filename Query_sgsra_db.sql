-- ============================================================================
-- PROYECTO: SGSRA-MD (Master Drilling)
-- SCRIPT DDL: CREACION DE TABLAS, RESTRICCIONES, INDICES Y DATOS SEMILLA
-- COMPATIBILIDAD: PostgreSQL 16+ / PostgreSQL 18
-- ============================================================================
sgsra_db

SELECT * FROM administrador;

-- Hash oficial generado por org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder
-- para la contraseña exacta: Admin123*
-- Hash BCrypt exacto para: admin123*
UPDATE usuario 
SET  estado_cuenta = 'ACTIVO',
    intentos_fallidos = 0
WHERE correo_corporativo IN ('leao.chura@masterdrilling.com');


-- Verificar estado actual
SELECT id_usuario, correo_corporativo, rol, estado_cuenta, intentos_fallidos 
FROM usuario 
WHERE LOWER(correo_corporativo) = 'leao.chura@masterdrilling.com';


-- Limpiar dependencias transaccionales
DELETE FROM solicitud_detalle;
DELETE FROM solicitud;
DELETE FROM prestamo_detalle;
DELETE FROM prestamo;
DELETE FROM devolucion_detalle;
DELETE FROM devolucion;
DELETE FROM registro_detalle;
DELETE FROM registro;
DELETE FROM detalle_rechazo;
DELETE FROM dictamen_rechazo;

-- Limpiar tablas de roles
DELETE FROM administrador;
DELETE FROM mecanico;
DELETE FROM almacenista;

-- Limpiar usuarios
DELETE FROM usuario;

SELECT id_auditoria, id_operacion, accion, timestamp 
FROM auditoria_operacion 
ORDER BY id_auditoria DESC;

DROP TABLE IF EXISTS registro_detalle CASCADE;
DROP TABLE IF EXISTS registro CASCADE;
DROP TABLE IF EXISTS devolucion_detalle CASCADE;
DROP TABLE IF EXISTS devolucion CASCADE;
DROP TABLE IF EXISTS prestamo_detalle CASCADE;
DROP TABLE IF EXISTS prestamo CASCADE;
DROP TABLE IF EXISTS herramienta CASCADE;
DROP TABLE IF EXISTS detalle_rechazo CASCADE;
DROP TABLE IF EXISTS dictamen_rechazo CASCADE;
DROP TABLE IF EXISTS solicitud_detalle CASCADE;
DROP TABLE IF EXISTS solicitud CASCADE;
DROP TABLE IF EXISTS maquinaria CASCADE;
DROP TABLE IF EXISTS repuesto CASCADE;
DROP TABLE IF EXISTS mecanico CASCADE;
DROP TABLE IF EXISTS almacenista CASCADE;
DROP TABLE IF EXISTS administrador CASCADE;
DROP TABLE IF EXISTS usuario CASCADE;
DROP TABLE IF EXISTS auditoria_operacion CASCADE;

-- 1. TABLA: USUARIO
CREATE TABLE usuario (
    id_usuario BIGSERIAL PRIMARY KEY,
    dni VARCHAR(8) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    correo_corporativo VARCHAR(100) UNIQUE NOT NULL,
    contrasena_hash VARCHAR(255) NOT NULL,
    rol VARCHAR(20) NOT NULL CHECK (rol IN ('MECANICO', 'ALMACENISTA', 'ADMINISTRADOR')),
    estado_cuenta VARCHAR(20) NOT NULL DEFAULT 'ACTIVO' CHECK (estado_cuenta IN ('ACTIVO', 'BLOQUEADO', 'INACTIVO')),
    intentos_fallidos INT NOT NULL DEFAULT 0,
    creado_en TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. TABLAS DE ROLES ESPECIALIZADOS
CREATE TABLE mecanico (
    dni_mecanico VARCHAR(8) PRIMARY KEY,
    nombre_mecanico VARCHAR(100) NOT NULL,
    especialidad_mecanico VARCHAR(50) NOT NULL,
    cargo_mecanico VARCHAR(50) NOT NULL,
    telefono VARCHAR(15),
    CONSTRAINT fk_mecanico_usuario FOREIGN KEY (dni_mecanico) 
        REFERENCES usuario(dni) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE almacenista (
    dni_almacenista VARCHAR(8) PRIMARY KEY,
    nombre_almacenista VARCHAR(100) NOT NULL,
    sede_asignada VARCHAR(50) NOT NULL,
    CONSTRAINT fk_almacenista_usuario FOREIGN KEY (dni_almacenista) 
        REFERENCES usuario(dni) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE administrador (
    dni_administrador VARCHAR(8) PRIMARY KEY,
    nombre_administrador VARCHAR(100) NOT NULL,
    correo_corporativo VARCHAR(100) NOT NULL,
    CONSTRAINT fk_administrador_usuario FOREIGN KEY (dni_administrador) 
        REFERENCES usuario(dni) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- 3. TABLA: REPUESTO
CREATE TABLE repuesto (
    cod_parte VARCHAR(30) PRIMARY KEY,
    nombre_repuesto VARCHAR(150) NOT NULL,
    stock_actual INT NOT NULL CHECK (stock_actual >= 0),
    stock_minimo INT NOT NULL CHECK (stock_minimo >= 0),
    descripcion TEXT,
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

-- 4. TABLA: MAQUINARIA
CREATE TABLE maquinaria (
    cod_maquinaria VARCHAR(20) PRIMARY KEY,
    modelo_maquinaria VARCHAR(100) NOT NULL,
    serie_fabricante VARCHAR(50),
    estado_operativo VARCHAR(20) NOT NULL CHECK (estado_operativo IN ('OPERATIVA', 'EN_MANTENIMIENTO', 'INOPERATIVA', 'BAJA'))
);

-- 5. TABLA: SOLICITUD
CREATE TABLE solicitud (
    solicitud_num VARCHAR(20) PRIMARY KEY,
    fecha_emision DATE NOT NULL,
    hora_emision TIME WITHOUT TIME ZONE NOT NULL,
    prioridad_solicitud VARCHAR(20) NOT NULL CHECK (prioridad_solicitud IN ('BAJA', 'MEDIA', 'ALTA')),
    justificacion_tecnica TEXT NOT NULL,
    estado_solicitud VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE' CHECK (estado_solicitud IN ('PENDIENTE', 'APROBADA', 'APROBADA_PARCIAL', 'RECHAZADA', 'ORDEN_CONTACTADA')),
    dni_mecanico VARCHAR(8) NOT NULL,
    cod_maquina VARCHAR(20) NOT NULL,
    CONSTRAINT fk_solicitud_mecanico FOREIGN KEY (dni_mecanico) 
        REFERENCES mecanico(dni_mecanico) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_solicitud_maquinaria FOREIGN KEY (cod_maquina) 
        REFERENCES maquinaria(cod_maquinaria) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- 6. TABLA: SOLICITUD_DETALLE
CREATE TABLE solicitud_detalle (
    solicitud_num VARCHAR(20) NOT NULL,
    item INT NOT NULL,
    cantidad_repuesto INT NOT NULL CHECK (cantidad_repuesto > 0),
    cod_parte VARCHAR(30) NOT NULL,
    estado_item VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE' CHECK (estado_item IN ('PENDIENTE', 'APROBADO', 'RECHAZADO')),
    PRIMARY KEY (solicitud_num, item),
    CONSTRAINT fk_soldet_solicitud FOREIGN KEY (solicitud_num) 
        REFERENCES solicitud(solicitud_num) ON DELETE CASCADE,
    CONSTRAINT fk_soldet_repuesto FOREIGN KEY (cod_parte) 
        REFERENCES repuesto(cod_parte) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- 7. TABLAS: DICTAMEN_RECHAZO Y DETALLE_RECHAZO
CREATE TABLE dictamen_rechazo (
    dictamen_num VARCHAR(20) PRIMARY KEY,
    ref_solicitud_num VARCHAR(20) NOT NULL,
    fecha_evaluacion DATE NOT NULL,
    justificacion_rechazo TEXT NOT NULL,
    dni_administrador VARCHAR(8) NOT NULL,
    CONSTRAINT fk_dictamen_solicitud FOREIGN KEY (ref_solicitud_num) 
        REFERENCES solicitud(solicitud_num) ON DELETE RESTRICT,
    CONSTRAINT fk_dictamen_admin FOREIGN KEY (dni_administrador) 
        REFERENCES administrador(dni_administrador) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE detalle_rechazo (
    dictamen_num VARCHAR(20) NOT NULL,
    item INT NOT NULL,
    cod_parte VARCHAR(30) NOT NULL,
    cantidad_rechazada INT NOT NULL CHECK (cantidad_rechazada > 0),
    motivo_especifico_item VARCHAR(255) NOT NULL,
    PRIMARY KEY (dictamen_num, item),
    CONSTRAINT fk_detrec_dictamen FOREIGN KEY (dictamen_num) 
        REFERENCES dictamen_rechazo(dictamen_num) ON DELETE CASCADE,
    CONSTRAINT fk_detrec_repuesto FOREIGN KEY (cod_parte) 
        REFERENCES repuesto(cod_parte) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- 8. TABLA: HERRAMIENTA
CREATE TABLE herramienta (
    cod_herramienta VARCHAR(30) PRIMARY KEY,
    nombre_herramienta VARCHAR(150) NOT NULL,
    marca_herramienta VARCHAR(50) NOT NULL,
    categoria VARCHAR(30) NOT NULL CHECK (categoria IN ('Electricas', 'Hidraulicas', 'Neumaticas', 'Manuales')),
    estado_actual VARCHAR(30) NOT NULL CHECK (estado_actual IN ('Disponible', 'Prestada', 'En Mora', 'En Mantenimiento', 'Extraviada', 'Baja Tecnica'))
);

-- 9. TABLAS: PRESTAMO Y PRESTAMO_DETALLE
CREATE TABLE prestamo (
    prestamo_num VARCHAR(20) PRIMARY KEY,
    fecha_prestamo DATE NOT NULL,
    hora_salida TIME WITHOUT TIME ZONE NOT NULL,
    dni_almacenista VARCHAR(8) NOT NULL,
    dni_mecanico VARCHAR(8) NOT NULL,
    estado_prestamo VARCHAR(20) NOT NULL DEFAULT 'ACTIVO' CHECK (estado_prestamo IN ('ACTIVO', 'CERRADO', 'MORA')),
    CONSTRAINT fk_prestamo_almacenista FOREIGN KEY (dni_almacenista) 
        REFERENCES almacenista(dni_almacenista) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_prestamo_mecanico FOREIGN KEY (dni_mecanico) 
        REFERENCES mecanico(dni_mecanico) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE prestamo_detalle (
    prestamo_num VARCHAR(20) NOT NULL,
    item INT NOT NULL,
    cod_herramienta VARCHAR(30) NOT NULL,
    nombre_herramienta VARCHAR(150) NOT NULL,
    estado_herramienta VARCHAR(50) NOT NULL,
    hora_retorno TIME WITHOUT TIME ZONE,
    firma_mecanico TEXT NOT NULL,
    PRIMARY KEY (prestamo_num, item),
    CONSTRAINT fk_presdet_prestamo FOREIGN KEY (prestamo_num) 
        REFERENCES prestamo(prestamo_num) ON DELETE CASCADE,
    CONSTRAINT fk_presdet_herramienta FOREIGN KEY (cod_herramienta) 
        REFERENCES herramienta(cod_herramienta) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- 10. TABLAS: DEVOLUCION Y DEVOLUCION_DETALLE
CREATE TABLE devolucion (
    devolucion_num VARCHAR(20) PRIMARY KEY,
    fecha_devolucion DATE NOT NULL,
    hora_retorno TIME WITHOUT TIME ZONE NOT NULL,
    detalle_incidencia TEXT,
    prestamo_num VARCHAR(20) NOT NULL,
    dni_almacenista VARCHAR(8) NOT NULL,
    dni_mecanico VARCHAR(8) NOT NULL,
    CONSTRAINT fk_devolucion_prestamo FOREIGN KEY (prestamo_num) 
        REFERENCES prestamo(prestamo_num) ON DELETE RESTRICT,
    CONSTRAINT fk_devolucion_almacenista FOREIGN KEY (dni_almacenista) 
        REFERENCES almacenista(dni_almacenista) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_devolucion_mecanico FOREIGN KEY (dni_mecanico) 
        REFERENCES mecanico(dni_mecanico) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE devolucion_detalle (
    devolucion_num VARCHAR(20) NOT NULL,
    item INT NOT NULL,
    cod_herramienta VARCHAR(30) NOT NULL,
    estado_herramienta VARCHAR(50) NOT NULL CHECK (estado_herramienta IN ('Buen Estado', 'Con Averia', 'Incompleta')),
    PRIMARY KEY (devolucion_num, item),
    CONSTRAINT fk_devdet_devolucion FOREIGN KEY (devolucion_num) 
        REFERENCES devolucion(devolucion_num) ON DELETE CASCADE,
    CONSTRAINT fk_devdet_herramienta FOREIGN KEY (cod_herramienta) 
        REFERENCES herramienta(cod_herramienta) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- 11. TABLAS: REGISTRO Y REGISTRO_DETALLE
CREATE TABLE registro (
    registro_num VARCHAR(20) PRIMARY KEY,
    fecha_ingreso DATE NOT NULL,
    dni_almacenista VARCHAR(8) NOT NULL,
    CONSTRAINT fk_registro_almacenista FOREIGN KEY (dni_almacenista) 
        REFERENCES almacenista(dni_almacenista) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE registro_detalle (
    registro_num VARCHAR(20) NOT NULL,
    item INT NOT NULL,
    cod_herramienta VARCHAR(30) NOT NULL,
    PRIMARY KEY (registro_num, item),
    CONSTRAINT fk_regdet_registro FOREIGN KEY (registro_num) 
        REFERENCES registro(registro_num) ON DELETE CASCADE,
    CONSTRAINT fk_regdet_herramienta FOREIGN KEY (cod_herramienta) 
        REFERENCES herramienta(cod_herramienta) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- 12. TABLA: AUDITORIA_OPERACION
CREATE TABLE auditoria_operacion (
    id_auditoria BIGSERIAL PRIMARY KEY,
    id_operacion VARCHAR(50) NOT NULL,
    id_usuario BIGINT,
    accion VARCHAR(50) NOT NULL,
    ip_origen VARCHAR(45) NOT NULL,
    timestamp TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    hash_sha256 VARCHAR(64) NOT NULL
);

-- INDICES B-TREE
CREATE INDEX idx_solicitud_mecanico ON solicitud(dni_mecanico);
CREATE INDEX idx_solicitud_estado ON solicitud(estado_solicitud);
CREATE INDEX idx_prestamo_mecanico ON prestamo(dni_mecanico);
CREATE INDEX idx_prestamo_estado ON prestamo(estado_prestamo);
CREATE INDEX idx_herramienta_categoria ON herramienta(categoria);
CREATE INDEX idx_repuesto_activo ON repuesto(activo);

-- ============================================================================
-- DATOS SEMILLA (SEEDS) INICIALES PARA PRUEBAS
-- ============================================================================

-- Usuarios base (Clave inicial generada: Admin123*, Mecanico123*, Almacen123*)
INSERT INTO usuario (dni, nombre, correo_corporativo, contrasena_hash, rol, estado_cuenta) VALUES
('75859812', 'Carlos Mendoza', 'carlos.mendoza@masterdrilling.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', 'MECANICO', 'ACTIVO'),
('45829104', 'Marcos Aurelio Ramos Quispe', 'marcos.ramos@masterdrilling.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', 'ALMACENISTA', 'ACTIVO'),
('10293847', 'Leao Chura', 'leao.chura@masterdrilling.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', 'ADMINISTRADOR', 'ACTIVO');

INSERT INTO mecanico (dni_mecanico, nombre_mecanico, especialidad_mecanico, cargo_mecanico) VALUES
('75859812', 'Carlos Mendoza', 'Hidraulica', 'Mecanico de Planta');

INSERT INTO almacenista (dni_almacenista, nombre_almacenista, sede_asignada) VALUES
('45829104', 'Marcos Aurelio Ramos Quispe', 'Taller Lurin');

INSERT INTO administrador (dni_administrador, nombre_administrador, correo_corporativo) VALUES
('10293847', 'Leao Chura', 'leao.chura@masterdrilling.com');

-- Maquinaria pesada
INSERT INTO maquinaria (cod_maquinaria, modelo_maquinaria, serie_fabricante, estado_operativo) VALUES
('MD-RB-01', 'Raise Borer Rhino 1008', 'SER-EPI-9901', 'OPERATIVA'),
('MD-RB-02', 'Master Drilling Componentes RD IV', 'SER-MD-4402', 'OPERATIVA'),
('MD-RB-03', 'Perforadora Subterranea Rhino 2002', 'SER-EPI-2002', 'EN_MANTENIMIENTO');

-- Catalogo maestro de repuestos
INSERT INTO repuesto (cod_parte, nombre_repuesto, stock_actual, stock_minimo, descripcion, activo) VALUES
('P-REX-024', 'Bomba de pistones axiales Rexroth A4VSO 125 DR', 10, 2, 'Bomba hidraulica para rotacion principal', TRUE),
('H-ESP-118', 'Manguera espiral 4SP 1 pulgada', 35, 5, 'Manguera de alta presion 400 bar', TRUE),
('F-HYD-882', 'Filtro hidraulico 10 micras', 50, 10, 'Filtro de retorno de aceite para tanque', TRUE),
('K-SEL-340', 'Kit sellos Viton alta temperatura', 25, 4, 'Sellos para cilindro elevador', TRUE),
('V-ALL-111', 'Valvula de control direccional proporcional', 12, 3, 'Modulo de mando electrohidraulico', TRUE);

-- Inventario de herramientas en panol
INSERT INTO herramienta (cod_herramienta, nombre_herramienta, marca_herramienta, categoria, estado_actual) VALUES
('HER-TOR-004', 'Torquimetro Industrial 3/4 pulgada 100-600 Nm', 'Proto', 'Manuales', 'Disponible'),
('HER-PIST-003', 'Pistola de impacto neumatica 1 pulgada', 'Chicago Pneumatic', 'Neumaticas', 'Disponible'),
('HER-BOM-008', 'Bomba hidraulica manual 700 bar', 'Enerpac', 'Hidraulicas', 'Disponible'),
('HER-MAN-022', 'Manometro digital de presion diferencial', 'Wika', 'Manuales', 'Disponible'),
('HER-LLAV-015', 'Juego de llaves combinadas milimetricas 6-32mm', 'Stanley FatMax', 'Manuales', 'Disponible');