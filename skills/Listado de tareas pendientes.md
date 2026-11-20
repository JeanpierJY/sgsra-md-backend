# 📋 Matriz de Tareas Pendientes y Requerimientos Funcionales (SGSRA)

> **Documento de Control y Seguimiento Técnico**  
> **Sistema de Gestión de Solicitud de Repuestos y Almacén (SGSRA - Master Drilling)**  
> **Alcance:** Backend (Spring Boot 3.x / PostgreSQL 18) y Frontend Móvil (Flutter / Android APK)

---

## 📊 1. Resumen Ejecutivo de Estado y Prioridades

| Prioridad      | Módulo / Componente                              | Requerimientos Asociados                       | Esfuerzo Estimado |        Estado General        |
| :------------- | :----------------------------------------------- | :--------------------------------------------- | :---------------: | :--------------------------: |
| 🔴 **Crítica** | **Adaptación Android APK & Plataforma**          | `Multiplataforma`, `Clean Build`, `Permisos`   |       Bajo        |     🟢 Completo en código    |
| 🔴 **Crítica** | **Centro de Notificaciones & Alertas UI**        | `RF46`, `RF47`, `RF48`, `RF50`                 |       Bajo        | 🟢 Completo (Backend & UI)   |
| 🟠 **Alta**    | **Pañol: Catálogo, QR Devolución y Despacho**    | `RF33`, `RF35`, `RF38`, `RF39`, `RF40`, `RF43` |       Bajo        | 🟢 Completo (Backend & UI)   |
| 🟠 **Alta**    | **Gestión Fotográfica Móvil (`image_picker`)**   | `RF09`, `RF12`, `RF32`, `RF35`, `RF45`         |       Medio       | 🟢 Completo (Backend & UI)   |
| 🟡 **Media**   | **Administrador: Aprobación Parcial y Bandeja**  | `RF21`, `RF26`, `RF31`, `RF49`                 |       Bajo        | 🟢 Completo (Backend & UI)   |
| 🟡 **Media**   | **Mecánico: Seguridad, Perfil y Carrito**        | `RF04`, `RF06`, `RF07`, `RF13`, `RF14`         |       Bajo        | 🟢 Completo (Backend & UI)   |
| 🟣 **Estratégica** | **Despliegue Cloud Render 24/7 & APK Final** | `Fase 6`: Render Docker, PostgreSQL, UptimeRobot, Storage y APK | Medio | 🟡 En Ejecución / Validación |
| 🟢 **Baja**    | **Trazabilidad Documental y GitHub (Semana 13)** | Plantillas A, B y C / Issues                   |       Bajo        |    ⚪ Gestión documental     |

---

## 🗂️ 2. Desglose Detallado por Módulos y Requerimientos

### 🔔 Módulo 1: Sistema Centralizado de Notificaciones y Alertas Reactivas

_Centraliza la comunicación asíncrona entre Mecánicos, Almacenistas y Administradores._

| ID RF            | Tarea / Característica                   | Capa Técnica                  | Criterio de Aceptación / Definición de Hecho                                                                                                                                                                                                                |
| :--------------- | :--------------------------------------- | :---------------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **RF50**         | **Centro de Notificaciones Universal**   | Flutter (`lib/presentation/`) | Ícono de campana con badge dinámico en las 3 pantallas principales (`MecanicoMainScreen`, `AdminMainScreen`, `AlmacenMainScreen`). Pantalla modal con pestañas _No leídas_ y _Leídas_, botón "Marcar todas como leídas" y consumo de `/api/v1/notificaciones`. |
| **RF46**         | **Alerta de Solicitud Emitida**          | Backend & DB                  | Al crearse una solicitud (`RF17`), insertar notificación con rol destino `ADMINISTRADOR` ("Nueva solicitud #NUM generada"). _(Implementado en backend)_.                                                                                                    |
| **RF47**         | **Alerta de Decisión de Solicitud**      | Flutter & Backend             | Desplegar en la campana del `MECANICO` si su orden fue aprobada, rechazada o resuelta parcialmente.                                                                                                                                                         |
| **RF43 / RF48**  | **Alerta de Mora en Préstamos de Pañol** | Flutter & Backend             | Resaltar en rojo con advertencia en el pañol y enviar notificación preventiva al `MECANICO` y `ALMACENISTA`.                                                                                                                                                |
| **RF41**         | **Alerta de Extravío de Herramientas**   | Flutter & Backend             | Notificar al mecánico involucrado y remitir reporte directo al Administrador para reposición/sanción.                                                                                                                                                       |
| **Alerta Stock** | **Aviso Temprano de Repuesto Crítico**   | Backend & Flutter             | Al caer el `stock_actual` por debajo de `stock_minimo`, generar notificación automática para `ADMINISTRADOR` y `ALMACENISTA`.                                                                                                                               |

