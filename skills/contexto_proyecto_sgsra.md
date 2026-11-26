# CONTEXTO MAESTRO DEL PROYECTO: SGSRA-MD (Master Drilling Perú S.A.)

> **System Prompt / Regla Base para el Asistente de IA:**
> Actúa como un Arquitecto de Software Senior Full-Stack experto en **Java 21 (Spring Boot 3.x / 4.x)**, **Flutter 3.x (Dart / BLoC / Clean Architecture)**, **PostgreSQL 16+ - 18** y **Despliegue Cloud en Render Cloud (Web Service Docker + PostgreSQL)**. Todo el código que generes debe integrarse de manera estricta con este contexto, respetando las rutas reales del repositorio, nombres de tablas, convenciones de API, reglas de negocio y entregables de producción definidos a continuación. **No uses placeholders, código simulado ni mocks falsos en lógica de negocio; entrega código completo, limpio y funcional listo para compilar en APK Android y backend REST.**

---

## 1. Resumen Ejecutivo y Propósito del Producto

- **Nombre del Sistema:** SGSRA-MD (_Sistema de Gestión de Solicitudes de Repuestos para Maquinarias Pesadas y Control de Almacén de Herramientas_).
- **Cliente / Empresa:** Master Drilling Perú S.A. (Operaciones de perforación minera subterránea / Raise Boring). Enfoque operacional: taller de mantenimiento electromecánico y pañol de herramientas.
- **Repositorio Oficial:** `https://github.com/JeanpierJY/sgsra-md-backend` (Rama activa de desarrollo: `SG_rama`; ramas históricas: `main`, `Backend-Spring-Boot`, `Modules-Roles`).
- **Problema que Resuelve:** Elimina la fricción operativa, demoras, suplantaciones de identidad y pérdidas críticas (18% anual) causadas por el uso de formatos físicos en papel (`FOR-MNT-012`, `FOR-ADM-004`, `FOR-ALM-015`, cuadernos de pañol) para solicitar repuestos de maquinaria pesada y controlar el préstamo/devolución de herramientas calibradas en taller y socavón.
- **Objetivo Actual de Desarrollo:** Consolidación final del producto con empaquetado **APK Release Android** para dispositivos móviles de taller y despliegue del backend y base de datos en la nube **24/7 en Render Cloud (`https://sgsra-md-backend.onrender.com`)**, permitiendo conectividad ubicua (WiFi y datos móviles) sin depender de IPs locales ni configuraciones de firewall de laptop.

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
  - `mobile_scanner: ^7.1.0`: Escaneo óptico ultrarrápido de códigos QR y barras en taller.
  - `qr_flutter: ^4.1.0`: Generación de etiquetas QR para herramientas.
  - `local_auth: ^2.1.8`: Autenticación biométrica con huella dactilar.
  - `image_picker: ^1.1.2`: Captura con cámara frontal (selfie de recuperación) y trasera (fotos de piezas).
  - `path_provider: ^2.1.4` + `open_filex: ^4.5.0`: Guardado y apertura automática de archivos Excel/CSV nativos en Android.
  - `url_launcher: ^6.3.1`: Apertura directa de WhatsApp (`wa.me`) para enviar claves temporales de recuperación.
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
- **Catálogo (`mantenimiento_catalogo_screen.dart`):** Gestión CRUD de repuestos, filtros por estado (`Todos`, `Habilitados`, `Deshabilitados`), carga fotográfica y botón superior para consultar **Proveedores Homologados** con redirección directa a llamadas telefónicas.
- **Reportes (`reportes_analiticos_screen.dart`):** Métricas consolidadas de demanda, gráficos reactivos y exportación directa a Excel (`.xlsx`) y CSV compatible con Android.
- **Personal (`gestion_personal_screen.dart`):** Búsqueda de usuarios, activación/bloqueo de cuentas, edición de nombre (sin edición de teléfono por seguridad) y pantalla de atención de solicitudes de recuperación de clave con cotejo de selfie vs perfil y botón **WhatsApp** con mensaje prellenado al chat del trabajador.

