# 📋 Matriz de Tareas Pendientes y Requerimientos Funcionales (SGSRA)

> **Documento de Control y Seguimiento Técnico**  
> **Sistema de Gestión de Solicitud de Repuestos y Almacén (SGSRA - Master Drilling)**  
> **Alcance:** Backend (Spring Boot 3.x / PostgreSQL 18) y Frontend Móvil (Flutter / Android APK)

---

## 📊 1. Resumen Ejecutivo de Estado y Prioridades

| Prioridad      | Módulo / Componente                               | Requerimientos Asociados                       | Esfuerzo Estimado |        Estado General        |
| :------------- | :------------------------------------------------ | :--------------------------------------------- | :---------------: |        :------------:        |
| 🔴 **Crítica** | **Adaptación Android APK & Plataforma**           | `Multiplataforma`, `Clean Build`, `Permisos`   |       Medio       |        🟡 En progreso        |
| 🔴 **Crítica** | **Centro de Notificaciones & Alertas UI**         | `RF46`, `RF47`, `RF48`, `RF50`                 |       Medio       | 🟡 Backend OK / UI Pendiente |
| 🟠 **Alta**    | **Pañol: Catálogo, QR Devolución y Despacho**     | `RF33`, `RF35`, `RF38`, `RF39`, `RF40`, `RF43` |       Medio       |        🟡 UI Parcial         |
| 🟠 **Alta**    | **Gestión Fotográfica Móvil (`image_picker`)**    | `RF09`, `RF12`, `RF32`, `RF35`, `RF45`         |       Medio       |  ⚪ Por iniciar en Flutter   |
| 🟡 **Media**   | **Administrador: Aprobación Parcial y Bandeja**   | `RF21`, `RF26`, `RF31`, `RF49`                 |       Medio       |    🟡 Por integrar en UI     |
| 🟡 **Media**   | **Mecánico: Seguridad, Perfil y Carrito**         | `RF04`, `RF06`, `RF07`, `RF13`, `RF14`         |       Bajo        |       🟢 Casi completo       |
| 🟢 **Baja**    | **Trazabilidad Documental y GitHub (Semana 13)**  | Plantillas A, B y C / Issues                   |       Bajo        |    ⚪ Gestión documental     |

---

## 🗂️ 2. Desglose Detallado por Módulos y Requerimientos

### 🔔 Módulo 1: Sistema Centralizado de Notificaciones y Alertas Reactivas

_Centraliza la comunicación asíncrona entre Mecánicos, Almacenistas y Administradores._

| ID RF | Tarea / Característica | Capa Técnica | Criterio de Aceptación / Definición de Hecho |
| :--------------- | :---------------------------------------------- | :---------------------------- | :------------------------------------------- |
| **RF50** | **Centro de Notificaciones Universal** | Flutter (`lib/presentation/`) | Ícono de campana con badge dinámico en las 3 pantallas principales (`MecanicoMainScreen`, `AdminMainScreen`, `AlmacenMainScreen`). Vista/modal con pestañas _No leídas_ y _Leídas_, botón "Marcar todas como leídas" y consumo de `/api/v1/notificaciones`. |
| **RF46** | **Alerta de Solicitud Emitida** | Backend & DB | Al crearse una solicitud (`RF17`), insertar notificación con rol destino `ADMINISTRADOR` ("Nueva solicitud #NUM generada"). _(Implementado en backend)_. |
| **RF47** | **Alerta de Decisión de Solicitud** | Flutter & Backend | Desplegar en la campana del `MECANICO` si su orden fue aprobada, rechazada o resuelta parcialmente. |
| **RF43 / RF48** | **Alerta de Mora en Préstamos de Pañol** | Flutter & Backend | Resaltar en rojo con advertencia en el pañol y enviar notificación preventiva al `MECANICO` y `ALMACENISTA`. |
| **RF41** | **Alerta de Extravío de Herramientas** | Flutter & Backend | Notificar al mecánico involucrado y remitir reporte directo al Administrador para reposición/sanción. |
| **Alerta Stock** | **Aviso Temprano de Repuesto Crítico** | Backend & Flutter | Al caer el `stock_actual` por debajo de `stock_minimo`, generar notificación automática para `ADMINISTRADOR` y `ALMACENISTA`. |

---

### 📷 Módulo 2: Gestión de Fotografías y Recursos Multimedia

_Soporte de evidencias visuales para repuestos y herramientas tanto en almacén como en taller._

