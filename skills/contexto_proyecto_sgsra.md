# CONTEXTO MAESTRO DEL PROYECTO: SGSRA-MD (Master Drilling Perú S.A.)

> **System Prompt / Regla Base para el Asistente de IA:**
> Actúa como un Arquitecto de Software Senior Full-Stack experto en **Java 21 (Spring Boot 3.x / 4.x)**, **Flutter 3.x (Dart / BLoC / Clean Architecture)**, **PostgreSQL 16+ - 18** y **Despliegue Cloud 24/7 en Oracle Cloud Infrastructure (OCI)**. Todo el código que generes debe integrarse de manera estricta con este contexto, respetando las rutas reales del repositorio, nombres de tablas, convenciones de API, reglas de negocio y entregables de producción definidos a continuación. **No uses placeholders, código simulado ni mocks falsos en lógica de negocio; entrega código completo, limpio y funcional listo para compilar en APK Android y backend REST.**

---

## 1. Resumen Ejecutivo y Propósito del Producto

- **Nombre del Sistema:** SGSRA-MD (_Sistema de Gestión de Solicitudes de Repuestos para Maquinarias Pesadas y Control de Almacén de Herramientas_).
- **Cliente / Empresa:** Master Drilling Perú S.A. (Operaciones de perforación minera subterránea / Raise Boring). Enfoque operacional: taller de mantenimiento electromecánico y pañol de herramientas.
- **Repositorio Oficial:** `https://github.com/JeanpierJY/sgsra-md-backend` (Rama activa de desarrollo: `SG_rama`; ramas históricas: `main`, `Backend-Spring-Boot`, `Modules-Roles`).
- **Problema que Resuelve:** Elimina la fricción operativa, demoras, suplantaciones de identidad y pérdidas críticas (18% anual) causadas por el uso de formatos físicos en papel (`FOR-MNT-012`, `FOR-ADM-004`, `FOR-ALM-015`, cuadernos de pañol) para solicitar repuestos de maquinaria pesada y controlar el préstamo/devolución de herramientas calibradas en taller y socavón.
- **Objetivo Actual de Desarrollo:** Consolidación final del producto con empaquetado **APK Release Android** para dispositivos móviles de taller y despliegue del backend y base de datos en la nube **24/7 en Oracle Cloud Infrastructure (OCI Always Free)**, permitiendo conectividad ubicua (WiFi y datos móviles) sin depender de IPs locales ni configuraciones de firewall de laptop.

---

## 2. Stack Tecnológico y Estructura del Repositorio

### 2.1 Backend (`sgsra-md/`)

- **Lenguaje & Plataforma:** Java 21 LTS (OpenJDK 21).
- **Framework Base:** Spring Boot 3.x / Starter Parent `4.1.2`:
  - `spring-boot-starter-webmvc`: Controladores REST, interceptores y serialización Jackson.
  - `spring-boot-starter-data-jpa`: Capa de persistencia ORM con Hibernate.
  - `spring-boot-starter-security`: Filtros de seguridad, cifrado BCrypt y autorización.
  - `spring-boot-starter-validation`: Validación declarativa (`@Valid`, `@NotNull`, `@Min`, etc.).
- **Base de Datos:** PostgreSQL 16+ - 18 (Relacional ACID en 3FN), conector oficial `org.postgresql:postgresql` (runtime).
- **Criptografía & Seguridad:**
  - Contraseñas hasheadas mediante `BCryptPasswordEncoder` (`PasswordEncoderConfig.java`).
  - Auditoría inalterable (_Append-Only_) sellada criptográficamente con **SHA-256** (`HashUtil.java`).
  - Bloqueo escalonado de cuentas por intentos fallidos (5 min, 15 min y bloqueo total) con fecha/hora en `bloqueado_hasta`.
- **Librerías Clave (`pom.xml`):**
  - **Lombok:** Eliminación de boilerplate (`@Getter`, `@Setter`, `@Builder`, `@RequiredArgsConstructor`).
  - **Apache POI 5.2.5 (`poi-ooxml`):** Generación y exportación de reportes analíticos en formato Excel nativo (`.xlsx`).
  - **Google Guava 33.1.0-jre:** Utilidades funcionales, colecciones inmutables y validaciones.
  - **Apache Commons Lang3 (`commons-lang3`):** Sanitización de entradas, prevención de inyecciones y manipulación segura de strings.
  - **SpringDoc OpenAPI 2.8.5 (`springdoc-openapi-starter-webmvc-ui`):** Documentación viva Swagger UI en `/swagger-ui.html` y especificación OpenAPI 3.0 en `/v3/api-docs`.
