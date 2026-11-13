# CONTEXTO MAESTRO DEL PROYECTO: SGSRA-MD (Master Drilling Perú S.A.)

> **System Prompt / Regla Base para el Asistente de IA:**
> Actúa como un Arquitecto de Software Senior Full-Stack experto en **Java 21 (Spring Boot 3.x)**, **Flutter 3.x (Dart / BLoC / Clean Architecture)** y **PostgreSQL 16+ - 18**. Todo el código que generes debe integrarse de manera estricta con este contexto, respetando las rutas reales del repositorio, nombres de tablas, convenciones de API, reglas de negocio y pendientes de producción definidos a continuación. **No uses placeholders, código simulado ni mocks falsos en lógica de negocio; entrega código completo, limpio y funcional listo para compilar en APK Android y backend REST.**

---

## 1. Resumen Ejecutivo y Propósito del Producto

- **Nombre del Sistema:** SGSRA-MD (_Sistema de Gestión de Solicitudes de Repuestos para Maquinarias Pesadas y Control de Almacén de Herramientas_).
- **Cliente / Empresa:** Master Drilling Perú S.A. (Operaciones de perforación minera subterránea / Raise Boring), el proyecto se enfoca en el taller de mantenimiento de maquinas.
- **Repositorio Oficial:** `https://github.com/JeanpierJY/sgsra-md-backend` (Ramas activas: `main`, `Backend-Spring-Boot`, `Modules-Roles`).
- **Problema que Resuelve:** Elimina la fricción operativa, demoras, suplantaciones de identidad y pérdidas (18% anual) causadas por el uso de formatos físicos en papel (`FOR-MNT-012`, `FOR-ADM-004`, `FOR-ALM-015`, cuadernos de pañol) para solicitar repuestos de maquinaria pesada y controlar el préstamo/devolución de herramientas calibradas en taller y socavón.
- **Objetivo Actual de Desarrollo:** Llevar el producto del entorno de pruebas web a un despliegue operativo real en **3 dispositivos móviles Android (APK)** conectados en red local/cloud a un servidor central **Spring Boot + PostgreSQL 16+ - 18**, cerrando todas las funcionalidades pendientes.

---

## 2. Stack Tecnológico y Estructura del Repositorio

### 2.1 Backend (`sgsra-md/`)

- **Lenguaje & Framework:** Java 21, Spring Boot 3.x (`spring-boot-starter-webmvc`, `spring-boot-starter-data-jpa`, `spring-boot-starter-security`, `spring-boot-starter-validation`).
- **Base de Datos:** PostgreSQL 16+ - 18 (Relacional ACID en 3FN).
- **Seguridad & Criptografía:**
  - Contraseñas hasheadas con `BCryptPasswordEncoder` (`PasswordEncoderConfig.java`).
  - Autenticación stateless con **JWT Bearer** (`JwtTokenUtil`).
  - Auditoría inalterable (_Append-Only_) sellada con **SHA-256** (`HashUtil.java`).
- **Librerías Clave (`pom.xml`):** Lombok, Apache POI 5.2.5 (`poi-ooxml`), Apache Commons Lang3 (`commons-lang3` para sanitización CSV contra _Formula Injection_), Google Guava 33.1.0, Logback (SLF4J), SpringDoc OpenAPI 2.8.5 (Swagger).
- **Estructura de Paquetes Java (`com.masterdrilling.sgsramd`):** (falta actualizar)
  - `config/` (`PasswordEncoderConfig`, configuración CORS/WebMvc)
  - `controller/` (`AutenticacionController`, `CatalogoController`, `SolicitudController`, `InventarioController`, `PrestamoController`, `ReporteController`, `AuditoriaController`, `NotificacionController`)
  - `service/` & `service/impl/` (`AutenticacionServiceImpl`, `CatalogoServiceImpl`, `SolicitudServiceImpl`, `InventarioServiceImpl`, `PrestamoServiceImpl`, `ReporteServiceImpl`, `AuditoriaServiceImpl`, `NotificacionServiceImpl`, `StorageService`)
  - `DAO/` (`Usuario_DAO`, `Mecanico_DAO`, `Almacenista_DAO`, `Administrador_DAO`, `Repuesto_DAO`, `Maquinaria_DAO`, `Solicitud_DAO`, `SolicitudDetalle_DAO`, `Herramienta_DAO`, `Prestamo_DAO`, `PrestamoDetalle_DAO`, `Devolucion_DAO`, `AuditoriaOperacion_DAO`, `Notificacion_DAO`)
  - `model/entity/` & `model/enums/` (`RolUsuario`, `EstadoCuenta`, `EstadoSolicitud`, `PrioridadSolicitud`, `EstadoMaquinaria`)
  - `dto/request/` & `dto/response/`
  - `exception/` (`GlobalExceptionHandler` con `@RestControllerAdvice`)