### 3. `ALMACENISTA` (`AlmacenMainScreen` - 4 Pestañas Inferiores + Mi Perfil en AppBar)
- **Dashboard (`dashboard_almacen_screen.dart`):** Indicadores en tiempo real de pañol (Disponibles, Prestadas, En Mora, Mantenimiento, Extraviadas) seguido de la sección **Repuestos Aprobados para Retiro Físico** y el **Control de Préstamos Activos**.
- **Despacho (`despacho_screen.dart`):** Doble salida operativa dividida en:
  1. *Repuestos:* Entrega formal de solicitudes aprobadas con verificación de stock y cambio a estado `ENTREGADA`.
  2. *Herramientas:* Salida formal de pañol por DNI con buscador simétrico de mecánicos y herramientas.
- **Retorno (`retorno_qr_screen.dart`):** Escáner óptico QR con cámara trasera, buscador predictivo y modal interactivo de inspección física (`BUEN_ESTADO`, `CON_AVERIA`, `INCOMPLETA`) con ficha antes/después.
- **Herramientas (`registrar_herramienta_screen.dart`):** Catálogo de herramientas con buscador predictivo, filtros por categoría/estado, botón flotante de alta y botón flotante de **Reporte de Extravío [RF41]** que abre modal con buscador exclusivo de herramientas extraviadas e imputación al último custodio.

---

## 4. Catálogo de Requerimientos Funcionales (RF01 - RF50) y Reglas de Negocio

### Módulo 1: Seguridad, Usuarios y Perfiles (`RF01 - RF08`)
- ~~**RF01:** Inicio de sesión con correo corporativo (`@masterdrilling.com`) y contraseña hasheada en BCrypt.~~ ✅
- ~~**RF02:** Asignación automática de vistas según rol mediante `HomeRouter`.~~ ✅
- ~~**RF03:** Cierre de sesión seguro purgando llaves en `FlutterSecureStorage`.~~ ✅
- ~~**RF04:** Solicitud de desbloqueo / recuperación de contraseña hacia Administración con evidencia fotográfica selfie en vivo (`CameraDevice.front`) y envío de clave temporal por **WhatsApp**.~~ ✅
- ~~**RF05:** Acceso rápido mediante biometría dactilar (`local_auth`) con prellenado de último correo y token seguro en Keystore.~~ ✅
- ~~**RF06:** **Bloqueo escalonado por intentos fallidos:**~~ ✅
  - ~~3 fallos consecutivos $\rightarrow$ Bloqueo temporal por 5 minutos.~~
  - ~~6 fallos consecutivos $\rightarrow$ Bloqueo temporal por 15 minutos.~~
  - ~~9 fallos consecutivos $\rightarrow$ **Bloqueo total (`BLOQUEADO`)**, requiriendo atención formal del Administrador.~~
- ~~**RF07:** Edición de perfil básico: DNI, Nombres y Correo en modo solo lectura; permite actualizar el teléfono (9 dígitos, solo Mecánico y Almacenista) y contraseña personal.~~ ✅
- ~~**RF08:** Gestión de personal: Búsqueda dinámica, activación/bloqueo de cuentas, edición de nombres (sin edición de teléfono por seguridad), reseteo de claves y revisión de selfies.~~ ✅
  - **REGLA CRÍTICA DE JERARQUÍA:** Un Administrador no puede suspender, alterar ni resetear a otro Administrador (retorna `HTTP 403 Forbidden`).

### Módulo 2: Catálogo y Solicitudes del Mecánico (`RF09 - RF20`)
- ~~**RF09 - RF12:** Catálogo maestro paginado con fotos reales (`imagen_url`), buscador predictivo en tiempo real y modal de ficha técnica con fallback offline.~~ ✅
- ~~**RF13 - RF16:** Carrito digital con selector predictivo de maquinaria pesada (`MD-RB-01`), selector de cantidad, nivel de prioridad (`BAJA`, `MEDIA`, `ALTA`) y justificación técnica ($\ge 10$ caracteres).~~ ✅
- ~~**RF17:** Transmisión formal con generación de correlativo `SOL-2026-XXXX` en estado `PENDIENTE`.~~ ✅
- ~~**RF18:** Modo Offline: Almacenamiento local en SQLite cifrado ante pérdida de señal en socavón.~~ ✅
- ~~**RF19 - RF20:** Historial personal de solicitudes con badges cromáticos (`Amarillo`: Pendiente, `Verde`: Aprobada, `Naranja`: Aprobada Parcial, `Rojo`: Rechazada, `Azul`: Entregada).~~ ✅

