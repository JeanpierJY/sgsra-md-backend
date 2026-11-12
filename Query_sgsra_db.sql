-- ============================================================================
-- PROYECTO: SGSRA-MD (Master Drilling)
-- SCRIPT DDL: CREACION DE TABLAS, RESTRICCIONES, INDICES Y USUARIOS SEMILLA
-- COMPATIBILIDAD: PostgreSQL 16+ / PostgreSQL 18
-- Base de datos: sgsra_db
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 0. LIMPIEZA TOTAL EN ORDEN DE DEPENDENCIAS (DROP TABLES)
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS notificacion CASCADE;
DROP TABLE IF EXISTS auditoria_operacion CASCADE;
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

-- ----------------------------------------------------------------------------
-- 1. TABLA: USUARIO (Autenticacion y Control de Acceso)
-- ----------------------------------------------------------------------------
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

-- ----------------------------------------------------------------------------
-- 2. TABLAS DE ROLES ESPECIALIZADOS
-- ----------------------------------------------------------------------------
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

-- ----------------------------------------------------------------------------
-- 3. TABLA: REPUESTO (Catalogo Maestro con Soporte de Imagen y Stock)
-- ----------------------------------------------------------------------------
CREATE TABLE repuesto (
    cod_parte VARCHAR(30) PRIMARY KEY,
    nombre_repuesto VARCHAR(150) NOT NULL,
    stock_actual INT NOT NULL CHECK (stock_actual >= 0),
    stock_minimo INT NOT NULL CHECK (stock_minimo >= 0),
    descripcion TEXT,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    imagen_url VARCHAR(255)
);

-- ----------------------------------------------------------------------------
-- 4. TABLA: MAQUINARIA (Flota de Perforacion y Equipos Pesados)
-- ----------------------------------------------------------------------------
CREATE TABLE maquinaria (
    cod_maquinaria VARCHAR(20) PRIMARY KEY,
    modelo_maquinaria VARCHAR(100) NOT NULL,
    serie_fabricante VARCHAR(50),
    estado_operativo VARCHAR(20) NOT NULL CHECK (estado_operativo IN ('OPERATIVA', 'EN_MANTENIMIENTO', 'INOPERATIVA', 'BAJA'))
);

