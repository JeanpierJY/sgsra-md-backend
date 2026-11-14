# Registro de Cambios — Correcciones Backend y Frontend (SGSRA-MD)

Este documento resume todo lo que se cambió en el backend (Spring Boot) y en la app móvil (Flutter) para resolver las observaciones de [dudasbackend.md](dudasbackend.md) y [dudasfrontend.md](dudasfrontend.md). También explica cómo se recuperó el trabajo después del conflicto de git del 14/11/2026.

> **Estado:** todo está en la rama `SG_rama`, **sin commit**. El backend compila y `flutter analyze` no muestra errores ni advertencias. **Falta la prueba manual en dispositivo.**

---

## Índice

1. [Resumen](#1-resumen)
2. [Cambios en el backend](#2-cambios-en-el-backend)
3. [Cambios en la app móvil](#3-cambios-en-la-app-móvil)
4. [Observación → solución](#4-observación--solución)
5. [Recuperación tras el conflicto de git](#5-recuperación-tras-el-conflicto-de-git)
6. [Archivos nuevos, modificados y eliminados](#6-archivos-nuevos-modificados-y-eliminados)
7. [Cómo probar](#7-cómo-probar)
8. [Pendientes y riesgos](#8-pendientes-y-riesgos)

---

## 1. Resumen

| Bloque | Qué se hizo |
|---|---|
| Observaciones del backend ([dudasbackend.md](dudasbackend.md)) | Perfil (REQ-01), flujo formal de recuperación de contraseña (REQ-02), jerarquía de administradores (SEC-01), orden del catálogo (BUG-02), descuento atómico al despachar (BUG-03), matriz de notificaciones (6.1–6.3) y control de mora a 7 días. Esto quedó en el commit **128ee11 "Correcciones del backend"**. |
| Observaciones del frontend ([dudasfrontend.md](dudasfrontend.md)) | AUT-01 a AUT-03, ADM-01 a ADM-04, MEC-01 a MEC-03, PRE-01 y ALM-01. Requirieron cambios en la app y también en el backend. |
| Consola de pruebas | Edición y visualización del teléfono del almacenista. |
| Restauración | Los cambios se recuperaron y se fusionaron con los commits nuevos del equipo, sin perder el trabajo de ninguno. |

---

## 2. Cambios en el backend

Ruta base: `sgsra-md/src/main/java/com/masterdrilling/sgsramd/`

### 2.1 Autenticación y bloqueo de cuenta (AUT-01)

- **Problema:** al fallar la contraseña, el contador de intentos quedaba en 2 y la cuenta nunca se bloqueaba.
- **Causa:** `autenticar()` lanzaba una excepción dentro de una transacción. Spring deshacía la transacción, y con ella el intento fallido que se acababa de guardar.
- **Solución:** `@Transactional(noRollbackFor = {AccesoDenegadoException.class, CuentaBloqueadaException.class})` en `AutenticacionServiceImpl.autenticar`. Además, `CuentaBloqueadaException`, `ErrorDetalle` y `GlobalExceptionHandler` devuelven el tiempo de espera y los intentos restantes.

### 2.2 Recuperación de contraseña (REQ-02, AUT-02)

- El operario pide la recuperación con **DNI + teléfono registrado** y, opcionalmente, una **selfie**.
- **Seguridad:** el teléfono debe coincidir con el registrado. Durante la recuperación nunca se registra un teléfono nuevo; antes, un tercero podía fijar su propio número en cuentas que no tenían teléfono. Los intentos fallidos quedan en auditoría (`VALIDACION_TELEFONO_FALLIDA`).
- Las cuentas de Administrador no pueden usar este flujo; las gestiona TI.
- El administrador **solo aprueba o rechaza** solicitudes pendientes:
  - `GET /auth/recuperaciones?estado=`
  - `PUT /auth/recuperaciones/{id}/aprobar?nuevaClave&correoAdmin`
  - `PUT /auth/recuperaciones/{id}/rechazar?motivo&correoAdmin`
- `SolicitudRecuperacionResponse` incluye `fotoSelfieUrl` y `fotoPerfilUrl`, para comparar la selfie con la foto registrada.
- Se mantienen también los métodos de recuperación por **correo** que agregó el equipo.

### 2.3 Mi Perfil y foto de perfil (REQ-01, AUT-03)

- `GET /auth/perfil` devuelve el nuevo `PerfilResponse`: DNI, nombre, correo, rol, teléfono, sede (almacenista) y `fotoPerfilUrl`.
- `PUT /auth/perfil`: solo se edita el **teléfono** (9 dígitos). El nombre y el correo no se pueden cambiar.
- **Nuevo:** `POST /auth/perfil/foto` (multipart, parte `foto`) guarda la imagen en `uploads/perfiles/`.
- `Usuario` tiene la columna nueva `foto_perfil_url`, que Hibernate crea solo con `ddl-auto=update`.
- `Almacenista` tiene la columna `telefono`.

### 2.4 Gestión de personal (ADM-01, SEC-01)

- **Problema:** las ediciones parecían guardarse pero se perdían. El formulario de la app tenía el teléfono fijo en `987654321` y el teléfono del almacenista nunca se guardaba.
- **Solución en `actualizarUsuarioPorDni`:**
  - Guarda nombre y teléfono en `usuario`, `mecanico` y `almacenista`, y el nombre en `administrador`.
  - Registra en auditoría `DATOS_PERSONAL_ACTUALIZADOS`.
- `listarUsuarios` ordena por nombre y devuelve `telefono`, `intentosFallidos` y `fotoPerfilUrl` (en `UsuarioResumenResponse`).
- **SEC-01:** `validarObjetivoNoAdministrador` impide que un administrador modifique, suspenda o cambie la clave de otro administrador desde la app. Desde la consola TI sí se puede.

### 2.5 Auditoría (ADM-02)

- **Problema:** la consulta usaba `CAST(:param AS ...) IS NULL`, que PostgreSQL rechaza con el error **42P18**. La pantalla lo ocultaba mostrando 6 registros de ejemplo escritos en el código.
- **Solución:** `AuditoriaOperacion_DAO` reemplaza `filtrarAuditoria` por `filtrarPorFechas` y `filtrarPorTermino`, ordenadas por fecha descendente.
- `AuditoriaServiceImpl` aplica fechas por defecto y completa `nombreUsuario` y `rolUsuario` (campos nuevos de `AuditoriaResponse`).

### 2.6 Catálogo y stock (BUG-02, MEC-01)

- **BUG-02:** el listado no tenía un orden fijo y los repuestos nuevos o editados quedaban fuera de la primera página. Ahora se ordena por código (`ordenarPorCodigo`).
- **MEC-01:** `Repuesto_DAO.sumarCantidadReservada(codParte)` suma lo pedido en solicitudes *Pendientes*, *Aprobadas* o *Aprobadas parciales*, sin contar los ítems rechazados. `RepuestoResponse` ahora incluye `stockReservado`.

### 2.7 Solicitudes y notificaciones

| Evento | Destinatario | Tipo |
|---|---|---|
| Nueva solicitud de prioridad ALTA | Administrador | `PRIORIDAD_ALTA` |
| Cualquier otra solicitud nueva (ADM-04) | Administrador ("Nueva Solicitud Pendiente") | `NUEVA_SOLICITUD` |
| Aprobación total o parcial | Mecánico | `SOLICITUD_APROBADA` |
| Aprobación de prioridad ALTA | Almacenista ("Despacho Urgente") | `PRIORIDAD_ALTA` |
| Rechazo (MEC-03) | Mecánico, **con el motivo** | — |
| Despacho de repuestos (ALM-01) | Mecánico ("Repuestos Entregados") | `APROBACION` |
| Repuesto llega a su stock mínimo al despachar | Administrador y Almacenista | `STOCK_MINIMO` |
| Herramienta extraviada | Administrador y último custodio | `EXTRAVIO` |

> Los tipos se normalizan a los 7 valores que acepta la tabla `notificacion` (`normalizarTipoAlerta`, aporte del equipo).

### 2.8 Despacho de repuestos (BUG-03, ALM-01)

- `PUT /solicitudes/{num}/entregar?correoAlmacenista=` descuenta el stock de **todos** los ítems aprobados en una sola transacción: si falta stock de uno, no se descuenta ninguno.
- La solicitud pasa a `ENTREGADA` y queda en auditoría (`ENTREGA_DESPACHO_REPUESTOS`).
- `DetalleSolicitudResponse.ItemDetalleResponse` incluye `stockActual` y `stockMinimo`, para que el almacenista vea cómo queda el stock antes de confirmar.

### 2.9 Préstamos de herramientas (PRE-01, mora)

- `PrestamoResumenResponse` agrega:
  - Entrega: `nombreAlmacenistaEntrega`.
  - Devolución: `devolucionNum`, `fechaDevolucion`, `horaRetorno`, `nombreAlmacenistaRecepcion` y `detalleIncidencia`.
  - Por herramienta: `estadoAlEntregar` y `estadoAlDevolver`.
- **Control de vencimiento:**
  - Al día 6, aviso preventivo al mecánico.
  - Al día 7, el préstamo pasa a **MORA** y se avisa al almacenista.
  - Lo ejecuta `PrestamoVencimientoService` todos los días a las 07:00 (ver [riesgos](#8-pendientes-y-riesgos)).

### 2.10 Consola de pruebas (`ManualTestingRunner`)

- Se usa la versión del equipo (calibración e2e).
- Se agregó:
  - **4.3 Editar usuario:** también guarda el teléfono del **almacenista**.
  - **10. Mi Perfil (Almacenista):** muestra el teléfono y agrega la opción **10.3 Editar teléfono de contacto**.

---

## 3. Cambios en la app móvil

Ruta base: `sgsra_mobile/lib/`. Se respetó el diseño original: mismos colores (`AppColors`), tarjetas y barras.

### 3.1 Componentes compartidos nuevos

| Archivo | Uso |
|---|---|
| `core/session/session_manager.dart` | Datos de la sesión activa: `correo_usuario`, `dni_usuario`, `rol_usuario`, etc. |
| `core/widgets/detalle_solicitud_sheet.dart` | Hoja con el detalle de una solicitud: repuestos, estado y **motivo del rechazo** en rojo. Si la abre el administrador y la solicitud está pendiente, muestra Aprobar y Rechazar (el rechazo pide al menos 15 caracteres). |
| `core/widgets/detalle_prestamo_sheet.dart` | Hoja **Antes / Después** de un préstamo: datos de la entrega y de la devolución, estado de cada herramienta y observaciones. |
| `notificaciones/presentation/widgets/notificacion_bell.dart` | Campana con el contador de notificaciones no leídas en la barra superior. |
| `core/utils/file_saver*.dart` | Descarga de reportes en móvil y web. |

### 3.2 Todos los roles

- **Mi Perfil** (`auth/presentation/screens/mi_perfil_screen.dart`): una sola pantalla para los 3 roles, que reemplaza a `editar_perfil_screen.dart`.
  - Los datos institucionales son de solo lectura.
  - Se pueden editar el teléfono y la contraseña.
  - **Foto de perfil** con ícono de cámara: se elige entre cámara o galería.
- **Notificaciones** (`centro_notificaciones_screen.dart`): al tocar una notificación se marca como leída y se navega a su destino.
  - Si tiene un código de solicitud: el **administrador** ve el detalle con Aprobar/Rechazar, el **almacenista** va a la hoja de despacho y el **mecánico** ve el detalle.
  - Si es una recuperación de contraseña: el administrador abre la pantalla de recuperaciones.
- **Login** (`login_screen.dart`, `auth_bloc.dart`): muestra los intentos restantes y el bloqueo con su tiempo de espera. La recuperación envía DNI, teléfono y selfie.
- **Las pestañas se recargan al volver a ellas:** antes se cargaban una sola vez y mostraban datos viejos. Ahora cada pantalla se vuelve a crear en cada visita.

### 3.3 Administrador

| Pantalla | Cambios |
|---|---|
| **Recuperación de contraseñas** (nueva, `solicitudes_recuperacion_screen.dart`) | Pestañas *Pendientes* e *Historial*. Muestra la foto de perfil al lado de la selfie. **Aprobar** genera una clave temporal (`Md` + 3 letras + 5 dígitos) que se puede copiar. **Rechazar** pide un motivo de al menos 10 caracteres. |
| **Personal** (`gestion_personal_screen.dart`) | Aviso amarillo y ícono 🔐 si hay recuperaciones pendientes. Buscador, filtro por rol y foto de cada trabajador. Al editar se muestra el **teléfono real** (oculto para administradores), aparece un indicador mientras guarda y la lista se recarga. |
| **Auditoría** (`auditoria_screen.dart`) | Se quitaron los datos de ejemplo. Las acciones aparecen en lenguaje claro (p. ej. "Aprobó una solicitud") con usuario y rol, **agrupadas por día** (Hoy/Ayer). Filtros por categoría (con íconos y colores) y por periodo (Hoy / 7 días / 30 días / 6 meses). Cada registro se despliega para ver el detalle y el hash SHA-256, que se puede copiar. Botón "Cargar más". |
| **Bandeja de Solicitudes** | Usaba un correo de administrador fijo; ahora usa el de la sesión. |

### 3.4 Mecánico

| Pantalla | Cambios |
|---|---|
| **Catálogo** (`catalogo_screen.dart`) | Chips de stock: **disponibles**, **reservados**, **en su carrito** y *Físico/Mín*. No permite agregar más de lo que realmente está disponible. |
| **Carrito** (`carrito_pedido_screen.dart`) | Al enviar se abre un diálogo de éxito con el código, el estado *Pendiente*, la aclaración de que el stock queda reservado hasta la entrega y los botones **Seguir comprando** y **Ver detalle**. |
| **Pedidos** (`historial_solicitudes_screen.dart`) | Filtros por estado con contador. Al tocar una solicitud se abre su detalle; las rechazadas indican "Toque para ver el motivo del rechazo". La solicitud recién creada se abre sola. |
| **Herramientas** (`herramientas_prestadas_screen.dart`) | Secciones *En su poder* e *Historial de préstamos*. Al tocar un préstamo se abre el detalle **Antes / Después**. |

### 3.5 Almacenista

| Pantalla | Cambios |
|---|---|
| **Despacho** (nueva, `despacho_screen.dart`) | Dos pestañas: **Repuestos** (con contador rojo de pendientes) y **Herramientas** (la salida de pañol de siempre). |
| **Repuestos por solicitud** (nueva, `despacho_repuestos_tab.dart`) | Vistas *Por despachar* y *Entregadas*. Las urgentes van primero, con aviso rojo. Cada tarjeta tiene una franja del color de la prioridad y el botón **Preparar despacho**. |
| **Hoja de despacho** | Muestra a quién se entrega (nombre, DNI, teléfono) y una **lista de repuestos para marcar** ("Marcar todos" disponible). Cada repuesto indica `Stock: 18 → 17`, en naranja si llega al mínimo y en rojo si no alcanza. Los rechazados aparecen tachados. **Confirmar despacho** solo se activa con todo marcado y stock suficiente; pide confirmación y muestra el resumen del stock actualizado. |
| **Dashboard** | Al tocar un préstamo se abre el detalle Antes / Después. |
| **Retorno** (`devolucion_inspeccion_screen.dart`) | Al cerrar una devolución aparece un aviso de confirmación y luego la hoja Antes / Después. |

---

## 4. Observación → solución

| ID | Observación | Causa encontrada | Solución |
|---|---|---|---|
| AUT-01 | El contador de intentos se queda en 2 | La transacción deshacía el intento fallido guardado | `noRollbackFor` en el login |
| AUT-02 | El admin no puede atender la recuperación | Los endpoints existían, pero la app no tenía pantalla | Pantalla *Recuperación de contraseñas* |
| AUT-03 | Foto de perfil | No existía | Foto en *Mi Perfil*, visible al lado de la selfie |
| ADM-01 | La edición de personal no se guarda | Teléfono fijo en el formulario y teléfono del almacenista sin guardar | Guarda en todas las tablas, muestra el teléfono real y recarga |
| ADM-02 | La auditoría no registra acciones | Error 42P18 en la consulta; la app mostraba datos de ejemplo | Consulta corregida y recarga al entrar |
| ADM-03 | Auditoría difícil de leer | — | Lenguaje claro, agrupación por día y filtros |
| ADM-04 | Abrir la solicitud desde su notificación | No había navegación | Tocar la notificación abre la solicitud |
| MEC-01 | El stock no cambia al solicitar | El stock físico baja recién al despachar | Se muestran disponibles y reservados; el stock baja al despachar (ALM-01) |
| MEC-02 | La solicitud no aparece en Pedidos | La pestaña no se recargaba | Recarga al entrar y botón *Ver detalle* |
| MEC-03 | No se ve el motivo del rechazo | El motivo solo estaba en el endpoint de detalle | Hoja de detalle con el motivo en rojo |
| PRE-01 | Falta el antes y después del préstamo | El backend no enviaba los datos de la devolución | Campos nuevos y hoja Antes / Después |
| ALM-01 | No se pueden despachar repuestos | La app no tenía pantalla de despacho | Pestaña *Repuestos* con lista de verificación |

---

## 5. Recuperación tras el conflicto de git

**Qué pasó (14/11/2026):** un `git stash pop` dejó 9 archivos en conflicto. Para limpiar se ejecutó `git reset --hard HEAD`. Ese reset descartó los cambios sin commit y también sacó de la rama el commit **128ee11 "Correcciones del backend"**. Mientras tanto, el equipo había subido 3 commits nuevos (`9e2c6b4`, `6cfe9d2`, `3682be2`).

**Cómo se recuperó:**

1. Antes del reset se guardó una copia de los 84 archivos modificados fuera del repositorio.
2. 128ee11 se volvió a aplicar sin commit (`git cherry-pick -n`).
3. Cada archivo del respaldo se fusionó con la versión del equipo usando como base el ancestro común `32c8bde`.
4. Los conflictos que quedaron se resolvieron así:

| Archivo | Versión elegida |
|---|---|
| `AutenticacionController`, `IAutenticacionService` | **Equipo**: recuperación por DNI+teléfono con selfie, o por correo. Se conserva también el método propio. |
| `AutenticacionServiceImpl` | **Propia**, más los métodos por correo del equipo. Validación del teléfono más estricta y SEC-01. |
| `SolicitudServiceImpl` | **Propia** (notificaciones y despacho con stock mínimo). La condición de prioridad ALTA quedó con la del equipo. |
| `ManualTestingRunner` | **Equipo**, más el teléfono del almacenista. |
| Pantallas `perfil_*`, `CatalogoServiceImpl`, `PrestamoServiceImpl`, `SolicitudRecuperacionResponse` | **Propia**. |
| Todo lo demás | Se unió automáticamente, sin conflicto. |

---

## 6. Archivos nuevos, modificados y eliminados

**Backend, nuevos:**
- `config/TareasProgramadasConfig.java`
- `dto/response/PerfilResponse.java`
- `service/impl/PrestamoVencimientoService.java`

**Backend, modificados:**
- DAO: `AuditoriaOperacion_DAO`, `Repuesto_DAO`.
- Controlador: `AutenticacionController`.
- DTOs: `ActualizarPerfilRequest`, `CrearUsuarioRequest`, `AuditoriaResponse`, `DetalleSolicitudResponse`, `PrestamoResumenResponse`, `RepuestoResponse`, `SolicitudRecuperacionResponse`, `UsuarioResumenResponse`.
- Excepciones: `CuentaBloqueadaException`, `ErrorDetalle`, `GlobalExceptionHandler`.
- Entidades: `Almacenista`, `Prestamo`, `Usuario`.
- Interfaces de servicio: `IAutenticacionService`, `ICatalogoService`.
- Implementaciones: `AuditoriaServiceImpl`, `AutenticacionServiceImpl`, `CatalogoServiceImpl`, `PrestamoServiceImpl`, `SolicitudServiceImpl`.
- Otros: `ManualTestingRunner`, `SgsraMdApplication`, `application.properties`.

**App, nuevos:**
- `session_manager.dart`
- `detalle_solicitud_sheet.dart`, `detalle_prestamo_sheet.dart`
- `file_saver*.dart`
- `notificacion_bell.dart`
- `mi_perfil_screen.dart`
- `solicitudes_recuperacion_screen.dart`
- `despacho_screen.dart`, `despacho_repuestos_tab.dart`

**App, modificados:** las pantallas principales de los 3 roles, el login, las notificaciones, los datasources (`auth`, `admin`, `almacen`, `notificacion`), los modelos y entidades de repuestos y préstamos, `dio_client`, `api_constants`, `app_router` y `pubspec.yaml`.

**App, eliminado:** `auth/presentation/screens/editar_perfil_screen.dart` (reemplazado por `mi_perfil_screen.dart`).

**Documentación:** `skills/dudasfrontend.md` (reordenado, con tabla de estado) y este documento.

---

## 7. Cómo probar

1. **Backend:** reiniciar con `$env:JAVA_HOME="C:\Program Files\Java\jdk-21.0.12.1"; .\mvnw.cmd spring-boot:run`. Al arrancar se crean las columnas nuevas (`foto_perfil_url`, teléfono del almacenista).
2. **App:** recompilar con `flutter run`.
3. **Pruebas sugeridas:**

| Prueba | Resultado esperado |
|---|---|
| Fallar la contraseña 3 veces | El contador baja 2 → 1 → 0, la cuenta se bloquea y aparece la opción de recuperación |
| Pedir la recuperación con DNI + teléfono + selfie | Le llega al administrador; en *Personal → 🔐* aprueba con clave temporal o rechaza |
| Subir una foto en *Mi Perfil* | Aparece junto a la selfie al revisar una recuperación |
| Editar el teléfono de un almacenista en *Personal* | Se mantiene después de cerrar sesión |
| Aprobar una solicitud | Aparece en *Auditoría* como "Aprobó una solicitud" |
| Mecánico: pedir 1 de un repuesto con 18 | Catálogo: "17 disponibles · 1 reservado"; aparece en *Pedidos* |
| Rechazar una solicitud con motivo | El mecánico ve el motivo en rojo en *Pedidos* y en la notificación |
| Almacenista: *Despacho → Repuestos* | Marcar los repuestos y confirmar: el stock físico baja en todos los roles y el mecánico recibe "Repuestos Entregados" |
| Cerrar una devolución de herramienta | Se ve el detalle Antes / Después en ambos roles |

---

## 8. Pendientes y riesgos

- **Hacer commit** apenas se confirme que todo funciona, para no volver a perder el trabajo.
- **Posible tarea duplicada:** `PrestamoVencimientoService` y `TareasProgramadasConfig` revisan los préstamos vencidos a las 07:00. Puede haber avisos de mora duplicados; conviene dejar solo una.
- **SEC-01 en la app:** un administrador no puede editar a otro administrador desde *Personal*. Es intencional; la consola TI sí puede.
- **Pendiente de [dudasbackend.md](dudasbackend.md):**
  - REQ-04 (filtros de métricas por 30/60/90/180 días) existe en la consola de pruebas del equipo, pero todavía no en la pantalla *Reportes* de la app.
  - DUDA-04 (reducir las pestañas del almacenista) no se trabajó.
- **Respaldo:** la copia previa al reset sigue en `C:\Users\Usuario\.claude\projects\...\respaldo-cambios-2026-11-14\` por si hace falta comparar algo.