| ID RF | Tarea / Característica | Capa Técnica | Criterio de Aceptación / Definición de Hecho |
| :--------------- | :---------------------------------------------- | :-------------------- | :------------------------------------------- |
| **DB & Storage** | **StorageService y Recursos Estáticos** | Backend Spring Boot | Subida física a `uploads/` y exposición web estática `/uploads/**`. _(Completado en Fase 1)_. |
| **RF32** | **Carga de Foto en Mantenimiento de Repuestos** | Flutter (`admin/`) | En `mantenimiento_catalogo_screen.dart`, habilitar selector con cámara o galería (`image_picker` + `FormData` Dio hacia `POST /api/v1/catalogo/{codParte}/imagen`). Validar peso máximo de 5 MB. |
| **RF44 / RF45** | **Foto en Registro de Nuevas Herramientas** | Flutter (`almacen/`) | En `registrar_herramienta_screen.dart`, adjuntar foto antes de guardar la herramienta mediante `POST /api/v1/inventario/herramientas/{codHerramienta}/imagen`. |
| **RF09 / RF12** | **Despliegue Visual en Catálogo de Repuestos** | Flutter (`mecanico/`) | Mostrar foto en tarjetas y en modal `detalle_repuesto_modal.dart`. Integrar `errorBuilder` corporativo como fallback ante fallos de conexión o ítems sin imagen. |
| **RF35** | **Identificación Visual por Escáner QR** | Flutter (`scanner/`) | Al escanear el QR en pañol, mostrar la foto registrada del ítem para validación visual rápida contra la herramienta física. |

---

### 📦 Módulo 3: Almacén y Control de Pañol

_Optimización de recepción, despacho y control de herramientas._

| ID RF | Tarea / Característica | Capa Técnica | Criterio de Aceptación / Definición de Hecho |
| :-------------- | :--------------------------------------------- | :-------------------- | :------------------------------------------- |
| **RF33** | **Catálogo General de Herramientas Agrupadas** | Flutter (`almacen/`) | Vista de herramientas agrupadas por modelo/nombre con stock total, cantidad disponible y en préstamo (evitando listados planos redundantes). |
| **RF38 - RF40** | **Flujo Ágil de Devolución tras QR** | Flutter (`scanner/`) | Al escanear herramienta en estado `Prestada`, mostrar botón directo _"Registrar Devolución"_. Modal de inspección física (`Buen Estado`, `Con Averia`, `Incompleta`) y liquidar préstamo en 1 solo paso. |
| **RF43** | **Alerta Visual de Mora en Pañol** | Flutter (`almacen/`) | En la tabla de préstamos activos, pintar en rojo brillante con icono de advertencia las herramientas cuyo plazo de devolución esté vencido. |
| **Despacho** | **Confirmación de Entrega de Solicitud** | Flutter & Backend | En el dashboard del almacenista, listar órdenes `APROBADA` o `APROBADA_PARCIAL` y habilitar botón de despacho que consume `PUT /api/v1/solicitudes/{id}/entregar` descontando stock real. |

---

### 🛡️ Módulo 4: Administrador, Jerarquía, Auditoría y Solicitudes

_Blindaje de privilegios y control operativo del sistema._

| ID RF | Tarea / Característica | Capa Técnica | Criterio de Aceptación / Definición de Hecho |
| :------------------ | :--------------------------------------------------- | :-------------------- | :------------------------------------------- |
| **Seguridad Admin** | **Protección Horizontal entre Administradores** | Backend Spring Boot | Bloqueo estricto en backend si un admin intenta alterar/suspender a otro admin (`403 Forbidden`). Cuentas de jefatura gestionadas solo por TI / script. _(Completado en Fase 1)_. |
| **RF21 / Orden** | **Priorización de Solicitudes Atrasadas (FIFO)** | Flutter & Backend | Las solicitudes pendientes más antiguas deben aparecer **arriba obligatoriamente** (orden ascendente por fecha/hora de emisión) para priorizar pedidos retrasados. |
| **RF26** | **Aprobación / Rechazo Parcial Simplificado** | Flutter & Backend | Checkboxes/switches por cada línea del pedido (_aprobar/denegar_). **No exigir motivo por ítem**, basta con un solo motivo general si hay algún rechazo, consumiendo `PUT /api/v1/solicitudes/{id}/aprobar-parcial`. |
| **RF31 / RF49** | **Filtros Avanzados de Auditoría Histórica** | Flutter (`admin/`) | Barra de búsqueda y filtros combinados: rango de fechas (`desde` - `hasta`), usuario/DNI, tipo de acción y código de máquina. Integrar lectura en vivo sin logs locales estáticos. |
| **Personal** | **Búsqueda y Filtros en Gestión de Usuarios** | Flutter (`admin/`) | Barra de búsqueda dinámica (por DNI o nombre) y selector/chips por rol (`MECANICO`, `ALMACENISTA`, `ADMINISTRADOR`). |

---

### 👤 Módulo 5: Mecánico, Seguridad y Perfiles

_Experiencia de usuario de campo y endurecimiento de autenticación._