- **Almacenamiento Local / Archivos:** `LocalStorageServiceImpl` con soporte multipart hasta 5 MB (`spring.servlet.multipart.max-file-size=5MB`) y exposición web de recursos estáticos bajo `/uploads/**`.
- **Estructura de Paquetes Java (`com.masterdrilling.sgsramd`):**
  - `config/`: `PasswordEncoderConfig`, `WebMvcResourceConfig`, `SwaggerConfig`, `TareasProgramadasConfig`.
  - `controller/`: `AutenticacionController`, `CatalogoController`, `SolicitudController`, `InventarioController`, `PrestamoController`, `ReporteController`, `AuditoriaController`, `NotificacionController`, `MaquinariaController`, `UsuarioController`.
  - `service/` & `service/impl/`: `AutenticacionServiceImpl`, `CatalogoServiceImpl`, `SolicitudServiceImpl`, `InventarioServiceImpl`, `PrestamoServiceImpl`, `ReporteServiceImpl`, `AuditoriaServiceImpl`, `NotificacionServiceImpl`, `LocalStorageServiceImpl`, `PrestamoVencimientoService`, `FirebaseNotificacionServiceImpl`.
  - `DAO/`: `Usuario_DAO`, `Mecanico_DAO`, `Almacenista_DAO`, `Administrador_DAO`, `Repuesto_DAO`, `Maquinaria_DAO`, `Solicitud_DAO`, `SolicitudDetalle_DAO`, `Herramienta_DAO`, `Prestamo_DAO`, `PrestamoDetalle_DAO`, `Devolucion_DAO`, `DevolucionDetalle_DAO`, `AuditoriaOperacion_DAO`, `Notificacion_DAO`, `SolicitudRecuperacionClave_DAO`, `DictamenRechazo_DAO`, `DetalleRechazo_DAO`.
  - `model/entity/`: `Usuario`, `Mecanico`, `Almacenista`, `Administrador`, `Repuesto`, `Maquinaria`, `Solicitud`, `SolicitudDetalle`, `DictamenRechazo`, `DetalleRechazo`, `Herramienta`, `Prestamo`, `PrestamoDetalle`, `Devolucion`, `DevolucionDetalle`, `AuditoriaOperacion`, `Notificacion`, `SolicitudRecuperacionClave`, `Registro`, `RegistroDetalle`.
  - `model/enums/`: `RolUsuario`, `EstadoCuenta`, `EstadoSolicitud`, `PrioridadSolicitud`, `EstadoHerramienta`, `CategoriaHerramienta`, `EstadoPrestamo`, `EstadoRecuperacion`.
  - `dto/request/` & `dto/response/`: DTOs fuertemente tipados para todas las transacciones.
  - `exception/`: `GlobalExceptionHandler` con `@RestControllerAdvice` y respuestas `MensajeGenericoResponse`.

### 2.2 Frontend Móvil (`sgsra_mobile/`)

- **Framework & SDK:** Flutter 3.x / Dart (SDK: `>=3.4.0 <4.0.0`).
- **Arquitectura de Software:** Clean Architecture desacoplada (`data/`, `domain/`, `presentation/`) con patrón **BLoC (`flutter_bloc: ^8.1.6`)** para gestión reactiva de estado.
- **Cliente HTTP & Persistencia Segura:**
  - `dio: ^5.5.0`: Cliente HTTP con interceptores de autenticación y manejo de errores.
  - `flutter_secure_storage: ^9.2.2`: Almacenamiento seguro en Android KeyStore para credenciales biométricas, DNI y host personalizado.
  - `sqflite: ^2.3.0` & `sqflite_sqlcipher: ^3.2.0+1`: Base de datos SQLite local para modo offline en socavón.
- **Sensores Nativos y Hardware:**
  - `mobile_scanner: ^5.1.1`: Escaneo óptico ultrarrápido de códigos QR y barras en taller.
  - `local_auth: ^2.1.8`: Autenticación biométrica con huella dactilar.
  - `image_picker: ^1.1.2`: Captura con cámara frontal (selfie de recuperación) y trasera (fotos de piezas).
  - `path_provider: ^2.1.4` + `open_filex: ^4.5.0`: Guardado y apertura automática de archivos Excel/CSV nativos en Android.
  - `connectivity_plus: ^6.0.3`: Monitoreo de conectividad a la red.