### Módulo 3: Administración, Aprobaciones y Auditoría (`RF21 - RF32`)
- ~~**RF21 - RF22:** Bandeja unificada ordenada por FIFO con filtros temporales (30 a 180 días) y contadores dinámicos.~~ ✅
- ~~**RF23 - RF25:** Aprobación total inmediata o rechazo total con justificación técnica obligatoria ($\ge 15$ caracteres).~~ ✅
- ~~**RF26:** **Aprobación parcial de componentes:** Evaluación ítem por ítem con validación de stock en vivo, pasando la orden a `APROBADA_PARCIAL`.~~ ✅
- ~~**RF27:** Directorio de proveedores homologados (Bosch Rexroth, Enerpac, Parker, Donaldson, Festo) con botón de llamada nativa por `MethodChannel` (`Intent.ACTION_DIAL`).~~ ✅
- **RF28:** *(Descartado del alcance por ser gestión administrativa externa de compras)*.
- ~~**RF29 - RF30:** Reportes analíticos con gráficos interactivos y exportación nativa a **Excel (`.xlsx`) y CSV** compatible con Android.~~ ✅
- ~~**RF31:** Bitácora de auditoría histórica con filtros por rango de fechas, usuario/DNI y acción.~~ ✅
- ~~**RF32:** CRUD de repuestos con filtros (`Todos`, `Habilitados`, `Deshabilitados`) y carga fotográfica multipart (`< 5MB`).~~ ✅

### Módulo 4: Almacén / Pañol de Herramientas (`RF33 - RF45`)
- ~~**RF33:** Dashboard de pañol con stock en tiempo real (Disponibles, Prestadas, En Mora, Mantenimiento, Extraviadas) con Repuestos Aprobados antes de Préstamos.~~ ✅
- ~~**RF34 - RF35:** Escáner óptico QR con cámara trasera y despliegue instantáneo de ficha técnica del activo.~~ ✅
- ~~**RF36 - RF37:** Salida formal de herramientas validando cupo máximo ($\le 5$ herramientas), capturando firma digital.~~ ✅
- ~~**RF38 - RF40:** Recepción e inspección física de devolución (`BUEN_ESTADO` $\rightarrow$ Disponible, `CON_AVERIA` / `INCOMPLETA` $\rightarrow$ En Mantenimiento) con visualización antes/después (`PRE-01`).~~ ✅
- ~~**RF41 - RF42:** Reporte de extravío de herramientas con buscador predictivo exclusivo de activos perdidos e imputación de responsabilidad al último custodio.~~ ✅
- ~~**RF43:** Alerta visual destacada en rojo/ámbar para préstamos y herramientas en estado `MORA`.~~ ✅
- ~~**RF44 - RF45:** Alta de herramientas por categoría (`Manuales`, `Hidráulicas`, `Neumáticas`, `Eléctricas`) con envío de `correoAlmacenista`, etiqueta QR y fotografía opcional/en alta.~~ ✅
- ~~**Flujo de Despacho de Repuestos:** Entrega física de repuestos de solicitudes aprobadas, pasando a estado `ENTREGADA` y descontando el inventario físico en tiempo real.~~ ✅

### Módulo 5: Notificaciones Internas y Auditoría (`RF46 - RF50`)
- ~~**RF46 - RF48:** Sistema de notificaciones persistidas en PostgreSQL (tabla `notificacion`) para solicitudes, dictámenes, moras, extravíos y stock mínimo.~~ ✅
- ~~**RF49:** Registro inmutable de auditoría con hash SHA-256 e IP de origen.~~ ✅
- ~~**RF50:** Centro de notificaciones universal con campana y badge numérico en AppBar en los 3 roles.~~ ✅

---

## 5. Arquitectura de Despliegue Cloud: Render Cloud (Web Service Docker + PostgreSQL)

Para garantizar la disponibilidad continua del sistema sin depender de redes locales ni laptops encendidas:

```
┌────────────────────────────────────────────────────────────────────────┐
│                        RENDER CLOUD (PaaS / Docker)                    │
│                                                                        │
│   Web Service: https://sgsra-md-backend.onrender.com (HTTPS Nativo)    │
│   Database: PostgreSQL 16/18 Gestionado (sgsra_db)                     │
│                                                                        │
│   ┌──────────────────────────────────────────────────────────────┐    │
│   │               Docker Container (Java 21 JRE Alpine)          │    │
│   │                                                              │    │
│   │   ┌────────────────────────┐      ┌──────────────────────┐   │    │
│   │   │ Spring Boot 3.x/4.x    │◄────►│ Render PostgreSQL 16 │   │    │
│   │   │ Puerto: 8080 (REST)    │      │ (sgsra_db interno)   │   │    │
│   │   └───────────┬────────────┘      └──────────────────────┘   │    │
│   │               │                                              │    │
│   │               ▼                                              │    │
│   │   ┌────────────────────────┐                                 │    │
│   │   │ Storage ./uploads/     │ ⚠️ Almacenamiento Efímero        │    │
│   │   │ (Fotos / Selfies)      │ (Se borra ante reinicios)       │    │
│   │   └────────────────────────┘                                 │    │
│   └──────────────────────────────────────────────────────────────┘    │
│                                   ▲                                    │
│   Keep-Alive 24/7 (UptimeRobot)   │ Ping HTTP GET cada 5 min           │
│   https://uptimerobot.com ────────┘ (Evita suspensión por inactividad) │
└───────────────────────────────────▲────────────────────────────────────┘
                                    │ HTTPS REST API
                                    │ (Puerto 443 / SSL)
            ┌───────────────────────┴───────────────────────┐
            │                                               │
     📱 Celular Mecánico                     📱 Celular Almacén / Admin
   (App SGSRA-MD Release APK)               (App SGSRA-MD Release APK)
    Red WiFi / Datos 4G/5G                   Red WiFi / Datos 4G/5G
```

> ⚠️ **Consideraciones Operativas de Render Cloud:**
> 1. **Reposo y Arranque en Frío:** En el plan gratuito, si no recibe peticiones por 15 minutos, el contenedor entra en modo reposo. El arranque en frío demora **1 a 2 minutos**. Para mitigarlo, se utiliza un monitor en **UptimeRobot** que envía pings continuos cada 5 minutos al endpoint `/api/v1/catalogo`.
> 2. **Almacenamiento Efímero:** El directorio `/app/uploads` reside dentro del contenedor Docker. Ante cualquier reinicio o redeploy, los archivos subidos se eliminan. Se requiere implementar un proveedor de almacenamiento persistente en la nube (Cloudinary, AWS S3 o Firebase Storage).

---

## 6. Modelo de Datos Físico Consolidado (PostgreSQL 16+ - 18)

Esquema relacional actualizado conforme a `Query_sgsra_db.sql` y las entidades JPA/Hibernate en producción (3FN, integridad referencial completa, auditoría, notificaciones, recuperación de contraseñas e índices B-Tree):

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
    estado_cuenta VARCHAR(20) NOT NULL DEFAULT 'ACTIVO' CHECK (estado_cuenta IN ('ACTIVO', 'BLOQUEADO', 'INACTIVO')),
    intentos_fallidos INT NOT NULL DEFAULT 0,
    bloqueado_hasta TIMESTAMP WITHOUT TIME ZONE, -- Generado/actualizado por JPA Hibernate
    foto_perfil_url VARCHAR(255),
    creado_en TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 2. TABLAS DE ESPECIALIZACIÓN POR ROL
-- ============================================================================
CREATE TABLE mecanico (
    dni_mecanico VARCHAR(8) PRIMARY KEY REFERENCES usuario(dni) ON UPDATE CASCADE ON DELETE RESTRICT,
    nombre_mecanico VARCHAR(100) NOT NULL,
    especialidad_mecanico VARCHAR(50) NOT NULL,
    cargo_mecanico VARCHAR(50) NOT NULL,
    telefono VARCHAR(15)
);

