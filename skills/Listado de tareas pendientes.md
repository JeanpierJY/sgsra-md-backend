# 📋 Matriz de Tareas Pendientes y Requerimientos Funcionales (SGSRA)

> **Documento de Control y Seguimiento Técnico**  
> **Sistema de Gestión de Solicitud de Repuestos y Almacén (SGSRA - Master Drilling)**  
> **Alcance:** Backend (Spring Boot 3.x / PostgreSQL 18) y Frontend Móvil (Flutter / Android APK)

---

## 📊 1. Resumen Ejecutivo de Estado y Prioridades

| Prioridad      | Módulo / Componente                              | Requerimientos Asociados                       | Esfuerzo Estimado |        Estado General        |
| :------------- | :----------------------------------------------- | :--------------------------------------------- | :---------------: | :--------------------------: |
| 🔴 **Crítica** | **Adaptación Android APK & Plataforma**          | `Multiplataforma`, `Clean Build`, `Permisos`   |       Medio       |        🟡 En progreso        |
| 🔴 **Crítica** | **Centro de Notificaciones & Alertas UI**        | `RF46`, `RF47`, `RF48`, `RF50`                 |       Medio       | 🟡 Backend OK / UI Pendiente |
| 🟠 **Alta**    | **Pañol: Catálogo, QR Devolución y Despacho**    | `RF33`, `RF35`, `RF38`, `RF39`, `RF40`, `RF43` |       Medio       |        🟡 UI Parcial         |
| 🟠 **Alta**    | **Gestión Fotográfica Móvil (`image_picker`)**   | `RF09`, `RF12`, `RF32`, `RF35`, `RF45`         |       Medio       |  ⚪ Por iniciar en Flutter   |
| 🟡 **Media**   | **Administrador: Aprobación Parcial y Bandeja**  | `RF21`, `RF26`, `RF31`, `RF49`                 |       Medio       |    🟡 Por integrar en UI     |
| 🟡 **Media**   | **Mecánico: Seguridad, Perfil y Carrito**        | `RF04`, `RF06`, `RF07`, `RF13`, `RF14`         |       Bajo        |       🟢 Casi completo       |
| 🟢 **Baja**    | **Trazabilidad Documental y GitHub (Semana 13)** | Plantillas A, B y C / Issues                   |       Bajo        |    ⚪ Gestión documental     |

---

## 🗂️ 2. Desglose Detallado por Módulos y Requerimientos

### 🔔 Módulo 1: Sistema Centralizado de Notificaciones y Alertas Reactivas

_Centraliza la comunicación asíncrona entre Mecánicos, Almacenistas y Administradores._

| ID RF            | Tarea / Característica                   | Capa Técnica                  | Criterio de Aceptación / Definición de Hecho                                                                                                                                                                                                                |
| :--------------- | :--------------------------------------- | :---------------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **RF50**         | **Centro de Notificaciones Universal**   | Flutter (`lib/presentation/`) | Ícono de campana con badge dinámico en las 3 pantallas principales (`MecanicoMainScreen`, `AdminMainScreen`, `AlmacenMainScreen`). Vista/modal con pestañas _No leídas_ y _Leídas_, botón "Marcar todas como leídas" y consumo de `/api/v1/notificaciones`. |
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
| **RF32**         | **Carga de Foto en Mantenimiento de Repuestos** | Flutter (`admin/`)    | En `mantenimiento_catalogo_screen.dart`, habilitar selector con cámara o galería (`image_picker` + `FormData` Dio hacia `POST /api/v1/catalogo/{codParte}/imagen`). Validar peso máximo de 5 MB. |
| **RF44 / RF45**  | **Foto en Registro de Nuevas Herramientas**     | Flutter (`almacen/`)  | En `registrar_herramienta_screen.dart`, adjuntar foto antes de guardar la herramienta mediante `POST /api/v1/inventario/herramientas/{codHerramienta}/imagen`.                                   |
| **RF09 / RF12**  | **Despliegue Visual en Catálogo de Repuestos**  | Flutter (`mecanico/`) | Mostrar foto en tarjetas y en modal `detalle_repuesto_modal.dart`. Integrar `errorBuilder` corporativo como fallback ante fallos de conexión o ítems sin imagen.                                 |
| **RF35**         | **Identificación Visual por Escáner QR**        | Flutter (`scanner/`)  | Al escanear el QR en pañol, mostrar la foto registrada del ítem para validación visual rápida contra la herramienta física.                                                                      |