- **Integración Nativa Android (Kotlin):**
  - `MainActivity.kt` con canal `MethodChannel("com.example.sgsra_mobile/telefono")` para invocar `Intent.ACTION_DIAL`, abriendo el marcador telefónico nativo con el número prellenado automáticamente.
- **Recursos Multimedia y Assets Nativos (`pubspec.yaml`):**
  - `assets/images/`: `logo_master_drilling.png`, `isotipo_md.png`, `avatar_placeholder.png`, `empty_box.png`, `ic_launcher.png`.
  - `assets/images/repuestos/`: Fotografías oficiales de catálogo de repuestos (`P-CAT-330.png`, `P-REX-024.png`, etc.).
  - `assets/images/herramientas/`: Fotografías oficiales de herramientas de pañol (`HER-ENE-008.png`, `HER-TOR-004.png`, etc.).
  - Ícono oficial de la aplicación Android configurado en `android/app/src/main/res/mipmap-*/ic_launcher.png`.
  - Fallback offline inteligente en `ImagenProducto`: intenta URL de red $\rightarrow$ recurre a imagen empaquetada en assets $\rightarrow$ fallback final a ícono vectorial corporativo.

---

## 3. Roles del Sistema y Navegación (`HomeRouter`)

El enrutador principal (`home_router.dart`) dirige al usuario según su rol de cuenta, manteniendo una barra superior unificada con avatar de acceso a perfil (`PerfilBoton`) y campana de alertas (`NotificacionBell`):

### 1. `MECANICO` (`MecanicoMainScreen` - 4 Pestañas Inferiores + Mi Perfil en AppBar)
- **Catálogo (`catalogo_screen.dart`):** Catálogo maestro con fotos, buscador predictivo y ficha modal ampliable (`detalle_repuesto_modal.dart`).
- **Solicitudes (`carrito_pedido_screen.dart`):** Carrito digital de repuestos, selector predictivo de maquinaria (`MEC-05`), selección de prioridad (`BAJA`, `MEDIA`, `ALTA`) y justificación técnica.
- **Historial (`historial_solicitudes_screen.dart`):** Historial personal cronológico de pedidos con filtros por estado (`PENDIENTE`, `APROBADA`, `APROBADA_PARCIAL`, `RECHAZADA`, `ENTREGADA`) y detalle de dictamen de rechazo.
- **Herramientas (`herramientas_prestadas_screen.dart`):** Gestión de herramientas en custodia organizada en **3 pestañas operativas**:
  1. *En curso:* Préstamos activos y vigentes en poder del mecánico.
  2. *Retraso/Alerta:* Préstamos en estado `MORA` o con herramientas reportadas como extraviadas.
  3. *Devueltas:* Historial de préstamos concluidos y retornados a pañol con ficha antes/después.

### 2. `ADMINISTRADOR` (`AdminMainScreen` - 5 Pestañas Inferiores + Mi Perfil en AppBar)
- **Bandeja (`bandeja_solicitudes_screen.dart`):** Bandeja unificada ordenada por FIFO, filtros temporales, contadores en tiempo real y modal de **aprobación parcial ítem por ítem (`RF26`)** con motivo obligatorio si hay rechazos.
- **Auditoría (`auditoria_screen.dart`):** Bitácora inalterable conectada a PostgreSQL con sellado `SHA-256`, agrupada cronológicamente con filtros avanzados por usuario, acción y fechas.
- **Catálogo (`mantenimiento_catalogo_screen.dart`):** Gestión CRUD de repuestos, stock mínimo/actual, carga fotográfica y botón superior para consultar **Proveedores Homologados [RF27]** con redirección directa a llamadas telefónicas.
- **Reportes (`reportes_analiticos_screen.dart`):** Métricas consolidadas de demanda, gráficos reactivos y exportación directa a Excel (`.xlsx`) y CSV compatible con Android.
- **Personal (`gestion_personal_screen.dart`):** Búsqueda de usuarios, activación/bloqueo de cuentas, reseteo de contraseñas y pantalla de atención de solicitudes de recuperación de clave con cotejo de selfie vs perfil.

### 3. `ALMACENISTA` (`AlmacenMainScreen` - 4 Pestañas Inferiores + Mi Perfil en AppBar)
- **Dashboard (`dashboard_almacen_screen.dart`):** Indicadores en tiempo real de pañol (Disponibles, Prestadas, En Mora, Mantenimiento, Extraviadas) seguido de la sección **Repuestos Aprobados para Retiro Físico** y el **Control de Préstamos Activos**.
- **Despacho (`despacho_screen.dart`):** Doble salida operativa dividida en:
  1. *Repuestos:* Entrega formal de solicitudes aprobadas con verificación de stock y cambio a estado `ENTREGADA`.
  2. *Herramientas:* Salida formal de pañol por DNI con buscador simétrico de mecánicos y herramientas.