---

### 📷 Módulo 2: Gestión de Fotografías y Recursos Multimedia

_Soporte de evidencias visuales para repuestos y herramientas tanto en almacén como en taller._

| ID RF            | Tarea / Característica                          | Capa Técnica          | Criterio de Aceptación / Definición de Hecho                                                                                                                                                     |
| :--------------- | :---------------------------------------------- | :-------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **DB & Storage** | **StorageService y Recursos Estáticos**         | Backend Spring Boot   | Subida física a `uploads/` y exposición web estática `/uploads/**`. _(Completado en Fase 1)_.                                                                                                    |
| **RF32**         | **Carga de Foto en Mantenimiento de Repuestos** | Flutter (`admin/`)    | En `mantenimiento_catalogo_screen.dart`, selector con cámara o galería (`image_picker` + `FormData` hacia `POST /api/v1/catalogo/{codParte}/imagen`). Validar peso máximo de 5 MB.              |
| **RF44 / RF45**  | **Foto en Registro de Nuevas Herramientas**     | Flutter (`almacen/`)  | En `registrar_herramienta_screen.dart`, adjuntar foto antes de guardar la herramienta mediante `POST /api/v1/inventario/herramientas/{codHerramienta}/imagen`.                                   |
| **RF09 / RF12**  | **Despliegue Visual en Catálogo de Repuestos**  | Flutter (`mecanico/`) | Componente `ImagenProducto` en tarjetas y modal `detalle_repuesto_modal.dart` con fallback corporativo ante fallos de conexión o ítems sin imagen.                                              |
| **RF35**         | **Identificación Visual por Escáner QR**        | Flutter (`scanner/`)  | Al escanear el QR en pañol, mostrar la foto registrada del ítem para validación visual rápida contra la herramienta física.                                                                      |

---

### 📦 Módulo 3: Almacén y Control de Pañol

_Optimización de recepción, despacho y control de herramientas._

| ID RF           | Tarea / Característica                         | Capa Técnica         | Criterio de Aceptación / Definición de Hecho                                                                                                                                                             |
| :-------------- | :--------------------------------------------- | :------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **RF33**        | **Catálogo General de Herramientas del Pañol** | Flutter (`almacen/`) | Pestaña _Herramientas_ con buscador predictivo, filtros por categoría y estado con contadores en tiempo real, detalle del activo con historial y botones flotantes para alta y extravío.                |
| **RF38 - RF40** | **Retorno Dinámico estilo Catálogo y Modal**   | Flutter (`scanner/`) | Listado automático de todas las herramientas actualmente en préstamo con buscador predictivo; modal emergente al tocar o escanear QR con inspección física (`BUEN_ESTADO`, `CON_AVERIA`, `INCOMPLETA`). |
| **RF43**        | **Alerta Visual de Mora en Pañol**             | Flutter (`almacen/`) | En la lista de retorno y en el panel, resaltar en rojo con badge destacado `EN MORA` las herramientas vencidas.                                                                                         |
| **Despacho**    | **Doble Salida Formal (Repuestos y Pañol)**    | Flutter & Backend    | Pestaña _Despacho_ dividida en: 1) Repuestos aprobados con confirmación de entrega y descuento de stock (`PUT /entregar`); 2) Préstamo de pañol con buscadores simétricos para mecánico y herramienta. |

---

### 🛡️ Módulo 4: Administrador, Jerarquía, Auditoría y Solicitudes

_Blindaje de privilegios y control operativo del sistema._

