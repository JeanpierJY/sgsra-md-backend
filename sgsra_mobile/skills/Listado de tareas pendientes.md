# 📋 Matriz de Tareas Pendientes y Requerimientos Funcionales (SGSRA)

> **Documento de Control y Seguimiento Técnico**  
> **Sistema de Gestión de Solicitud de Repuestos y Almacén (SGSRA - Master Drilling)**  
> **Alcance:** Backend (Spring Boot 3.x / PostgreSQL 18) y Frontend Móvil (Flutter / Android APK)

---

## 📊 1. Resumen Ejecutivo de Estado y Prioridades

| Prioridad | Módulo / Componente | Requerimientos Asociados | Esfuerzo Estimado | Estado General |
| :--- | :--- | :--- | :---: | :---: |
| 🔴 **Crítica** | **Notificaciones y Alertas Reactivas** | `RF46`, `RF47`, `RF48`, `RF50` | Alto | 🟡 Pendiente integración E2E |
| 🔴 **Crítica** | **Seguridad, Perfiles y Jerarquía Admin** | `RF04`, `RF06`, `RF07` | Medio | 🟡 Pendiente reglas backend |
| 🟠 **Alta** | **Gestión de Imágenes (Multipar / Storage)** | `RF09`, `RF12`, `RF32`, `RF35`, `RF45` | Medio | ⚪ Por iniciar |
| 🟠 **Alta** | **Pañol: Catálogo, QR Devolución y Despacho** | `RF33`, `RF35`, `RF38`, `RF39`, `RF40`, `RF43` | Alto | 🟡 Parcial en UI |
| 🟡 **Media** | **Administrador: Aprobación Parcial y Auditoría**| `RF26`, `RF31`, `RF49` | Medio | 🟡 Endpoints parciales |
| 🟡 **Media** | **Mecánico: Prioridad y Ficha Técnica** | `RF12`, `RF13`, `RF14`, `RF17` | Bajo | 🟢 Casi completo |
| 🟢 **Baja** | **Trazabilidad Documental y GitHub (Semana 13)** | Plantillas A, B y C / Issues | Bajo | ⚪ Gestión documental |

---

## 🗂️ 2. Desglose Detallado por Módulos y Requerimientos

### 🔔 Módulo 1: Sistema Centralizado de Notificaciones y Alertas
*Centraliza la comunicación asíncrona entre Mecánicos, Almacenistas y Administradores.*

| ID RF | Tarea / Característica | Capa Técnica | Criterio de Aceptación / Definición de Hecho |
| :--- | :--- | :--- | :--- |
| **RF50** | **Centro de Notificaciones Universal** | Flutter (`lib/presentation/`) | Ícono de campana con badge dinámico en las 3 pantallas principales (`MecanicoMainScreen`, `AdminMainScreen`, `AlmacenMainScreen`). Modal/vista con tabs: *No leídas* y *Leídas*, botón "Marcar todas como leídas". |
| **RF46** | **Alerta de Solicitud Emitida** | Backend & DB | Al crearse una solicitud (`RF17`), insertar notificación con rol destino `ADMINISTRADOR` ("Nueva solicitud #NUM generada por operario X"). |
| **RF47** | **Alerta de Decisión de Solicitud** | Backend & DB | Al aprobarse, rechazarse o aprobarse parcialmente una solicitud (`RF23`, `RF24`, `RF26`), notificar al `MECANICO` solicitante con detalle y motivo. |
| **RF43 / RF48** | **Alerta de Mora en Préstamos de Pañol** | Backend & Flutter | Marcar préstamos vencidos en tabla física. Mostrar alerta roja brillante en dashboard del almacenista y push/alerta preventiva al mecánico custodio. |
| **RF41** | **Alerta de Extravío de Herramientas** | Backend & Flutter | Al registrar pérdida/extravío, notificar al mecánico responsable y generar expediente automático al Administrador para reposición/sanción. |
| **Alerta Stock** | **Aviso Temprano de Repuesto Crítico** | Backend | Al caer el `stock_actual` por debajo de `stock_minimo`, generar alerta automática para `ADMINISTRADOR` y `ALMACENISTA`. |

---

### 📷 Módulo 2: Gestión de Fotografías y Recursos Multimedia
*Soporte de evidencias visuales para repuestos y herramientas tanto en almacén como en terreno.*