- **Retorno (`retorno_qr_screen.dart`):** Escáner óptico QR con cámara trasera, buscador predictivo y modal interactivo de inspección física (`BUEN_ESTADO`, `CON_AVERIA`, `INCOMPLETA`) con ficha antes/después.
- **Herramientas (`registrar_herramienta_screen.dart`):** Catálogo de herramientas con buscador predictivo, filtros por categoría/estado, botón flotante de alta y botón flotante de **Reporte de Extravío [RF41]** que abre modal con buscador exclusivo de herramientas extraviadas e imputación al último custodio.

---

## 4. Modelo de Datos Físico Consolidado (PostgreSQL 16+ - 18)

Esquema relacional en Tercera Forma Normal (3FN) con integridad referencial completa y soporte para auditoría, notificaciones y recuperación de contraseñas:

```sql
-- ============================================================================
-- 1. TABLA MAESTRA DE USUARIOS Y CONTROL DE ACCESO
-- ============================================================================
CREATE TABLE usuario (
    id_usuario BIGSERIAL PRIMARY KEY,
    dni VARCHAR(8) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    correo_corporativo VARCHAR(100) UNIQUE NOT NULL,
    contrasena_hash VARCHAR(255) NOT NULL,
    rol VARCHAR(20) NOT NULL CHECK (rol IN ('MECANICO', 'ALMACENISTA', 'ADMINISTRADOR')),
    estado_cuenta VARCHAR(20) NOT NULL DEFAULT 'ACTIVO', -- ACTIVO, BLOQUEADO, INACTIVO
    intentos_fallidos INT NOT NULL DEFAULT 0,
    bloqueado_hasta TIMESTAMP,
    foto_perfil_url VARCHAR(255),
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 2. TABLAS DE ESPECIALIZACIÓN POR ROL
-- ============================================================================
CREATE TABLE mecanico (
    dni_mecanico VARCHAR(8) PRIMARY KEY REFERENCES usuario(dni) ON DELETE CASCADE,
    nombre_mecanico VARCHAR(100) NOT NULL,
    especialidad_mecanico VARCHAR(50) NOT NULL,
    cargo_mecanico VARCHAR(50) NOT NULL,
    telefono VARCHAR(15)
);

CREATE TABLE almacenista (
    dni_almacenista VARCHAR(8) PRIMARY KEY REFERENCES usuario(dni) ON DELETE CASCADE,
    nombre_almacenista VARCHAR(100) NOT NULL,
    sede_asignada VARCHAR(50) NOT NULL,
    telefono VARCHAR(9)
);

CREATE TABLE administrador (
    dni_administrador VARCHAR(8) PRIMARY KEY REFERENCES usuario(dni) ON DELETE CASCADE,
    nombre_administrador VARCHAR(100) NOT NULL,
    correo_corporativo VARCHAR(100) NOT NULL
);

-- ============================================================================
-- 3. CATÁLOGO DE REPUESTOS Y MAQUINARIA
-- ============================================================================
CREATE TABLE repuesto (
    cod_parte VARCHAR(30) PRIMARY KEY,
    nombre_repuesto VARCHAR(150) NOT NULL,
    stock_actual INT NOT NULL CHECK (stock_actual >= 0),
    stock_minimo INT NOT NULL CHECK (stock_minimo >= 0),
    descripcion TEXT,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    imagen_url VARCHAR(255)
);

CREATE TABLE maquinaria (
    cod_maquinaria VARCHAR(20) PRIMARY KEY,
    modelo_maquinaria VARCHAR(100) NOT NULL,
    serie_fabricante VARCHAR(50),
    estado_operativo VARCHAR(20) NOT NULL CHECK (estado_operativo IN ('OPERATIVA', 'EN_MANTENIMIENTO', 'INOPERATIVA', 'BAJA'))
);

-- ============================================================================
-- 4. FLUJO DE SOLICITUDES Y EVALUACIÓN
-- ============================================================================
CREATE TABLE solicitud (
    solicitud_num VARCHAR(20) PRIMARY KEY, -- Formato: SOL-2026-XXXX
    fecha_emision DATE NOT NULL,
    hora_emision TIME WITHOUT TIME ZONE NOT NULL,
    prioridad_solicitud VARCHAR(20) NOT NULL CHECK (prioridad_solicitud IN ('BAJA', 'MEDIA', 'ALTA')),
    justificacion_tecnica TEXT NOT NULL,
    estado_solicitud VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE', -- PENDIENTE, APROBADA, APROBADA_PARCIAL, RECHAZADA, ENTREGADA
    dni_mecanico VARCHAR(8) NOT NULL REFERENCES mecanico(dni_mecanico),
    cod_maquina VARCHAR(20) NOT NULL REFERENCES maquinaria(cod_maquinaria)
);

CREATE TABLE solicitud_detalle (
    solicitud_num VARCHAR(20) NOT NULL REFERENCES solicitud(solicitud_num) ON DELETE CASCADE,
    item INT NOT NULL,
    cantidad_repuesto INT NOT NULL CHECK (cantidad_repuesto > 0),
    estado_item VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE', -- PENDIENTE, APROBADO, RECHAZADO
    motivo_rechazo_item TEXT,
    cod_parte VARCHAR(30) NOT NULL REFERENCES repuesto(cod_parte),
    PRIMARY KEY (solicitud_num, item)
);

CREATE TABLE dictamen_rechazo (
    dictamen_num VARCHAR(20) PRIMARY KEY,
    ref_solicitud_num VARCHAR(20) NOT NULL REFERENCES solicitud(solicitud_num),
    fecha_evaluacion DATE NOT NULL,
    justificacion_rechazo TEXT NOT NULL,
    dni_administrador VARCHAR(8) NOT NULL REFERENCES administrador(dni_administrador)
);

CREATE TABLE detalle_rechazo (
    dictamen_num VARCHAR(20) NOT NULL REFERENCES dictamen_rechazo(dictamen_num) ON DELETE CASCADE,
    item INT NOT NULL,
    motivo_rechazo TEXT NOT NULL,
    cod_parte VARCHAR(30) NOT NULL REFERENCES repuesto(cod_parte),
    PRIMARY KEY (dictamen_num, item)
);

-- ============================================================================
-- 5. PAÑOL DE HERRAMIENTAS, PRÉSTAMOS Y DEVOLUCIONES
-- ============================================================================
CREATE TABLE herramienta (
    cod_herramienta VARCHAR(30) PRIMARY KEY, -- Ej: HER-TOR-004
    nombre_herramienta VARCHAR(150) NOT NULL,
    marca_herramienta VARCHAR(50) NOT NULL,
    categoria VARCHAR(30) NOT NULL, -- Manuales, Hidraulicas, Neumaticas, Electricas
    estado_actual VARCHAR(30) NOT NULL, -- Disponible, Prestada, En Mora, En Mantenimiento, Extraviada
    imagen_url VARCHAR(255)
);

CREATE TABLE prestamo (
    prestamo_num VARCHAR(20) PRIMARY KEY,
    fecha_prestamo DATE NOT NULL,
    hora_salida TIME WITHOUT TIME ZONE NOT NULL,
    estado_prestamo VARCHAR(20) NOT NULL DEFAULT 'ACTIVO', -- ACTIVO, MORA, CERRADO
    dni_almacenista VARCHAR(8) NOT NULL REFERENCES almacenista(dni_almacenista),
    dni_mecanico VARCHAR(8) NOT NULL REFERENCES mecanico(dni_mecanico),
    aviso_preventivo_enviado BOOLEAN DEFAULT FALSE
);

CREATE TABLE prestamo_detalle (
    prestamo_num VARCHAR(20) NOT NULL REFERENCES prestamo(prestamo_num) ON DELETE CASCADE,
    item INT NOT NULL,
    nombre_herramienta VARCHAR(150) NOT NULL,
    estado_herramienta VARCHAR(50) NOT NULL,
    hora_retorno TIME WITHOUT TIME ZONE,
    firma_mecanico TEXT NOT NULL,
    cod_herramienta VARCHAR(30) NOT NULL REFERENCES herramienta(cod_herramienta),
    PRIMARY KEY (prestamo_num, item)
);

CREATE TABLE devolucion (
    devolucion_num VARCHAR(20) PRIMARY KEY,
    fecha_devolucion DATE NOT NULL,
    hora_retorno TIME WITHOUT TIME ZONE NOT NULL,
    detalle_incidencia TEXT,
    prestamo_num VARCHAR(20) NOT NULL REFERENCES prestamo(prestamo_num),
    dni_almacenista VARCHAR(8) NOT NULL REFERENCES almacenista(dni_almacenista),
    dni_mecanico VARCHAR(8) NOT NULL REFERENCES mecanico(dni_mecanico)
);

CREATE TABLE devolucion_detalle (
    devolucion_num VARCHAR(20) NOT NULL REFERENCES devolucion(devolucion_num) ON DELETE CASCADE,
    item INT NOT NULL,
    nombre_herramienta VARCHAR(150) NOT NULL,
    estado_herramienta VARCHAR(50) NOT NULL, -- BUEN_ESTADO, CON_AVERIA, INCOMPLETA
    hora_retorno TIME WITHOUT TIME ZONE NOT NULL,
    firma_almacenista TEXT NOT NULL,
    cod_herramienta VARCHAR(30) NOT NULL REFERENCES herramienta(cod_herramienta),
    PRIMARY KEY (devolucion_num, item)
);

-- ============================================================================
-- 6. RECUPERACIÓN DE CONTRASEÑAS, AUDITORÍA Y NOTIFICACIONES
-- ============================================================================
CREATE TABLE solicitud_recuperacion_clave (
    id_recuperacion BIGSERIAL PRIMARY KEY,
    dni_solicitante VARCHAR(8) NOT NULL,
    nombre_solicitante VARCHAR(100) NOT NULL,
    correo_solicitante VARCHAR(100) NOT NULL,
    rol_solicitante VARCHAR(20) NOT NULL,
    motivo TEXT,
    estado VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE', -- PENDIENTE, APROBADA, RECHAZADA
    fecha_solicitud TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_resolucion TIMESTAMP,
    dni_administrador VARCHAR(8),
    observacion_admin TEXT,
    foto_selfie_url VARCHAR(255)
);

CREATE TABLE auditoria_operacion (
    id_auditoria BIGSERIAL PRIMARY KEY,
    id_operacion VARCHAR(50) NOT NULL,
    id_usuario BIGINT,
    accion VARCHAR(50) NOT NULL,
    detalle TEXT,
    ip_origen VARCHAR(45) NOT NULL,
    timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    hash_sha256 VARCHAR(64) NOT NULL
);

CREATE TABLE notificacion (
    id_notificacion BIGSERIAL PRIMARY KEY,
    dni_destinatario VARCHAR(8),
    rol_destinatario VARCHAR(20), -- MECANICO, ALMACENISTA, ADMINISTRADOR
    titulo VARCHAR(120) NOT NULL,
    mensaje TEXT NOT NULL,
    tipo_alerta VARCHAR(30) NOT NULL, -- NUEVA_SOLICITUD, DICTAMEN, MORA, EXTRAVIO, DESBLOQUEO, STOCK_MINIMO
    referencia_id VARCHAR(30),
    leida BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 7. VISTA ANALÍTICA CONSOLIDADA
-- ============================================================================
CREATE OR REPLACE VIEW v_solicitud_metricas AS
SELECT s.solicitud_num, s.fecha_emision, s.estado_solicitud,
       COUNT(sd.item) AS total_items,
       COALESCE(SUM(sd.cantidad_repuesto), 0) AS total_unidades
FROM solicitud s
LEFT JOIN solicitud_detalle sd ON s.solicitud_num = sd.solicitud_num
GROUP BY s.solicitud_num, s.fecha_emision, s.estado_solicitud;
```