### 2.2 Frontend Móvil (`sgsra_mobile/`) (falta actualizar)

- **Framework & Lenguaje:** Flutter 3.x / Dart.
- **Arquitectura:** Clean Architecture (`lib/data/`, `lib/domain/`, `lib/presentation/`) + gestión de estado reactiva con **BLoC (`flutter_bloc`)**.
- **Cliente HTTP & Persistencia Local:**
  - `Dio` (`DioClient` con interceptores JWT).
  - `flutter_secure_storage` (Android Keystore para almacenamiento cifrado del token).
  - `sqflite` (SQLite local para caché de catálogo y borradores de solicitudes en **Modo Offline** dentro de socavón).
- **Hardware & Utilidades Móviles:** `mobile_scanner` (escáner óptico QR/barras), `local_auth` (biometría dactilar), `image_picker` (cámara/galería para fotos de repuestos y herramientas), `path_provider` + `open_filex` (exportación nativa de reportes en Android).

---

## 3. Roles del Sistema y Navegación (`HomeRouter`) (falta actualizar)

El enrutador principal (`home_router.dart`) decodifica el `rol` del JWT y aísla estrictamente las vistas:

1. **`MECANICO` (`MecanicoMainScreen` - 5 Pestañas + Campana Notificaciones):**
   - Catálogo maestro de repuestos (`catalogo_screen.dart` + `detalle_repuesto_modal.dart`).
   - Carrito digital y emisión formal de solicitudes (`carrito_pedido_screen.dart`).
   - Historial personal de solicitudes con badges cromáticos (`historial_solicitudes_screen.dart`).
   - Herramientas prestadas bajo su custodia (`herramientas_prestadas_screen.dart`).
   - Mi Perfil (`perfil_mecanico_screen.dart`).
2. **`ADMINISTRADOR` (`AdminMainScreen` - 6 Pestañas + Campana Notificaciones):**
   - Bandeja unificada de solicitudes y dictámenes (`bandeja_solicitudes_screen.dart`).
   - Bitácora inalterable de auditoría SHA-256 (`auditoria_screen.dart`).
   - Mantenimiento CRUD de catálogo de repuestos y proveedores (`mantenimiento_catalogo_screen.dart` + `proveedores_modal.dart`).
   - Reportes analíticos y exportación Excel/CSV (`reportes_analiticos_screen.dart`).
   - Gestión y fiscalización de personal (`gestion_personal_screen.dart`).
   - Mi Perfil (`perfil_admin_screen.dart`).
3. **`ALMACENISTA` (`AlmacenMainScreen` - 6 Pestañas + Campana Notificaciones):**
   - Dashboard de pañol, control de préstamos activos y despacho de repuestos aprobados (`dashboard_almacen_screen.dart`).
   - Despacho formal de herramientas por DNI (`registrar_prestamo_screen.dart`).
   - Recepción física e inspección de devolución (`devolucion_inspeccion_screen.dart`).
   - Escáner óptico QR de activos (`escanear_qr_screen.dart`).
   - Catálogo y alta de herramientas (`registrar_herramienta_screen.dart` + `reportar_extravio_modal.dart`).
   - Mi Perfil (`perfil_almacenista_screen.dart`).

---

## 4. Modelo de Datos Físico Consolidado (PostgreSQL 16+ - 18)

El esquema relacional base normalizado en 3FN (incluyendo las extensiones requeridas para producción: `notificacion`, `imagen_url` y `bloqueado_hasta`):