| ID RF               | Tarea / Característica                           | Capa Técnica        | Criterio de Aceptación / Definición de Hecho                                                                                                                                                                         |
| :------------------ | :----------------------------------------------- | :------------------ | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Seguridad Admin** | **Protección Horizontal entre Administradores**  | Backend Spring Boot | Bloqueo estricto en backend si un admin intenta alterar/suspender a otro admin (`403 Forbidden`). Cuentas de jefatura gestionadas solo por TI / script. _(Completado en Fase 1)_.                                    |
| **RF21 / Orden**    | **Priorización de Solicitudes Atrasadas (FIFO)** | Flutter & Backend   | Bandeja general con ordenamiento FIFO, filtros temporales de 30 a 180 días, contadores por estado y visualización destacada de urgentes.                                                                             |
| **RF26**            | **Aprobación / Rechazo Parcial por Ítem**        | Flutter & Backend   | Botones individuales Aprobar/Rechazar por cada repuesto con stock en vivo, motivo general obligatorio si hay rechazos y botón dinámico (_Aprobar todo_, _Aprobar parcialmente_, _Rechazar_).                         |
| **RF31 / RF49**     | **Filtros Avanzados de Auditoría Histórica**     | Flutter (`admin/`)  | Bitácora conectada directamente a PostgreSQL con filtros combinados por rango de fechas, usuario/DNI y categoría de acción, agrupada por días en lenguaje claro.                                                    |
| **Personal**        | **Búsqueda y Gestión de Usuarios**               | Flutter (`admin/`)  | Pantalla _Personal_ con buscador dinámico, edición persistente en base de datos y pantalla de resolución de solicitudes de recuperación de clave con cotejo de foto selfie vs perfil.                                 |

---

### 👤 Módulo 5: Mecánico, Seguridad y Perfiles

_Experiencia de usuario de campo y endurecimiento de autenticación._

| ID RF           | Tarea / Característica                          | Capa Técnica          | Criterio de Aceptación / Definición de Hecho                                                                                                                                      |
| :-------------- | :---------------------------------------------- | :-------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **RF07**        | **Restricción de Edición en Mi Perfil**         | Flutter & Backend     | Campos DNI, nombres y correo corporativo bloqueados en modo solo lectura para los 3 roles. Permitir editar únicamente el teléfono celular (9 dígitos) y contraseña propia.         |
| **RF04 / RF06** | **Bloqueo Escalonado y Recuperación de Cuenta** | Flutter & Backend     | 3 fallos = espera 5 min; 6 fallos = espera 10 min; 9 fallos = bloqueo definitivo. Modal de solicitud con validación DNI/teléfono y selfie obligatoria en vivo con cámara frontal.|
| **RF13 / RF14** | **Revisión de Carrito y Maquinarias**           | Flutter (`mecanico/`) | Búsqueda predictiva de flota de maquinaria (`GET /maquinarias?termino=`), selector de cantidades y nivel de urgencia (`BAJA`, `MEDIA`, `ALTA`) previo al envío de la orden.      |

---

### 📱 Módulo 6: Adaptación de Plataforma y Compilación APK Android

_Condiciones técnicas de arquitectura para compilación sin fallos y conexión en red física._

| Tarea Técnica                  | Archivo Afectado                           | Acción Requerida                                                                                                                                                       |
| :----------------------------- | :----------------------------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Eliminar dependencias Web**  | `reportes_analiticos_screen.dart`          | Bifurcación multiplataforma en `file_saver.dart` para exportación nativa a descargas de Android mediante `path_provider` + `open_filex`.                                |
| **Tráfico HTTP en Red Local**  | `android/app/src/main/AndroidManifest.xml` | Configurado `android:usesCleartextTraffic="true"` dentro de `<application>` para permitir llamadas HTTP sin SSL a la IP local de la laptop.                            |
| **Parametrización de IP Host** | `api_constants.dart`                       | IP centralizada lista para apuntar a la IP IPv4 real de la red Wi-Fi donde corre Spring Boot.                                                                          |
| **Permisos de Cámara y Fotos** | `android/app/src/main/AndroidManifest.xml` | Declarados permisos de `CAMERA`, `READ_MEDIA_IMAGES`, `READ_EXTERNAL_STORAGE` y `USE_BIOMETRIC`.                                                                       |

---

### 📑 Módulo 7: Gestión Documental y Calidad (Semana 13)

_Alineación con las observaciones de revisión y requerimientos académicos/corporativos._

| Tarea Documental | Detalle y Alcance |
| :--- | :--- |
| **Creación de Issues en GitHub** | Registrar issues con etiqueta `requerimientos` para observaciones de Plantilla A y B. Mapear unificaciones (`RF02/RF05/RF06 -> RF01`, `RF37 -> RF36`, `RF40 -> RF38`). |
| **Depuración de Alcance (`RF28`)** | Marcar formalmente `RF28` (_"Marcar orden como contactada"_) como fuera de alcance / descartado, al pertenecer al flujo externo de compras. |