| ID RF | Tarea / Característica | Capa Técnica | Criterio de Aceptación / Definición de Hecho |
| :--- | :--- | :--- | :--- |
| **DB & Storage** | **Columna `imagen_url` y Almacenamiento Local** | PostgreSQL & Spring Boot | Agregar `imagen_url VARCHAR(255)` en tablas `repuesto` y `herramienta`. Configurar `StorageService` (`uploads/imagenes/`) y exponer `/uploads/**` como recurso estático WebMvc. |
| **RF32** | **Carga de Foto en Mantenimiento de Repuestos** | Spring Boot & Flutter | En `mantenimiento_catalogo_screen.dart`, habilitar subida vía cámara o galería (`image_picker` + `FormData` Dio). Validar peso máximo de 5 MB. |
| **RF44 / RF45** | **Foto en Registro de Nuevas Herramientas** | Spring Boot & Flutter | En `registrar_herramienta_screen.dart`, adjuntar captura fotográfica obligatoria antes de generar el código QR físico. |
| **RF09 / RF12** | **Despliegue Visual en Catálogo de Repuestos** | Flutter | Mostrar `Image.network` en tarjetas y modal `detalle_repuesto_modal.dart`. Integrar `errorBuilder` con ícono corporativo fallback ante fallos de red. |
| **RF35** | **Identificación Visual por Escáner QR** | Flutter | Al escanear el QR en pañol, mostrar la foto registrada del ítem para validación física rápida contra el objeto en mano. |

---

### 📦 Módulo 3: Almacén y Control de Pañol
*Optimización de recepción, despacho y control de herramientas.*

| ID RF | Tarea / Característica | Capa Técnica | Criterio de Aceptación / Definición de Hecho |
| :--- | :--- | :--- | :--- |
| **RF33** | **Catálogo General de Herramientas Agrupadas** | Flutter (`almacen/`) | Vista de herramientas agrupadas por modelo/nombre con stock total y unidades disponibles/en préstamo (evitando listados planos redundantes). |
| **RF38 - RF40** | **Flujo Ágil de Devolución tras QR** | Flutter (`scanner/`) | Al escanear herramienta en estado `PRESTADO`, mostrar botón directo *"Procesar Devolución"*. Abrir modal de condición (`Buen Estado`, `Con Avería`, `Incompleta`) y liquidar préstamo en 1 toque. |
| **RF43** | **Alerta Visual de Mora en Pañol** | Flutter | En tabla de préstamos activos, destacar en fondo o borde rojo intermitente/alerta las filas con tiempo límite superado. |
| **Despacho** | **Confirmación de Entrega de Solicitud** | Spring Boot & Flutter | Bandeja para que el Almacenista consulte solicitudes en estado `APROBADA` o `APROBADA_PARCIAL`, confirme entrega y descuente `stock_actual` pasando a `ENTREGADA`. |

---

### 🛡️ Módulo 4: Administrador, Jerarquía y Auditoría
*Blindaje de privilegios y control operativo del sistema.*

| ID RF | Tarea / Característica | Capa Técnica | Criterio de Aceptación / Definición de Hecho |
| :--- | :--- | :--- | :--- |
| **Seguridad Admin** | **Protección Horizontal entre Administradores** | Spring Boot | En `AutenticacionServiceImpl`, impedir que un `ADMINISTRADOR` modifique, bloquee o resetee la contraseña de otro `ADMINISTRADOR`. Retornar `403 Forbidden`. Cuentas admin gestionadas por script TI. |
| **RF26** | **Aprobación / Rechazo Parcial de Solicitudes** | Flutter & Spring Boot | Interfaz con switches/checkboxes por cada línea del pedido. Exigir motivo de rechazo individual para repuestos denegados y despachar `PUT /api/v1/solicitudes/{id}/aprobar-parcial`. |
| **RF31 / RF49** | **Filtros Avanzados de Auditoría Histórica** | Spring Boot & Flutter | Barra de búsqueda con filtros combinados: rango de fechas (`desde` - `hasta`), usuario/DNI, tipo de acción y código de máquina. Corregir tipos en consulta PostgreSQL. |
| **Personal** | **Búsqueda y Filtros en Gestión de Usuarios** | Flutter (`admin/`) | Filtro dinámico en lista de usuarios por DNI, nombre y selector de rol (`MECANICO`, `ALMACENISTA`, `ADMINISTRADOR`). |