---

### 📦 Módulo 3: Almacén y Control de Pañol

_Optimización de recepción, despacho y control de herramientas._

| ID RF           | Tarea / Característica                         | Capa Técnica         | Criterio de Aceptación / Definición de Hecho                                                                                                                                                             |
| :-------------- | :--------------------------------------------- | :------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **RF33**        | **Catálogo General de Herramientas Agrupadas** | Flutter (`almacen/`) | Vista de herramientas agrupadas por modelo/nombre con stock total, cantidad disponible y en préstamo (evitando listados planos redundantes).                                                             |
| **RF38 - RF40** | **Flujo Ágil de Devolución tras QR**           | Flutter (`scanner/`) | Al escanear herramienta en estado `Prestada`, mostrar botón directo _"Registrar Devolución"_. Modal de inspección física (`Buen Estado`, `Con Averia`, `Incompleta`) y liquidar préstamo en 1 solo paso. |
| **RF43**        | **Alerta Visual de Mora en Pañol**             | Flutter (`almacen/`) | En la tabla de préstamos activos, pintar en rojo brillante con icono de advertencia las herramientas cuyo plazo de devolución esté vencido.                                                              |
| **Despacho**    | **Confirmación de Entrega de Solicitud**       | Flutter & Backend    | En el dashboard del almacenista, listar órdenes `APROBADA` o `APROBADA_PARCIAL` y habilitar botón de despacho que consume `PUT /api/v1/solicitudes/{id}/entregar` descontando stock real.                |

---

### 🛡️ Módulo 4: Administrador, Jerarquía, Auditoría y Solicitudes

_Blindaje de privilegios y control operativo del sistema._

| ID RF               | Tarea / Característica                           | Capa Técnica        | Criterio de Aceptación / Definición de Hecho                                                                                                                                                                         |
| :------------------ | :----------------------------------------------- | :------------------ | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Seguridad Admin** | **Protección Horizontal entre Administradores**  | Backend Spring Boot | Bloqueo estricto en backend si un admin intenta alterar/suspender a otro admin (`403 Forbidden`). Cuentas de jefatura gestionadas solo por TI / script. _(Completado en Fase 1)_.                                    |
| **RF21 / Orden**    | **Priorización de Solicitudes Atrasadas (FIFO)** | Flutter & Backend   | Las solicitudes pendientes más antiguas deben aparecer **arriba obligatoriamente** (orden ascendente por fecha/hora de emisión) para priorizar pedidos retrasados.                                                   |
| **RF26**            | **Aprobación / Rechazo Parcial Simplificado**    | Flutter & Backend   | Checkboxes/switches por cada línea del pedido (_aprobar/denegar_). **No exigir motivo por ítem**, basta con un solo motivo general si hay algún rechazo, consumiendo `PUT /api/v1/solicitudes/{id}/aprobar-parcial`. |
| **RF31 / RF49**     | **Filtros Avanzados de Auditoría Histórica**     | Flutter (`admin/`)  | Barra de búsqueda y filtros combinados: rango de fechas (`desde` - `hasta`), usuario/DNI, tipo de acción y código de máquina. Integrar lectura en vivo sin logs locales estáticos.                                   |
| **Personal**        | **Búsqueda y Filtros en Gestión de Usuarios**    | Flutter (`admin/`)  | Barra de búsqueda dinámica (por DNI o nombre) y selector/chips por rol (`MECANICO`, `ALMACENISTA`, `ADMINISTRADOR`).                                                                                                 |

---

### 👤 Módulo 5: Mecánico, Seguridad y Perfiles

_Experiencia de usuario de campo y endurecimiento de autenticación._

| ID RF           | Tarea / Característica                          | Capa Técnica          | Criterio de Aceptación / Definición de Hecho                                                                                                                                      |
| :-------------- | :---------------------------------------------- | :-------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **RF07**        | **Restricción de Edición en Mi Perfil**         | Flutter & Backend     | Campos DNI, nombres, apellidos y correo corporativo bloqueados en modo solo lectura para los 3 roles. Permitir editar únicamente el teléfono celular (9 dígitos).                 |
| **RF04 / RF06** | **Bloqueo Escalonado y Recuperación de Cuenta** | Flutter & Backend     | 3 fallos = bloqueo 5 min; 6 fallos = 15 min; 9 fallos = bloqueo total. Pantalla con cuenta regresiva reactiva y botón _"Solicitar Desbloqueo"_ que emite alerta a administración. |
| **RF13 / RF14** | **Revisión de Carrito y Prioridad**             | Flutter (`mecanico/`) | Selector claro de cantidad por repuesto en el carrito y prioridad visible (`BAJA`, `MEDIA`, `ALTA`) previo al envío de la orden (`RF17`).                                         |