---

## 🔄 3. Checklist Detallado de Ejecución

```markdown
- [x] Fase 1: PostgreSQL 18 & Backend Core
  - [x] 1.1 Script DDL: Tabla `notificacion` y columna `imagen_url` en `repuesto` y `herramienta`
  - [x] 1.2 Datos maestros: Flota de 12 maquinarias, 25 repuestos y 25 herramientas
  - [x] 1.3 Hashes oficiales Spring Security: Claves funcionales en BD (`admin`, `meca`, `alma`)
  - [x] 1.4 Servicio de Almacenamiento: `LocalStorageServiceImpl` con límite de 5 MB y recurso estático `/uploads/**`
  - [x] 1.5 Endpoints Multipart: `POST /catalogo/{codParte}/imagen` y `POST /inventario/herramientas/{codHerramienta}/imagen`
  - [x] 1.6 Mapeo DTOs: Atributo `imagenUrl` en respuestas de repuestos y fichas de herramientas
  - [x] 1.7 Seguridad Jerárquica: Bloqueo horizontal entre administradores (HTTP 403) y reseteo por DNI
  - [x] 1.8 Notificaciones Persistidas: Endpoints listar, paginar, contar no leídas y marcar lectura
  - [x] 1.9 Despacho de Repuestos: Estado `ENTREGADA` y endpoint `/entregar` con descuento de stock
  - [x] 1.10 Auditoría JPQL: Corrección de casting de parámetros nulos (evitar error SQL 42P18)
  - [x] 1.11 Normalización DB: Mapeo seguro en `FirebaseNotificacionServiceImpl` contra check constraint PostgreSQL

- [x] Fase 2: Adaptaciones Flutter para Android APK (Arquitectura & Compilación)
  - [x] 2.1 Paquetes en `pubspec.yaml`: Agregar `image_picker: ^1.1.2`, `path_provider: ^2.1.4`, `open_filex: ^4.5.0`
  - [x] 2.2 Desacoplar Web: Reemplazar descarga de reportes con `universal_html` en `reportes_analiticos_screen.dart` por guardado móvil en carpeta temporal/descargas y apertura automática con `open_filex`
  - [x] 2.3 Red Android: Configurar `android:usesCleartextTraffic="true"` en `AndroidManifest.xml` para permitir llamadas HTTP a la IP local de desarrollo
  - [x] 2.4 Permisos Nativos: Declarar permisos para lectura de almacenamiento e imágenes en `AndroidManifest.xml`
  - [x] 2.5 Parametrización de Red: Configurar `api_constants.dart` con la IP del servidor Spring Boot
  - [x] 2.6 Verificación de Build: Adaptaciones completas para el target Android APK sin dependencias exclusivas de navegador
  - [x] 2.7 Revision de ManualTestingRunner.java para averiguar que metodos, RF y otros faltan
  - [x] 2.8 Actualizacion ManualTestingRunner.java con todos los RF y nuevas funciones (conmutable de mecanicos, modo TI)

- [x] Fase 2.9: Cierre de Calibración Backend (Ajustes Previos a UI)
  - [x] 2.9.1 Lógica de Devolución: Ajustar `PrestamoServiceImpl` para que herramientas devueltas como `CON_AVERIA` o `INCOMPLETA` pasen a `En Mantenimiento` (no `Disponible`).
  - [x] 2.9.2 Historial de Préstamo: Actualizar `hora_retorno` en `prestamo_detalle` al devolver para que no figure siempre `"EN POSESION / ACTIVO"`.
  - [x] 2.9.3 Alerta de Mora: Al pasar préstamo a `MORA` en `verificarAlertasPrestamos()`, actualizar las herramientas en `herramienta` a `estado_actual = 'En Mora'` (RF43).
  - [x] 2.9.4 Evidencia Selfie en Recuperación: Agregar columna `foto_selfie_url` en `solicitud_recuperacion_clave`, soporte multipart en `POST /api/v1/auth/recuperar-clave` con guardado en `./uploads/selfies/` y exponer URL en `SolicitudRecuperacionResponse` para revisión visual del Administrador.

- [x] Fase 3: Core Móvil, Red WiFi & Componentes Transversales (Android APK Ready)
  - [x] 3.1 Eliminación limpia de `dart:html` / `universal_html` en reportes mediante `file_saver.dart` nativo.
  - [x] 3.2 Parametrización de red local centralizada en `api_constants.dart` y `usesCleartextTraffic` en manifiesto.
  - [x] 3.3 Centro Universal de Notificaciones (`RF50`): Campana en AppBar con badge reactivo en los 3 paneles y pantalla modal con filtros Leídas/No Leídas y enlace directo a la solicitud/recuperación.
  - [x] 3.4 Seguridad, Bloqueo Escalonado y Recuperación con Selfie (`RF04`, `RF06`, `REQ-02`):
    - Diálogo reactivo con cuenta regresiva: 3 fallos = espera 5 min; 6 fallos = espera 10 min; 9 fallos = bloqueo definitivo (`BLOQUEADO`).
    - Formulario modal para solicitar restablecer contraseña con validación de DNI (8 dígitos) y teléfono (9 dígitos).
    - Captura obligatoria de foto selfie en vivo con cámara frontal (`image_picker` con `CameraDevice.front`) enviada como evidencia al Administrador.
  - [x] 3.5 Pantalla Mi Perfil Universal (`RF07`, `REQ-01`): Acceso superior derecho en todas las pantallas (`GEN-02`); bloqueo estricto de DNI, nombre, correo y cargo (`readOnly = true`); edición de teléfono y cambio de contraseña propia.

- [x] Fase 4: Flujos Operativos y Vistas Especializadas por Rol
  - [x] 4.1 Módulo Mecánico:
    - [x] 4.1.1 Despliegue de fotos de repuestos en catálogo y modal de ficha técnica (`RF09`, `RF12`) con componente `ImagenProducto` y fallback corporativo.
    - [x] 4.1.2 Búsqueda predictiva de maquinaria (`MEC-05`) y carrito en 4 pasos con cantidades editables y urgencia en botones de color (`REQ-03`, `BUG-04`).
    - [x] 4.1.3 Historial cromático personal de solicitudes (`RF19`, `RF20`) y consulta de herramientas prestadas bajo su custodia con ficha antes/después (`PRE-01`).
  - [x] 4.2 Módulo Administrador:
    - [x] 4.2.1 Ordenamiento FIFO de solicitudes pendientes con contadores por estado, buscador y filtros temporales (`RF21`, `ADM-06`).
    - [x] 4.2.2 Modal de aprobación parcial por ítem (`RF26`, `ADM-05`) con stock en tiempo real y motivo general obligatorio si hay rechazos.
    - [x] 4.2.3 Barra de búsqueda dinámica y selector por rol en Gestión de Personal (`ADM-01`).
    - [x] 4.2.4 Pantalla de atención de solicitudes de recuperación de contraseña con comparación visual selfie vs perfil (`AUT-02`, `AUT-03`).
    - [x] 4.2.5 Filtros avanzados de auditoría conectada a base de datos (`ADM-02`, `ADM-03`).
    - [x] 4.2.6 Selector fotográfico (`image_picker`) con cámara o galería en mantenimiento de repuestos (`RF32`, `ADM-08`).
  - [x] 4.3 Módulo Almacenista (Ergonomía de Pañol Consolidada):
    - [x] 4.3.1 Rediseño a 4 pestañas: Dashboard, Despacho, Retorno y Herramientas.
    - [x] 4.3.2 Despacho formal de herramientas con buscador simétrico de mecánicos y herramientas con foto (`ALM-02`, `ALM-07`).
    - [x] 4.3.3 Despacho formal de repuestos aprobados con confirmación de entrega y descuento de stock en tiempo real (`ALM-01`).
    - [x] 4.3.4 Retorno de herramientas con visor QR optimizado, buscador predictivo y listado automático estilo catálogo (`ALM-08`, `ALM-09`).
    - [x] 4.3.5 Modal de retorno interactivo al seleccionar herramienta o capturar QR con estado físico (`BUEN_ESTADO`, `CON_AVERIA`, `INCOMPLETA`), detalle de avería y confirmación inmediata (`ALM-10`, `ALM-11`).
    - [x] 4.3.6 Indicadores del Dashboard compactos (3 por fila) alimentados en vivo desde PostgreSQL sin datos mock (`ALM-06`).
    - [x] 4.3.7 Botones flotantes para Nueva Herramienta y Reportar Extravío en catálogo de herramientas (`ALM-04`, `ALM-05`).

- [x] Fase 5: Pruebas Integradas E2E en Red WiFi, Carga de Multimedia, Compilación APK y Despliegue
  - [x] 5.1 Carga y distribución de multimedia: logotipos e íconos en `assets/images/`, catálogo y pañol en `assets/images/` y `uploads/**`, y mipmaps Android configurados.
  - [x] 5.2 Ajustes operativos y ergonomía: navegación en 3 pestañas para herramientas de mecánico, eliminación de filtro proveedor en bandeja, restauración de proveedores con discado telefónico nativo (`ACTION_DIAL`) y buscador predictivo de extraviadas en pañol.
  - [x] 5.3 Ciclo cruzado E2E: Mecánico solicita → Admin aprueba/parcial → Almacenista despacha repuestos; Almacén presta herramienta → Mecánico custodia → Almacén liquida por QR.
  - [x] 5.4 Compatibilidad Universal Android: `minSdk = 21` (Android 5.0 a 15), `multiDexEnabled = true`, ABI filters multi-arquitectura (`armeabi-v7a`, `arm64-v8a`, `x86_64`), hardware de cámara opcional para emuladores/tablets y calibración Gradle 9.3.1 / AGP 9.1.0 para Java 25.
  - [x] 5.5 Puesta en marcha en Android Studio: Proyecto sincronizado y listo para ejecutar en emulador o dispositivo físico y generar APK universal release.

- [ ] Fase 6: Despliegue en la Nube con Render Cloud (24/7 con UptimeRobot) y Generación de APK Final
  - [x] 6.1 Despliegue del Backend Spring Boot en Render Cloud: Creación de `Dockerfile` multi-etapa Java 21, conexión del repositorio GitHub y despliegue del Web Service (`https://sgsra-md-backend.onrender.com`).
  - [x] 6.2 Aprovisionamiento de Base de Datos PostgreSQL en Render: Instancia `sgsra-db` con ejecución de `Query_sgsra_db.sql` y población de datos con `Query_Insercion.sql`.
  - [x] 6.3 Monitor Keep-Alive 24/7 con UptimeRobot: Configuración de sondeo HTTP periódico cada 5 minutos hacia `/api/v1/catalogo` para evitar la suspensión (spin down) tras 15 minutos de inactividad.
  - [x] 6.4 Conexión Móvil en Flutter (`api_constants.dart`): Configuración de host HTTPS Render con aumento de timeout a 60 segundos tolerante a arranques en frío.
  - [ ] 6.5 Añadir Almacenamiento Multimedia Real Persistente (Cloudinary / AWS S3 / Firebase Storage): Migración del almacenamiento local de `./uploads/` hacia un bucket/servicio cloud persistente, ya que el sistema de archivos del contenedor Docker en Render es efímero y ante reinicios o despliegues se pierden las imágenes subidas de repuestos, herramientas y selfies.
  - [ ] 6.6 Generación de APK Release Final para Android: Compilación del binario universal `flutter build apk --release` optimizado para producción, verificando firma, iconografía corporativa y cero errores de compilación.
```

---

## 🖼️ 4. Inventario de Recursos Multimedia Requeridos

Consulte el documento completo [recursos_multimedia_requeridos.md](file:///c:/Users/Usuario/Documents/GitHub/sgsra-md-backend/skills/recursos_multimedia_requeridos.md) para las especificaciones detalladas.

| Tipo de Recurso | Cantidad | Ubicación Destino | Especificación Técnica |
| :--- | :---: | :--- | :--- |
| **Identidad Visual** | 3 archivos | `sgsra_mobile/assets/images/` | Logo Master Drilling (512x512 PNG), Isotipo y Avatar genérico |
| **Ícono App Android** | 1 set | `android/app/src/main/res/mipmap-*/` | `ic_launcher.png` adaptable para launcher Android |
| **Fotos Repuestos** | 10 a 25 fotos | Servidor Spring Boot `./uploads/imagenes/` | Formato JPG/PNG < 5 MB (bombas, válvulas, filtros, motores, mangueras) |
| **Fotos Herramientas** | 10 a 25 fotos | Servidor Spring Boot `./uploads/imagenes/` | Formato JPG/PNG < 5 MB (torquímetros, pistolas neumáticas, multímetros, gatos) |
| **Códigos QR de Prueba** | 5 códigos | Proyección en pantalla o impresos | Textos planos de prueba: `HER-TOR-004`, `HER-PIS-012`, `HER-FLU-001`, etc. |