| ID RF | Tarea / Característica | Capa Técnica | Criterio de Aceptación / Definición de Hecho |
| :-------------- | :--------------------------------------------------- | :-------------------- | :------------------------------------------- |
| **RF07** | **Restricción de Edición en Mi Perfil** | Flutter & Backend | Campos DNI, nombres, apellidos y correo corporativo bloqueados en modo solo lectura para los 3 roles. Permitir editar únicamente el teléfono celular (9 dígitos). |
| **RF04 / RF06** | **Bloqueo Escalonado y Recuperación de Cuenta** | Flutter & Backend | 3 fallos = bloqueo 5 min; 6 fallos = 15 min; 9 fallos = bloqueo total. Pantalla con cuenta regresiva reactiva y botón _"Solicitar Desbloqueo"_ que emite alerta a administración. |
| **RF13 / RF14** | **Revisión de Carrito y Prioridad** | Flutter (`mecanico/`) | Selector claro de cantidad por repuesto en el carrito y prioridad visible (`BAJA`, `MEDIA`, `ALTA`) previo al envío de la orden (`RF17`). |

---

### 📱 Módulo 6: Adaptación de Plataforma y Compilación APK Android

_Condiciones técnicas de arquitectura para compilación sin fallos y conexión en red física._

| Tarea Técnica | Archivo Afectado | Acción Requerida |
| :---------------------------- | :----------------------------------------- | :--------------- |
| **Eliminar dependencias Web** | `reportes_analiticos_screen.dart` | Remover `universal_html` / `dart:html` e implementar guardado compatible con Android (`path_provider` + `open_filex` o `share_plus`) para exportar reportes Excel/CSV. |
| **Tráfico HTTP en Red Local** | `android/app/src/main/AndroidManifest.xml` | Agregar `android:usesCleartextTraffic="true"` dentro de `<application>` para permitir llamadas HTTP sin SSL a la IP local de la laptop. |
| **Parametrización de IP Host**| `api_constants.dart` | Cambiar `192.168.X.X` por la IP IPv4 real de la red Wi-Fi donde corre Spring Boot para conectar los celulares físicos sin depender de emuladores ni `localhost`. |
| **Permisos de Cámara y Fotos**| `android/app/src/main/AndroidManifest.xml` | Declarar permisos de `CAMERA`, `READ_MEDIA_IMAGES` / `READ_EXTERNAL_STORAGE` requeridos por `image_picker`. |

---

### 📑 Módulo 7: Gestión Documental y Calidad (Semana 13)

_Alineación con las observaciones de revisión y requerimientos académicos/corporativos._

| :--------------------------------- | :-------------------                                                                                                                                                   |
| **Creación de Issues en GitHub**   | Registrar issues con etiqueta `requerimientos` para observaciones de Plantilla A y B. Mapear unificaciones (`RF02/RF05/RF06 -> RF01`, `RF37 -> RF36`, `RF40 -> RF38`). |
| **Depuración de Alcance (`RF28`)** | Marcar formalmente `RF28` (_"Marcar orden como contactada"_) como fuera de alcance / descartado, al pertenecer al flujo externo de compras.                            |

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

- [ ] Fase 2: Adaptaciones Flutter para Android APK (Arquitectura & Compilación)
  - [ ] 2.1 Paquetes en `pubspec.yaml`: Agregar `image_picker: ^1.1.2`, `path_provider: ^2.1.4`, `open_filex: ^4.5.0`
  - [ ] 2.2 Desacoplar Web: Reemplazar descarga de reportes con `universal_html` en `reportes_analiticos_screen.dart` por guardado móvil en carpeta temporal/descargas y apertura automática con `open_filex`
  - [ ] 2.3 Red Android: Configurar `android:usesCleartextTraffic="true"` en `AndroidManifest.xml` para permitir llamadas HTTP a la IP local de desarrollo
  - [ ] 2.4 Permisos Nativos: Declarar permisos para lectura de almacenamiento e imágenes en `AndroidManifest.xml`
  - [ ] 2.5 Parametrización de Red: Configurar `api_constants.dart` con la IP del servidor Spring Boot
  - [ ] 2.6 Verificación de Build: Ejecutar `flutter analyze` y asegurar cero advertencias de compilación para target Android

- [ ] Fase 3: UI & Experiencia de Usuario Móvil (Flujos Operativos)
  - [ ] 3.1 Notificaciones: Componente campana con badge reactivo en los 3 paneles + vista de historial
  - [ ] 3.2 Pañol: Catálogo agrupado de herramientas y alerta roja de mora en préstamos
  - [ ] 3.3 Pañol: Botón directo de devolución al escanear QR (`Buen Estado`, `Avería`, `Incompleta`)
  - [ ] 3.4 Pañol: Bandeja de despacho físico de repuestos aprobados (`PUT /entregar`)
  - [ ] 3.5 Admin: Ordenamiento FIFO de solicitudes pendientes (más antiguas arriba)
  - [ ] 3.6 Admin: Modal de aprobación/rechazo parcial con motivo general simplificado
  - [ ] 3.7 Admin: Filtros combinados en Auditoría y barra de búsqueda en Personal
  - [ ] 3.8 Mecánico: Selector de foto (cámara/galería) en catálogo y registro de herramientas
  - [ ] 3.9 Perfil: Bloquear edición de DNI, nombres y correo en Mi Perfil (solo teléfono editable)
  - [ ] 3.10 Auth: Pantalla/diálogo de bloqueo escalonado con cuenta regresiva y solicitud de desbloqueo
```