```sql
CREATE TABLE usuario (
    id_usuario BIGSERIAL PRIMARY KEY,
    dni VARCHAR(8) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(15),
    correo_corporativo VARCHAR(100) UNIQUE NOT NULL,
    contrasena_hash VARCHAR(255) NOT NULL,
    rol VARCHAR(20) NOT NULL CHECK (rol IN ('MECANICO', 'ALMACENISTA', 'ADMINISTRADOR')),
    estado_cuenta VARCHAR(20) NOT NULL DEFAULT 'ACTIVO', -- ACTIVO, BLOQUEADO, INACTIVO
    intentos_fallidos INT NOT NULL DEFAULT 0,
    bloqueado_hasta TIMESTAMP,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE repuesto (
    cod_parte VARCHAR(30) PRIMARY KEY,
    nombre_repuesto VARCHAR(150) NOT NULL,
    categoria VARCHAR(50),
    stock_actual INT NOT NULL CHECK (stock_actual >= 0),
    stock_minimo INT NOT NULL CHECK (stock_minimo >= 0),
    descripcion TEXT,
    imagen_url VARCHAR(255), -- Ruta relativa servida desde /uploads/**
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE maquinaria (
    cod_maquinaria VARCHAR(20) PRIMARY KEY,
    modelo_maquinaria VARCHAR(100) NOT NULL,
    serie_fabricante VARCHAR(50),
    estado_operativo VARCHAR(20) NOT NULL CHECK (estado_operativo IN ('OPERATIVA', 'EN_MANTENIMIENTO', 'INOPERATIVA', 'BAJA'))
);

CREATE TABLE solicitud (
    solicitud_num VARCHAR(20) PRIMARY KEY, -- Formato: SOL-2026-XXXX
    fecha_emision DATE NOT NULL,
    hora_emision TIME WITHOUT TIME ZONE NOT NULL,
    prioridad_solicitud VARCHAR(20) NOT NULL CHECK (prioridad_solicitud IN ('BAJA', 'MEDIA', 'ALTA')),
    justificacion_tecnica TEXT NOT NULL,
    estado_solicitud VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE', -- PENDIENTE, APROBADA, APROBADA_PARCIAL, RECHAZADA, ENTREGADA
    dni_mecanico VARCHAR(8) NOT NULL REFERENCES usuario(dni),
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
    dni_administrador VARCHAR(8) NOT NULL REFERENCES usuario(dni)
);

CREATE TABLE herramienta (
    cod_herramienta VARCHAR(30) PRIMARY KEY, -- Ej: HER-TOR-004
    nombre_herramienta VARCHAR(150) NOT NULL,
    marca_herramienta VARCHAR(50) NOT NULL,
    categoria VARCHAR(30) NOT NULL CHECK (categoria IN ('Manuales', 'Hidraulicas', 'Neumaticas', 'Electricas')),
    estado_actual VARCHAR(30) NOT NULL CHECK (estado_actual IN ('Disponible', 'Prestada', 'En Mora', 'En Mantenimiento', 'Extraviada')),
    imagen_url VARCHAR(255) -- Ruta relativa servida desde /uploads/**
);

CREATE TABLE prestamo (
    prestamo_num VARCHAR(20) PRIMARY KEY,
    fecha_prestamo DATE NOT NULL,
    hora_salida TIME WITHOUT TIME ZONE NOT NULL,
    fecha_limite_retorno TIMESTAMP NOT NULL,
    dni_almacenista VARCHAR(8) NOT NULL REFERENCES usuario(dni),
    dni_mecanico VARCHAR(8) NOT NULL REFERENCES usuario(dni),
    estado_prestamo VARCHAR(20) NOT NULL DEFAULT 'ACTIVO' -- ACTIVO, DEVUELTO, CON_INCIDENCIA
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
    estado_fisico VARCHAR(30) NOT NULL, -- BUEN_ESTADO, CON_AVERIA, INCOMPLETA
    detalle_incidencia TEXT,
    prestamo_num VARCHAR(20) NOT NULL REFERENCES prestamo(prestamo_num),
    dni_almacenista VARCHAR(8) NOT NULL REFERENCES usuario(dni),
    dni_mecanico VARCHAR(8) NOT NULL REFERENCES usuario(dni)
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

-- TABLA DE NOTIFICACIONES INTERNAS 100% POSTGRESQL (Sin dependencia de Firebase/Internet)
CREATE TABLE notificacion (
    id_notificacion BIGSERIAL PRIMARY KEY,
    dni_destinatario VARCHAR(8), -- NULL si va dirigido a todo un rol
    rol_destinatario VARCHAR(20), -- MECANICO, ALMACENISTA, ADMINISTRADOR
    titulo VARCHAR(120) NOT NULL,
    mensaje TEXT NOT NULL,
    tipo_alerta VARCHAR(30) NOT NULL, -- NUEVA_SOLICITUD, DICTAMEN, MORA, EXTRAVIO, DESBLOQUEO, STOCK_MINIMO
    referencia_id VARCHAR(30), -- Ej: SOL-2026-0001 o HER-TOR-004
    leida BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- VISTA SQL DE MÉTRICAS CALCULADAS
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

- **RF01:** Inicio de sesión con correo corporativo (`@masterdrilling.com`) y contraseña (BCrypt + JWT).
- **RF02:** Asignación automática de vistas según rol (`HomeRouter`).
- **RF03:** Cierre de sesión seguro purgando `FlutterSecureStorage`.
- **RF04:** Solicitud de desbloqueo / recuperación de contraseña hacia Administración.
- **RF05:** Acceso rápido mediante biometría dactilar (`local_auth`).
- **RF06:** **Bloqueo escalonado por intentos fallidos:**
  - 3 intentos fallidos $\rightarrow$ Bloqueo temporal por **5 minutos**.
  - 6 intentos fallidos $\rightarrow$ Bloqueo temporal por **15 minutos**.
  - 9 intentos fallidos $\rightarrow$ **Bloqueo total (`BLOQUEADO`)**; habilita botón en Login para enviar _"Solicitud de Desbloqueo"_ al Administrador.
- **RF07:** Edición de perfil básico: **Bloquear edición de DNI, Nombre y Correo** (solo lectura); permitir editar únicamente el **teléfono (9 dígitos)**.
- **RF08:** Gestión y fiscalización de personal (CRUD, activar/desactivar, filtros por rol/DNI, resetear contraseñas).
  - **REGLA CRÍTICA DE SEGURIDAD JERÁRQUICA:** Un `ADMINISTRADOR` **NO** puede editar, suspender ni resetear la contraseña de otro `ADMINISTRADOR` (el backend debe responder `HTTP 403 Forbidden`). La creación o gestión de cuentas de administradores se reserva exclusivamente al área de Sistemas/TI por BD.

### Módulo 2: Catálogo y Solicitudes del Mecánico (`RF09 - RF20`)

- **RF09:** Visualizar catálogo maestro paginado de repuestos con **fotografía (`imagen_url`)**, código de parte y stock.
- **RF10:** Buscador predictivo en tiempo real (a partir de 3 caracteres).
- **RF11:** Filtrar repuestos por categoría / familia técnica (`Hidráulico`, `Filtro`, `Motor`, `Válvula`).
- **RF12:** Desplegar modal con ficha técnica completa, especificaciones y foto en alta resolución (con icono vectorial fallback si falla la carga).
- **RF13:** Agrupar múltiples repuestos en carrito digital.
- **RF14:** Seleccionar cantidad (`> 0`) y prioridad del pedido (`BAJA`, `MEDIA`, `ALTA`).
- **RF15:** Vincular solicitud obligatoriamente al código de maquinaria (`MD-RB-01`, etc.).
- **RF16:** Justificación técnica obligatoria (**mínimo 10 caracteres**, máximo 300).
- **RF17:** Transmisión formal generando correlativo `SOL-2026-XXXX` en estado `PENDIENTE` (prevención de _Double Tap_).
- **RF18:** Modo Offline: Si no hay red en socavón, guardar solicitud en SQLite local y sincronizar al recuperar conexión.
- **RF19 - RF20:** Consultar historial personal cronológico con badges cromáticos (`Amarillo`: Pendiente, `Verde`: Aprobada, `Naranja`: Aprobada Parcial, `Rojo`: Rechazada, `Azul`: Entregada).

### Módulo 3: Administración, Aprobaciones y Auditoría (`RF21 - RF32`)

- **RF21 - RF22:** Bandeja unificada de solicitudes con filtros por estado/fecha e inspección detallada.
- **RF23:** Aprobación total rápida de solicitud (`APROBADA`).
- **RF24 - RF25:** Rechazo total con motivo obligatorio (**mínimo 15 caracteres**).
- **RF26:** **Aprobación parcial de componentes:** Permitir evaluar ítem por ítem (check para aprobar / motivo individual para rechazar), guardando la orden como `APROBADA_PARCIAL`.
- **RF27:** Visualizar contactos de proveedores homologados (Bosch Rexroth, Enerpac, Parker, Donaldson, Festo).
- _(Nota: `RF28` "Marcar como orden contactada" queda descartado por ser gestión externa de administración)._
- **RF29 - RF30:** Gráficos estadísticos de demanda de repuestos y exportación nativa a **Excel (`.xlsx`) y CSV** (sin usar `dart:html` para compatibilidad Android APK).
- **RF31:** Filtros avanzados en bitácora de auditoría por **rango de fechas, usuario/operario, acción y código de máquina**.
- **RF32:** CRUD de repuestos en catálogo maestro incluyendo **subida de imagen (`MultipartFile` < 5MB)** desde cámara o galería.

### Módulo 4: Almacén / Pañol de Herramientas (`RF33 - RF45`)

- **RF33:** Dashboard de pañol con métricas en tiempo real (Disponibles, Prestadas, En Mora, En Mantenimiento, Extraviadas) + **listado tipo catálogo general de herramientas** mostrando ficha completa y foto.
- **RF34 - RF35:** Escáner óptico QR/Barras con cámara trasera que reconoce la herramienta y despliega su ficha técnica con foto.
- **RF36 - RF37:** Registrar préstamo asignando mecánico por DNI (validando cupo máximo $\le 5$ herramientas y cero moras), capturando firma y pasando estado a `Prestada`.
- **RF38 - RF40:** **Devolución por escaneo físico:** Al escanear el QR de una herramienta en estado `Prestada`, mostrar botón directo _"Registrar Devolución"_ que abre el modal de inspección física (`Buen Estado` $\rightarrow$ `Disponible`, `Con Avería` $\rightarrow$ `En Mantenimiento`, `Incompleta` $\rightarrow$ incidencia).
- **RF41 - RF42:** Reportar herramienta extraviada (motivo $\ge 10$ caracteres), imputando automáticamente al último mecánico custodio, notificando al mecánico y registrando el evento en la bitácora de auditoría para el Administrador.
- **RF43:** **Alerta visual de mora:** Resaltar en rojo brillante con ícono de reloj en el dashboard/listado las herramientas cuyo tiempo de préstamo excedió el plazo límite.
- **RF44 - RF45:** Alta de nuevas herramientas con **subida de fotografía (`MultipartFile`)** y filtrado por categorías (`Manuales`, `Hidráulicas`, `Neumáticas`, `Eléctricas`).
- **Flujo de Despacho de Repuestos en Almacén:** Visualizar solicitudes de repuestos en estado `APROBADA` / `APROBADA_PARCIAL` y confirmar entrega física (`ENTREGADA`) descontando `stock_actual`.

### Módulo 5: Notificaciones Internas y Auditoría (`RF46 - RF50`)

- **RF46 - RF48:** Sistema de notificaciones persistido al **100% en PostgreSQL** (tabla `notificacion`):
  - Nueva solicitud (`RF17`) $\rightarrow$ Notifica a `ADMINISTRADOR`.
  - Dictamen de solicitud (`RF23/24/26`) $\rightarrow$ Notifica al `MECANICO`.
  - Préstamo vencido/mora (`RF43`) $\rightarrow$ Notifica a `ALMACENISTA` y `MECANICO`.
  - Extravío de herramienta (`RF41`) $\rightarrow$ Notifica al `MECANICO` custodio y `ADMINISTRADOR`.
  - Stock mínimo alcanzado $\rightarrow$ Notifica a `ADMINISTRADOR`.
  - Solicitud de desbloqueo de cuenta (`RF06`) $\rightarrow$ Notifica a `ADMINISTRADOR`.
- **RF49:** Bitácora de auditoría _Append-Only_ con hash criptográfico `SHA-256`.
- **RF50:** **Centro de Notificaciones en los 3 roles:** Ícono de campana en AppBar con badge numérico de no leídas, pantalla con pestañas _"No leídas"_ y _"Leídas"_, y botón _"Marcar todas como leídas"_.

---

## 6. Requerimientos No Funcionales (RNF) y Reglas de Vibe Coding

1. **Compatibilidad Multiplataforma Android APK (Cero `dart:html`):**
   - Prohibido importar `dart:html` o `dart:js` en Flutter. Para descargar Excel/CSV usar `path_provider` y `open_filex`.
   - Configurar `android:usesCleartextTraffic="true"` en `AndroidManifest.xml` para permitir tráfico HTTP en red local (`http://192.168.x.x:8080/api/v1`) durante las pruebas en los 3 teléfonos físicos.
   - Centralizar la IP del servidor en una única constante configurable en `api_constants.dart`.