---

## 5. Catálogo de Requerimientos Funcionales (RF01 - RF50) y Reglas de Negocio

### Módulo 1: Seguridad, Usuarios y Perfiles (`RF01 - RF08`)
- **RF01:** Inicio de sesión con correo corporativo (`@masterdrilling.com`) y contraseña hasheada en BCrypt.
- **RF02:** Asignación automática de vistas según rol mediante `HomeRouter`.
- **RF03:** Cierre de sesión seguro purgando llaves en `FlutterSecureStorage`.
- **RF04:** Solicitud de desbloqueo / recuperación de contraseña hacia Administración con evidencia fotográfica selfie en vivo (`CameraDevice.front`).
- **RF05:** Acceso rápido mediante biometría dactilar (`local_auth`) con prellenado de último correo y token seguro en Keystore.
- **RF06:** **Bloqueo escalonado por intentos fallidos:**
  - 3 fallos consecutivos $\rightarrow$ Bloqueo temporal por 5 minutos.
  - 6 fallos consecutivos $\rightarrow$ Bloqueo temporal por 15 minutos.
  - 9 fallos consecutivos $\rightarrow$ **Bloqueo total (`BLOQUEADO`)**, requiriendo atención formal del Administrador.
- **RF07:** Edición de perfil básico: DNI, Nombres y Correo en modo solo lectura; permite actualizar únicamente el teléfono (9 dígitos) y contraseña personal.
- **RF08:** Gestión de personal: Búsqueda dinámica, activación/bloqueo de cuentas, reseteo de claves y revisión de selfies.
  - **REGLA CRÍTICA DE JERARQUÍA:** Un Administrador no puede suspender, alterar ni resetear a otro Administrador (retorna `HTTP 403 Forbidden`).