CREATE TABLE almacenista (
    dni_almacenista VARCHAR(8) PRIMARY KEY REFERENCES usuario(dni) ON UPDATE CASCADE ON DELETE RESTRICT,
    nombre_almacenista VARCHAR(100) NOT NULL,
    sede_asignada VARCHAR(50) NOT NULL,
    telefono VARCHAR(15)
);

CREATE TABLE administrador (
    dni_administrador VARCHAR(8) PRIMARY KEY REFERENCES usuario(dni) ON UPDATE CASCADE ON DELETE RESTRICT,
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
    estado_solicitud VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE'
        CHECK (estado_solicitud IN ('PENDIENTE', 'APROBADA', 'APROBADA_PARCIAL', 'RECHAZADA', 'ORDEN_CONTACTADA', 'ENTREGADA')),
    dni_mecanico VARCHAR(8) NOT NULL REFERENCES mecanico(dni_mecanico) ON UPDATE CASCADE ON DELETE RESTRICT,
    cod_maquina VARCHAR(20) NOT NULL REFERENCES maquinaria(cod_maquinaria) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE solicitud_detalle (
    solicitud_num VARCHAR(20) NOT NULL REFERENCES solicitud(solicitud_num) ON DELETE CASCADE,
    item INT NOT NULL,
    cantidad_repuesto INT NOT NULL CHECK (cantidad_repuesto > 0),
    cod_parte VARCHAR(30) NOT NULL REFERENCES repuesto(cod_parte) ON UPDATE CASCADE ON DELETE RESTRICT,
    estado_item VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE' CHECK (estado_item IN ('PENDIENTE', 'APROBADO', 'RECHAZADO')),
    motivo_rechazo_item TEXT,
    PRIMARY KEY (solicitud_num, item)
);

CREATE TABLE dictamen_rechazo (
    dictamen_num VARCHAR(20) PRIMARY KEY,
    ref_solicitud_num VARCHAR(20) NOT NULL REFERENCES solicitud(solicitud_num) ON DELETE RESTRICT,
    fecha_evaluacion DATE NOT NULL,
    justificacion_rechazo TEXT NOT NULL,
    dni_administrador VARCHAR(8) NOT NULL REFERENCES administrador(dni_administrador) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE detalle_rechazo (
    dictamen_num VARCHAR(20) NOT NULL REFERENCES dictamen_rechazo(dictamen_num) ON DELETE CASCADE,
    item INT NOT NULL,
    cod_parte VARCHAR(30) NOT NULL REFERENCES repuesto(cod_parte) ON UPDATE CASCADE ON DELETE RESTRICT,
    cantidad_rechazada INT NOT NULL CHECK (cantidad_rechazada > 0),
    motivo_especifico_item VARCHAR(255) NOT NULL,
    PRIMARY KEY (dictamen_num, item)
);

-- ============================================================================
-- 5. PAÑOL DE HERRAMIENTAS, PRÉSTAMOS, DEVOLUCIONES Y REGISTRO DE LOTES
-- ============================================================================
CREATE TABLE herramienta (
    cod_herramienta VARCHAR(30) PRIMARY KEY, -- Ej: HER-TOR-004
    nombre_herramienta VARCHAR(150) NOT NULL,
    marca_herramienta VARCHAR(50) NOT NULL,
    categoria VARCHAR(30) NOT NULL CHECK (categoria IN ('Electricas', 'Hidraulicas', 'Neumaticas', 'Manuales')),
    estado_actual VARCHAR(30) NOT NULL CHECK (estado_actual IN ('Disponible', 'Prestada', 'En Mora', 'En Mantenimiento', 'Extraviada', 'Baja Tecnica')),
    imagen_url VARCHAR(255)
);

CREATE TABLE prestamo (
    prestamo_num VARCHAR(20) PRIMARY KEY,
    fecha_prestamo DATE NOT NULL,
    hora_salida TIME WITHOUT TIME ZONE NOT NULL,
    dni_almacenista VARCHAR(8) NOT NULL REFERENCES almacenista(dni_almacenista) ON UPDATE CASCADE ON DELETE RESTRICT,
    dni_mecanico VARCHAR(8) NOT NULL REFERENCES mecanico(dni_mecanico) ON UPDATE CASCADE ON DELETE RESTRICT,
    estado_prestamo VARCHAR(20) NOT NULL DEFAULT 'ACTIVO' CHECK (estado_prestamo IN ('ACTIVO', 'CERRADO', 'MORA')),
    aviso_preventivo_enviado BOOLEAN DEFAULT FALSE
);

CREATE TABLE prestamo_detalle (
    prestamo_num VARCHAR(20) NOT NULL REFERENCES prestamo(prestamo_num) ON DELETE CASCADE,
    item INT NOT NULL,
    cod_herramienta VARCHAR(30) NOT NULL REFERENCES herramienta(cod_herramienta) ON UPDATE CASCADE ON DELETE RESTRICT,
    nombre_herramienta VARCHAR(150) NOT NULL,
    estado_herramienta VARCHAR(50) NOT NULL,
    hora_retorno TIME WITHOUT TIME ZONE,
    firma_mecanico TEXT NOT NULL,
    PRIMARY KEY (prestamo_num, item)
);

CREATE TABLE devolucion (
    devolucion_num VARCHAR(20) PRIMARY KEY,
    fecha_devolucion DATE NOT NULL,
    hora_retorno TIME WITHOUT TIME ZONE NOT NULL,
    detalle_incidencia TEXT,
    prestamo_num VARCHAR(20) NOT NULL REFERENCES prestamo(prestamo_num) ON DELETE RESTRICT,
    dni_almacenista VARCHAR(8) NOT NULL REFERENCES almacenista(dni_almacenista) ON UPDATE CASCADE ON DELETE RESTRICT,
    dni_mecanico VARCHAR(8) NOT NULL REFERENCES mecanico(dni_mecanico) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE devolucion_detalle (
    devolucion_num VARCHAR(20) NOT NULL REFERENCES devolucion(devolucion_num) ON DELETE CASCADE,
    item INT NOT NULL,
    cod_herramienta VARCHAR(30) NOT NULL REFERENCES herramienta(cod_herramienta) ON UPDATE CASCADE ON DELETE RESTRICT,
    estado_herramienta VARCHAR(50) NOT NULL CHECK (estado_herramienta IN ('Buen Estado', 'Con Averia', 'Incompleta')),
    PRIMARY KEY (devolucion_num, item)
);

CREATE TABLE registro (
    registro_num VARCHAR(20) PRIMARY KEY,
    fecha_ingreso DATE NOT NULL,
    dni_almacenista VARCHAR(8) NOT NULL REFERENCES almacenista(dni_almacenista) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE registro_detalle (
    registro_num VARCHAR(20) NOT NULL REFERENCES registro(registro_num) ON DELETE CASCADE,
    item INT NOT NULL,
    cod_herramienta VARCHAR(30) NOT NULL REFERENCES herramienta(cod_herramienta) ON UPDATE CASCADE ON DELETE RESTRICT,
    PRIMARY KEY (registro_num, item)
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
    fecha_solicitud TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    fecha_resolucion TIMESTAMP WITHOUT TIME ZONE,
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
    timestamp TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    hash_sha256 VARCHAR(64) NOT NULL
);

CREATE TABLE notificacion (
    id_notificacion BIGSERIAL PRIMARY KEY,
    dni_destinatario VARCHAR(8),
    rol_destinatario VARCHAR(20) CHECK (rol_destinatario IN ('MECANICO', 'ALMACENISTA', 'ADMINISTRADOR', 'TODOS')),
    titulo VARCHAR(150) NOT NULL,
    mensaje TEXT NOT NULL,
    tipo_alerta VARCHAR(30) NOT NULL DEFAULT 'INFO'
        CHECK (tipo_alerta IN ('INFO', 'SOLICITUD', 'APROBACION', 'RECHAZO', 'MORA', 'EXTRAVIO', 'STOCK_MINIMO')),
    referencia_id VARCHAR(30),
    leida BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_creacion TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 7. ÍNDICES B-TREE (Optimización de Consultas Frecuentes)
-- ============================================================================
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
CREATE INDEX idx_solicitud_recup_dni ON solicitud_recuperacion_clave(dni_solicitante);
CREATE INDEX idx_solicitud_recup_estado ON solicitud_recuperacion_clave(estado);
```