---

### 👤 Módulo 5: Mecánico, Seguridad y Perfiles
*Experiencia de usuario de campo y endurecimiento de autenticación.*

| ID RF | Tarea / Característica | Capa Técnica | Criterio de Aceptación / Definición de Hecho |
| :--- | :--- | :--- | :--- |
| **RF07** | **Restricción de Edición en Mi Perfil** | Flutter & Spring Boot | Bloquear campos sensibles (DNI, nombres, apellidos y correo corporativo en modo sólo lectura). Permitir editar únicamente el teléfono celular (9 dígitos). |
| **RF04 / RF06** | **Bloqueo Escalonado de Intentos Fallidos** | Spring Boot & Flutter | 3 fallos = bloqueo 5 min; 6 fallos = 15 min; 9 fallos = bloqueo total. Pantalla con cuenta regresiva y botón *"Solicitar Desbloqueo"* que genera alerta al Administrador. |
| **RF13 / RF14** | **Revisión de Carrito y Prioridad** | Flutter | Selección visible de cantidad por repuesto en carrito y selector de prioridad (`BAJA`, `MEDIA`, `ALTA`) previo al despacho del pedido. |

---

### 📱 Módulo 6: Adaptación de Plataforma y Compilación APK
*Condiciones técnicas para despliegue en celulares físicos Android.*

| Tarea Técnica | Archivo Afectado | Acción Requerida |
| :--- | :--- | :--- |
| **Eliminar dependencias Web** | `reportes_analiticos_screen.dart` | Reemplazar `dart:html` por `path_provider` + `open_filex` / `share_plus` para exportar Excel/CSV en almacenamiento móvil. |
| **Tráfico HTTP Local** | `android/app/src/main/AndroidManifest.xml` | Agregar `android:usesCleartextTraffic="true"` para llamadas a la IP de red local sin SSL. |
| **Configuración de IP** | `api_constants.dart` | Parametrizar la IP IPv4 de la máquina host (ej. `http://192.168.x.x:8080/api/v1`) en lugar de `localhost`. |

---

### 📑 Módulo 7: Gestión Documental y Calidad (Semana 13)
*Alineación con las observaciones de revisión y requerimientos académicos/corporativos.*

| Tarea | Detalle de Ejecución |
| :--- | :--- |
| **Creación de Issues en GitHub** | Registrar issues con etiqueta `requerimientos` para observaciones de Plantilla A y B. Mapear unificaciones (`RF02/RF05/RF06 -> RF01`, `RF37 -> RF36`, `RF40 -> RF38`). |
| **Depuración de Alcance (`RF28`)** | Marcar formalmente `RF28` (*"Marcar orden como contactada"*) como fuera de alcance / descartado, al pertenecer al flujo externo de compras. |
| **Trazabilidad Plantilla C** | Completar la columna de números de Issue vinculados en la matriz de sustentación. |

---

## 🔄 3. Checklist Rápido de Ejecución

```markdown
- [ ] Fase 1: PostgreSQL 18 & Backend Core
  - [ ] Script DDL para tabla `notificacion` y columna `imagen_url`
  - [ ] Implementación de `StorageService` para multipart de imágenes
  - [ ] Regla de jerarquía admin en `AutenticacionServiceImpl`
  - [ ] Endpoints de notificaciones, bloqueo escalonado y aprobación parcial

- [ ] Fase 2: Adaptaciones Flutter para Android APK
  - [ ] Remover `dart:html` de reportes analíticos
  - [ ] Configurar `usesCleartextTraffic="true"` en `AndroidManifest.xml`
  - [ ] Integrar `image_picker` en catálogo y registro de herramientas

- [ ] Fase 3: UI & Experiencia de Usuario Móvil
  - [ ] Centro de notificaciones con badge en los 3 perfiles
  - [ ] Catálogo agrupado de herramientas y alerta de mora en pañol
  - [ ] Devolución rápida de herramienta al escanear QR
  - [ ] Bloqueo de edición de DNI/Correo en Mi Perfil
```

Para este proyecto se esta usando Github Desktop, no se usaran comandos git