-- ----------------------------------------------------------------------------
-- 5. TABLA: SOLICITUD (Pedidos de Repuestos)
-- ----------------------------------------------------------------------------
CREATE TABLE solicitud (
    solicitud_num VARCHAR(20) PRIMARY KEY,
    fecha_emision DATE NOT NULL,
    hora_emision TIME WITHOUT TIME ZONE NOT NULL,
    prioridad_solicitud VARCHAR(20) NOT NULL CHECK (prioridad_solicitud IN ('BAJA', 'MEDIA', 'ALTA')),
    justificacion_tecnica TEXT NOT NULL,
    estado_solicitud VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE' CHECK (estado_solicitud IN ('PENDIENTE', 'APROBADA', 'APROBADA_PARCIAL', 'RECHAZADA', 'ORDEN_CONTACTADA', 'ENTREGADA')),
    dni_mecanico VARCHAR(8) NOT NULL,
    cod_maquina VARCHAR(20) NOT NULL,
    CONSTRAINT fk_solicitud_mecanico FOREIGN KEY (dni_mecanico) 
        REFERENCES mecanico(dni_mecanico) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_solicitud_maquinaria FOREIGN KEY (cod_maquina) 
        REFERENCES maquinaria(cod_maquinaria) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ----------------------------------------------------------------------------
-- 6. TABLA: SOLICITUD_DETALLE (Items y Evaluacion por Repuesto)
-- ----------------------------------------------------------------------------
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

-- ----------------------------------------------------------------------------
-- 7. TABLAS: DICTAMEN_RECHAZO Y DETALLE_RECHAZO (Sustento de Denegacion)
-- ----------------------------------------------------------------------------
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

-- ----------------------------------------------------------------------------
-- 8. TABLA: HERRAMIENTA (Panol, Estados y Soporte de Fotografia)
-- ----------------------------------------------------------------------------
CREATE TABLE herramienta (
    cod_herramienta VARCHAR(30) PRIMARY KEY,
    nombre_herramienta VARCHAR(150) NOT NULL,
    marca_herramienta VARCHAR(50) NOT NULL,
    categoria VARCHAR(30) NOT NULL CHECK (categoria IN ('Electricas', 'Hidraulicas', 'Neumaticas', 'Manuales')),
    estado_actual VARCHAR(30) NOT NULL CHECK (estado_actual IN ('Disponible', 'Prestada', 'En Mora', 'En Mantenimiento', 'Extraviada', 'Baja Tecnica')),
    imagen_url VARCHAR(255)
);

-- ----------------------------------------------------------------------------
-- 9. TABLAS: PRESTAMO Y PRESTAMO_DETALLE (Custodia en Campo)
-- ----------------------------------------------------------------------------
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

-- ----------------------------------------------------------------------------
-- 10. TABLAS: DEVOLUCION Y DEVOLUCION_DETALLE (Retorno e Inspeccion)
-- ----------------------------------------------------------------------------
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

-- ----------------------------------------------------------------------------
-- 11. TABLA: DEVOLUCION_DETALLE
-- ----------------------------------------------------------------------------
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

-- ----------------------------------------------------------------------------
-- 12. TABLAS: REGISTRO Y REGISTRO_DETALLE (Alta de Lote de Herramientas)
-- ----------------------------------------------------------------------------
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

-- ----------------------------------------------------------------------------
-- 13. TABLA: AUDITORIA_OPERACION (Trazabilidad y No Repudio)
-- ----------------------------------------------------------------------------
CREATE TABLE auditoria_operacion (
    id_auditoria BIGSERIAL PRIMARY KEY,
    id_operacion VARCHAR(50) NOT NULL,
    id_usuario BIGINT,
    accion VARCHAR(50) NOT NULL,
    ip_origen VARCHAR(45) NOT NULL,
    timestamp TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    hash_sha256 VARCHAR(64) NOT NULL
);

-- ----------------------------------------------------------------------------
-- 14. TABLA: NOTIFICACION (Alertas Reactivas del Sistema - RF46 a RF50)
-- ----------------------------------------------------------------------------
CREATE TABLE notificacion (
    id_notificacion BIGSERIAL PRIMARY KEY,
    dni_destinatario VARCHAR(8),
    rol_destinatario VARCHAR(20) CHECK (rol_destinatario IN ('MECANICO', 'ALMACENISTA', 'ADMINISTRADOR', 'TODOS')),
    titulo VARCHAR(150) NOT NULL,
    mensaje TEXT NOT NULL,
    tipo_alerta VARCHAR(30) NOT NULL DEFAULT 'INFO' CHECK (tipo_alerta IN ('INFO', 'SOLICITUD', 'APROBACION', 'RECHAZO', 'MORA', 'EXTRAVIO', 'STOCK_MINIMO')),
    leida BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_creacion TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ----------------------------------------------------------------------------
-- 15. INDICES B-TREE (Optimizacion de Consultas Frecuentes)
-- ----------------------------------------------------------------------------
CREATE INDEX idx_solicitud_mecanico ON solicitud(dni_mecanico);
CREATE INDEX idx_solicitud_estado ON solicitud(estado_solicitud);
CREATE INDEX idx_prestamo_mecanico ON prestamo(dni_mecanico);
CREATE INDEX idx_prestamo_estado ON prestamo(estado_prestamo);
CREATE INDEX idx_herramienta_categoria ON herramienta(categoria);
CREATE INDEX idx_herramienta_estado ON herramienta(estado_actual);
CREATE INDEX idx_repuesto_activo ON repuesto(activo);
CREATE INDEX idx_auditoria_timestamp ON auditoria_operacion(timestamp);
CREATE INDEX idx_notificacion_destinatario ON notificacion(dni_destinatario, leida);
CREATE INDEX idx_notificacion_rol ON notificacion(rol_destinatario, leida);

-- ============================================================================
-- 16. USUARIOS SEMILLA (Contraseñas oficiales BCrypt: admin, meca, alma)
-- ============================================================================
-- Admin:       leao.chura@masterdrilling.com    / pass: admin
-- Mecanico:    carlos.baro@masterdrilling.com   / pass: meca
-- Almacenista: marcos.baro@masterdrilling.com   / pass: alma

INSERT INTO usuario (dni, nombre, correo_corporativo, contrasena_hash, rol, estado_cuenta) VALUES
('10293847', 'Leao Chura', 'leao.chura@masterdrilling.com', '$2a$10$SETRphAwaMIowSMY05fzae15b4lzZEG9kSOOnAoinuxztQIl.4e3i', 'ADMINISTRADOR', 'ACTIVO'),
('70000001', 'Carlos Mendoza Baro', 'carlos.baro@masterdrilling.com', '$2a$10$iD7BzGlbX42.b2eXAm2Jj.yF28BJ5sxd2V2VZkqei8kRLiMo9gGpC', 'MECANICO', 'ACTIVO'),
('70000002', 'Marcos Ramos Baro', 'marcos.baro@masterdrilling.com', '$2a$10$Mhsh51WoSbSQ0Qm6f.o38.0qH3NZZZTksyMEGZCVdr3okakrwU292', 'ALMACENISTA', 'ACTIVO'),
('75859812', 'Carlos Mendoza', 'carlos.mendoza@masterdrilling.com', '$2a$10$iD7BzGlbX42.b2eXAm2Jj.yF28BJ5sxd2V2VZkqei8kRLiMo9gGpC', 'MECANICO', 'ACTIVO'),
('45829104', 'Marcos Aurelio Ramos Quispe', 'marcos.ramos@masterdrilling.com', '$2a$10$Mhsh51WoSbSQ0Qm6f.o38.0qH3NZZZTksyMEGZCVdr3okakrwU292', 'ALMACENISTA', 'ACTIVO');

INSERT INTO administrador (dni_administrador, nombre_administrador, correo_corporativo) VALUES
('10293847', 'Leao Chura', 'leao.chura@masterdrilling.com');

INSERT INTO mecanico (dni_mecanico, nombre_mecanico, especialidad_mecanico, cargo_mecanico, telefono) VALUES
('70000001', 'Carlos Mendoza Baro', 'Hidraulica', 'Mecanico de Planta', '987654321'),
('75859812', 'Carlos Mendoza', 'Electrohidraulica', 'Mecanico de Campo', '995348431');

INSERT INTO almacenista (dni_almacenista, nombre_almacenista, sede_asignada) VALUES
('70000002', 'Marcos Ramos Baro', 'Taller Lurin'),
('45829104', 'Marcos Aurelio Ramos Quispe', 'Mina Cerro Lindo');

-- ===================================================================================
-- Limpieza de las tablas usuario y roles en caso de errores sin eliminar las tablas
-- ===================================================================================
TRUNCATE TABLE usuario CASCADE;
TRUNCATE TABLE administrador CASCADE;
TRUNCATE TABLE mecanico CASCADE;
TRUNCATE TABLE almacenista CASCADE;