### Módulo 2: Catálogo y Solicitudes del Mecánico (`RF09 - RF20`)
- **RF09 - RF12:** Catálogo maestro paginado con fotos reales (`imagen_url`), buscador predictivo en tiempo real y modal de ficha técnica con fallback offline.
- **RF13 - RF16:** Carrito digital con selector predictivo de maquinaria pesada (`MD-RB-01`), selector de cantidad, nivel de prioridad (`BAJA`, `MEDIA`, `ALTA`) y justificación técnica ($\ge 10$ caracteres).
- **RF17:** Transmisión formal con generación de correlativo `SOL-2026-XXXX` en estado `PENDIENTE`.
- **RF18:** Modo Offline: Almacenamiento local en SQLite cifrado ante pérdida de señal en socavón.
- **RF19 - RF20:** Historial personal de solicitudes con badges cromáticos (`Amarillo`: Pendiente, `Verde`: Aprobada, `Naranja`: Aprobada Parcial, `Rojo`: Rechazada, `Azul`: Entregada).

### Módulo 3: Administración, Aprobaciones y Auditoría (`RF21 - RF32`)
- **RF21 - RF22:** Bandeja unificada ordenada por FIFO con filtros temporales (30 a 180 días) y contadores dinámicos.
- **RF23 - RF25:** Aprobación total inmediata o rechazo total con justificación técnica obligatoria ($\ge 15$ caracteres).
- **RF26:** **Aprobación parcial de componentes:** Evaluación ítem por ítem con validación de stock en vivo, pasando la orden a `APROBADA_PARCIAL`.
- **RF27:** Directorio de proveedores homologados (Bosch Rexroth, Enerpac, Parker, Donaldson, Festo) con botón de llamada nativa por `MethodChannel` (`Intent.ACTION_DIAL`).
- **RF28:** *(Descartado del alcance por ser gestión administrativa externa de compras)*.
- **RF29 - RF30:** Reportes analíticos con gráficos interactivos y exportación nativa a **Excel (`.xlsx`) y CSV** compatible con Android.
- **RF31:** Bitácora de auditoría histórica con filtros por rango de fechas, usuario/DNI y acción.
- **RF32:** CRUD de repuestos con carga fotográfica multipart (`< 5MB`).