2. **Almacenamiento de Imágenes Local en Servidor:**
   - No usar AWS S3 ni Firebase Storage. Guardar las imágenes subidas vía `MultipartFile` en el directorio local `./uploads/imagenes/` del servidor Spring Boot y exponerlas como recurso estático `/uploads/**` mediante `WebMvcConfigurer`.
   - En Flutter, renderizar con `Image.network` manejando siempre `errorBuilder` (fallback a ícono local si no hay imagen o falla la red).
3. **Resiliencia Offline y Manejo de Errores:**
   - Las pantallas principales deben capturar excepciones `DioException` (timeout / sin red) sin mostrar pantallas rojas de error (`NoSuchMethodError` o `Null check`), recurriendo a caché SQLite local o mostrando mensajes amigables en español.
4. **Convención de Commits (Conventional Commits en Español):**
   - Formato: `feat(modulo): descripcion breve en espanol sin tildes` / `fix(modulo): correccion...`.

---

## 7. Checklist de Tareas Pendientes para Completar el Producto

Usa este checklist para guiar las sesiones de generación de código paso a paso:

- [ ] **Paso 1 (BD & Backend Storage):** Actualizar DDL PostgreSQL (`notificacion`, `imagen_url`, `bloqueado_hasta`), crear `StorageService` para imágenes multipart (`< 5MB`) y configurar `/uploads/**`.
- [ ] **Paso 2 (Backend Notificaciones & Seguridad):** Implementar `NotificacionController` / `NotificacionServiceImpl`, reglas de bloqueo escalonado (5m/15m/total), solicitud de desbloqueo y bloqueo de jerarquía entre administradores (`HTTP 403`).
- [ ] **Paso 3 (Backend Negocio):** Completar endpoint de aprobación parcial (`RF26`), despacho de repuestos en almacén (`ENTREGADA`), filtros avanzados de auditoría (`RF31`) y endpoints de subida de foto para repuestos y herramientas.
- [ ] **Paso 4 (Flutter Android Prep):** Eliminar `dart:html` en `reportes_analiticos_screen.dart`, configurar `AndroidManifest.xml` (`usesCleartextTraffic`, permisos cámara/galería) y actualizar `api_constants.dart`.
- [ ] **Paso 5 (Flutter Notificaciones & Perfil):** Crear `NotificacionesScreen` (`RF50`) e integrar la campana con badge en los 3 roles; bloquear edición de DNI/Nombre/Correo en `Mi Perfil` (`RF07`) y agregar flujo de solicitud de desbloqueo en Login.
- [ ] **Paso 6 (Flutter Imágenes, Pañol & Admin):** Integrar `image_picker` y visualización de fotos en catálogo de repuestos y herramientas; agregar catálogo agrupado y alerta roja de mora (`RF43`) en pañol; agregar botón de devolución tras escaneo QR (`RF38`); implementar checkboxes de aprobación parcial (`RF26`) y filtros de auditoría (`RF31`) en Admin.
- [ ] **Paso 7 (Build & Deploy):** Ejecutar `flutter build apk --release`, instalar el APK en los 3 teléfonos Android y validar el flujo completo extremo a extremo contra Spring Boot + PostgreSQL 18.