---

### 📱 Módulo 6: Adaptación de Plataforma y Compilación APK Android

_Condiciones técnicas de arquitectura para compilación sin fallos y conexión en red física._

| Tarea Técnica                  | Archivo Afectado                           | Acción Requerida                                                                                                                                                       |
| :----------------------------- | :----------------------------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Eliminar dependencias Web**  | `reportes_analiticos_screen.dart`          | Remover `universal_html` / `dart:html` e implementar guardado compatible con Android (`path_provider` + `open_filex` o `share_plus`) para exportar reportes Excel/CSV. |
| **Tráfico HTTP en Red Local**  | `android/app/src/main/AndroidManifest.xml` | Agregar `android:usesCleartextTraffic="true"` dentro de `<application>` para permitir llamadas HTTP sin SSL a la IP local de la laptop.                                |
| **Parametrización de IP Host** | `api_constants.dart`                       | Cambiar `192.168.X.X` por la IP IPv4 real de la red Wi-Fi donde corre Spring Boot para conectar los celulares físicos sin depender de emuladores ni `localhost`.       |
| **Permisos de Cámara y Fotos** | `android/app/src/main/AndroidManifest.xml` | Declarar permisos de `CAMERA`, `READ_MEDIA_IMAGES` / `READ_EXTERNAL_STORAGE` requeridos por `image_picker`.                                                            |

---

### 📑 Módulo 7: Gestión Documental y Calidad (Semana 13)

_Alineación con las observaciones de revisión y requerimientos académicos/corporativos._

| :--------------------------------- | :------------------- |
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
  - [x] 2.5 Parametrización de Red: Configurar `api_constants.dart` con la IP del servidor Spring Boot (`192.168.18.57`)
  - [x] 2.6 Verificación de Build: Adaptaciones completas para el target Android APK sin dependencias exclusivas de navegador
  - [x] 2.7 Revision de ManualTestingRunner.java para averiguar que metodos, RF y otros faltan.
  - [x] 2.8 Actualizacion ManualTestingRunner.java con todos los RF y nuevas funciones (conmutable de mecanicos, modo TI)

- [x] Fase 2.9: Cierre de Calibración Backend (Ajustes Previos a UI)
  - [x] 2.9.1 Lógica de Devolución: Ajustar `PrestamoServiceImpl` para que herramientas devueltas como `INCOMPLETA` pasen a `En Mantenimiento` / retenidas con incidencia (no `Disponible`).
  - [x] 2.9.2 Historial de Préstamo: Actualizar `hora_retorno` en `prestamo_detalle` al devolver para que no figure siempre `"EN POSESION / ACTIVO"`.
  - [x] 2.9.3 Alerta de Mora: Al pasar préstamo a `MORA` en `verificarAlertasPrestamos()`, actualizar las herramientas en `herramienta` a `estado_actual = 'En Mora'` (RF43).
  - [x] 2.9.4 Evidencia Selfie en Recuperación: Agregar columna `foto_selfie_url` en `SolicitudRecuperacionClave`, soporte multipart en `POST /api/v1/auth/recuperar-clave` con guardado en `./uploads/selfies/` y exponer URL en `SolicitudRecuperacionResponse` para revisión visual del Administrador.