### Módulo 4: Almacén / Pañol de Herramientas (`RF33 - RF45`)
- **RF33:** Dashboard de pañol con stock en tiempo real (Disponibles, Prestadas, En Mora, Mantenimiento, Extraviadas) con Repuestos Aprobados antes de Préstamos.
- **RF34 - RF35:** Escáner óptico QR con cámara trasera y despliegue instantáneo de ficha técnica del activo.
- **RF36 - RF37:** Salida formal de herramientas validando cupo máximo ($\le 5$ herramientas y 0 moras), capturando firma digital.
- **RF38 - RF40:** Recepción e inspección física de devolución (`BUEN_ESTADO` $\rightarrow$ Disponible, `CON_AVERIA` / `INCOMPLETA` $\rightarrow$ En Mantenimiento) con visualización antes/después (`PRE-01`).
- **RF41 - RF42:** Reporte de extravío de herramientas con buscador predictivo exclusivo de activos perdidos e imputación de responsabilidad al último custodio.
- **RF43:** Alerta visual destacada en rojo/ámbar para préstamos y herramientas en estado `MORA`.
- **RF44 - RF45:** Alta de herramientas por categoría (`Manuales`, `Hidráulicas`, `Neumáticas`, `Eléctricas`) con fotografía obligatoria.
- **Flujo de Despacho de Repuestos:** Entrega física de repuestos de solicitudes aprobadas, pasando a estado `ENTREGADA` y descontando el inventario físico en tiempo real.

### Módulo 5: Notificaciones Internas y Auditoría (`RF46 - RF50`)
- **RF46 - RF48:** Sistema de notificaciones persistidas en PostgreSQL (tabla `notificacion`) para solicitudes, dictámenes, moras, extravíos y stock mínimo.
- **RF49:** Registro inmutable de auditoría con hash SHA-256 e IP de origen.
- **RF50:** Centro de notificaciones universal con campana y badge numérico en AppBar en los 3 roles.

---

## 6. Arquitectura de Despliegue Cloud: Oracle Cloud Infrastructure (OCI Always Free 24/7)

Para garantizar la disponibilidad continua del sistema sin depender de redes locales ni computadoras portátiles:

```
┌────────────────────────────────────────────────────────────────────────┐
│                        ORACLE CLOUD (OCI Always Free)                  │
│                                                                        │
│   IP Pública Estática (Fija): 140.238.x.x                              │
│   Security List / Ingress Rules: TCP 8080 (API), TCP 5432 (Postgres)   │
│                                                                        │
│   ┌──────────────────────────────────────────────────────────────┐    │
│   │                      Instancia VM Compute                    │    │
│   │               Ubuntu 22.04 / 24.04 LTS (Ampere ARM / AMD)     │    │
│   │                                                              │    │
│   │   ┌────────────────────────┐      ┌──────────────────────┐   │    │
│   │   │ Spring Boot 3.x (Java) │◄────►│    PostgreSQL 16/18  │   │    │
│   │   │ Puerto: 8080 (REST)    │      │    Puerto: 5432      │   │    │
│   │   └───────────┬────────────┘      └──────────────────────┘   │    │
│   │               │                                              │    │
│   │               ▼                                              │    │
│   │   ┌────────────────────────┐                                 │    │
│   │   │ Storage ./uploads/     │                                 │    │
│   │   │ (Fotos / Selfies)      │                                 │    │
│   │   └────────────────────────┘                                 │    │
│   └──────────────────────────────────────────────────────────────┘    │
└───────────────────────────────────▲────────────────────────────────────┘
                                    │ HTTPS / HTTP REST API
                                    │ (Puerto 8080)
            ┌───────────────────────┴───────────────────────┐
            │                                               │
     📱 Celular Mecánico                     📱 Celular Almacén / Admin
   (App SGSRA-MD Release APK)               (App SGSRA-MD Release APK)
    Red WiFi / Datos 4G/5G                   Red WiFi / Datos 4G/5G
```

---

## 7. Checklist Maestro de Ejecución del Proyecto

- [x] **Fase 1: PostgreSQL & Backend Core** (DDL, Hashes Spring Security, `LocalStorageServiceImpl`, subida multipart `/uploads/**`).
- [x] **Fase 2: Adaptaciones Flutter Multiplataforma** (`file_saver.dart` nativo, permisos en `AndroidManifest.xml`, `api_constants.dart`).
- [x] **Fase 2.9: Calibración Backend** (Devoluciones con avería a mantenimiento, alerta preventiva día 6, evidencia selfie en recuperación).
- [x] **Fase 3: Core Móvil & Componentes Transversales** (Centro de notificaciones `RF50`, bloqueo escalonado con selfie, `PerfilBoton` superior derecho).
- [x] **Fase 4: Flujos Operativos por Rol** (Catálogo y solicitudes de mecánico, bandeja FIFO y dictámenes de administrador, pañol ergonómico y retorno QR en almacén).
- [x] **Fase 5: Multimedia, Ajustes de Usabilidad & Integración** (Distribución de multimedia en assets y uploads, 3 pestañas en herramientas de mecánico, llamada nativa a proveedores, buscador predictivo de extraviadas en pañol).
- [ ] **Fase 6: Despliegue Cloud en Oracle Cloud Infrastructure (OCI 24/7) & Empaquetado APK Final**
  - [ ] 6.1 Provisionamiento de VM Compute en OCI Always Free con IP pública estática y PostgreSQL persistente.
  - [ ] 6.2 Configuración de reglas de ingreso (Ingress Rules) en VCN de OCI para puerto 8080.
  - [ ] 6.3 Ejecución del backend Spring Boot como servicio daemon/systemd 24/7 en la nube.
  - [ ] 6.4 Apuntamiento de IP pública en `api_constants.dart` (`API_HOST`) permitiendo conectividad desde cualquier red móvil.
  - [ ] 6.5 Compilación del APK Release optimizado (`flutter build apk --release`) para entrega final del proyecto SGSRA-MD.