- [ ] Fase 3: Core Móvil, Red WiFi & Componentes Transversales (Android APK Ready)
  - [ ] 3.1 Eliminación limpia de `dart:html` / `universal_html` en `reportes_analiticos_screen.dart` asegurando exportación nativa de Excel/CSV a descargas del teléfono.
  - [ ] 3.2 Parametrización de red local: Centralizar en `api_constants.dart` la IP IPv4 dinámica de la laptop host y verificar `usesCleartextTraffic` en `AndroidManifest.xml`.
  - [ ] 3.3 Centro Universal de Notificaciones (`RF50`): Ícono de campana en AppBar con badge dinámico en los 3 módulos (`MecanicoMainScreen`, `AdminMainScreen`, `AlmacenMainScreen`) y pantalla/modal con pestañas _No leídas_ / _Leídas_ y botón _"Marcar todas como leídas"_.
  - [ ] 3.4 Seguridad, Bloqueo Escalonado y Recuperación con Selfie (`RF04`, `RF06`, `REQ-02`):
    - Diálogo de bloqueo temporal reactivo con cuenta regresiva escalonada: primeros 3 fallos espera 5 minutos; siguientes 3 fallos espera 10 minutos; tras 9 fallos se bloquea permanentemente (`BLOQUEADO`).
    - Formulario modal para solicitar restablecer contraseña con validación de DNI (8 dígitos) y teléfono (9 dígitos).
    - Captura obligatoria de foto selfie en vivo con la cámara frontal (`image_picker` con `CameraDevice.front`) enviada como evidencia al Administrador para fiscalizar identidad antes de asignar clave temporal.
  - [ ] 3.5 Pantalla Mi Perfil Universal (`RF07`, `REQ-01`): Bloqueo estricto de DNI, nombre, correo y cargo (`readOnly = true`); permitir editar únicamente el teléfono (9 dígitos) y cambio de contraseña propia.

- [ ] Fase 4: Flujos Operativos y Vistas Especializadas por Rol
  - [ ] 4.1 Módulo Mecánico:
    - [ ] 4.1.1 Despliegue de fotos de repuestos en catálogo y modal de ficha técnica (`RF09`, `RF12`) con fallback `errorBuilder` corporativo.
    - [ ] 4.1.2 Despliegue automático de la vista del carrito de repuestos al pulsar "Crear Solicitud" (`REQ-03`) y limpieza post-envío (`BUG-04`).
    - [ ] 4.1.3 Historial cromático personal de solicitudes (`RF19`, `RF20`) y consulta de herramientas prestadas bajo su custodia (`RF36`, `RF40`).
  - [ ] 4.2 Módulo Administrador:
    - [ ] 4.2.1 Ordenamiento FIFO de solicitudes pendientes (más antiguas arriba en la bandeja - `RF21`).
    - [ ] 4.2.2 Modal de aprobación parcial por ítem (`RF26`) con motivo general obligatorio si hay ítems denegados.
    - [ ] 4.2.3 Barra de búsqueda dinámica y selector por rol en Gestión de Personal (`admin/`).
    - [ ] 4.2.4 Filtros avanzados combinados en Auditoría (`RF31`): rango de fechas, usuario/DNI, acción y código de máquina.
    - [ ] 4.2.5 Selector fotográfico (`image_picker`) con cámara o galería en mantenimiento de repuestos (`RF32`).
  - [ ] 4.3 Módulo Almacenista (Ergonomía de Pañol Consolidada):
    - [ ] 4.3.1 Rediseño a 4 pestañas principales: Operaciones/Dashboard, Herramientas, Historial de Devoluciones y Mi Perfil.
    - [ ] 4.3.2 Botón Flotante Central (FAB) para Escáner QR inteligente: si la herramienta está `Disponible` abre _"Registrar Préstamo"_; si está `Prestada` abre _"Registrar Devolución e Inspección Física"_ (`Buen Estado`, `Con Avería`, `Incompleta`).
    - [ ] 4.3.3 Resaltado en rojo brillante con ícono de reloj en la tabla de préstamos para activos con mora vencida (`RF43`).
    - [ ] 4.3.4 Bandeja de despacho de repuestos aprobados (`PUT /api/v1/solicitudes/{id}/entregar`) con confirmación de entrega y descuento de stock en tiempo real.
    - [ ] 4.3.5 Selector fotográfico (`image_picker`) para registro de nuevas herramientas en pañol (`RF44`, `RF45`).

- [ ] Fase 5: Pruebas Integradas E2E en Red WiFi, Compilación APK y Despliegue
  - [ ] 5.1 Conectividad WiFi LAN: Validar ping y consumo HTTP entre los 3 celulares físicos y la laptop Spring Boot en el puerto 8080.
  - [ ] 5.2 Ciclo Cruzado E2E: Mecánico solicita $\rightarrow$ Admin aprueba/parcial $\rightarrow$ Almacenista despacha repuestos; Almacén presta herramienta $\rightarrow$ Mecánico custodia $\rightarrow$ Almacén liquida por QR.
  - [ ] 5.3 Compilación APK Release: Ejecutar `flutter build apk --release` verificando 0 advertencias críticas y 0 imports web.
  - [ ] 5.4 Instalación y Puesta en Marcha: Instalar el APK en los 3 dispositivos Android de Master Drilling Perú S.A. y verificar operatividad 100% offline de internet externo.
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

