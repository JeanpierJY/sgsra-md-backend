# Dudas y Observaciones del Frontend (sgsra_mobile)

Observaciones encontradas en las pruebas manuales de la app, ordenadas por módulo y prioridad.

**Tipos:** 🐞 Bug (no funciona como debería) · ✨ Mejora (funciona, pero se puede mejorar)
**Prioridad:** 🔴 Alta (bloquea un proceso) · 🟡 Media (afecta la información mostrada) · 🟢 Baja (usabilidad)

---

## Resumen

| ID     | Módulo                             | Tipo | Prioridad | Descripción corta                                              |
| ------ | ---------------------------------- | ---- | --------- | -------------------------------------------------------------- |
| AUT-01 | Autenticación                      | 🐞   | 🔴        | El contador de intentos se queda en 2                          |
| AUT-02 | Autenticación / Admin              | 🐞   | 🔴        | El admin no puede atender la solicitud de recuperación         |
| AUT-03 | Perfil (todos los roles)           | ✨   | 🟢        | Foto de perfil para validar la recuperación                    |
| ADM-01 | Admin – Personal                   | 🐞   | 🔴        | La edición de usuarios no se guarda                            |
| ADM-02 | Admin – Auditoría                  | 🐞   | 🟡        | La auditoría no registra acciones como aprobar solicitudes     |
| ADM-03 | Admin – Auditoría                  | ✨   | 🟢        | El historial de auditoría es difícil de leer                   |
| ADM-04 | Notificaciones                     | ✨   | 🟢        | Abrir la solicitud al tocar su notificación                    |
| MEC-01 | Mecánico – Catálogo                | 🐞   | 🟡        | El stock no se actualiza tras solicitar                        |
| MEC-02 | Mecánico – Pedidos                 | 🐞   | 🔴        | La solicitud creada no aparece en Pedidos                      |
| MEC-03 | Mecánico – Pedidos                 | 🐞   | 🟡        | No se ve el motivo del rechazo                                 |
| ALM-01 | Almacenista – Despacho             | 🐞   | 🔴        | No se pueden despachar los repuestos de una solicitud aprobada |
| PRE-01 | Préstamos (Almacenista y Mecánico) | ✨   | 🟡        | Falta el detalle del antes y después del préstamo              |

---

## 1. Autenticación y Recuperación de Contraseña

### AUT-01 🐞 🔴 El contador de intentos se queda en 2

- **Qué pasa:** al fallar la contraseña, el contador de intentos restantes llega a 2 y ya no baja.
- **Impacto:** la cuenta nunca se bloquea y por eso no se puede iniciar el restablecimiento de contraseña.
- **Esperado:** el contador baja con cada intento fallido; al agotarse, la cuenta se bloquea y aparece la opción de recuperación.
- **Revisar:** respuesta del backend al fallar el login (401/423) y cómo `login_screen` / `AuthBloc` muestran los intentos restantes.

### AUT-02 🐞 🔴 El administrador no puede atender la solicitud de recuperación

- **Qué pasa:** el usuario envía su sustento por olvido de contraseña, pero en el perfil de Administrador no hay ninguna acción sobre esa solicitud.
- **Impacto:** el administrador no puede asignar la clave temporal y el usuario queda sin acceso.
- **Esperado:** el administrador ve la solicitud (DNI, motivo, selfie), puede **aprobarla o rechazarla** y, al aprobar, asigna o genera la clave temporal.

### AUT-03 ✨ 🟢 Foto de perfil para cada rol

- **Propuesta:** agregar una foto en "Mi Perfil" para todos los roles.
- **Para qué:** el administrador puede comparar la foto registrada con la selfie de la solicitud antes de restablecer la contraseña.

---

## 2. Rol Administrador

### ADM-01 🐞 🔴 La edición de usuarios en "Personal" no se guarda

- **Qué pasa:** en _Personal_ los cambios al perfil de un usuario parecen guardarse, pero al cerrar sesión y volver a entrar ya no están.
- **Esperado:** los cambios se guardan en la base de datos y se mantienen entre sesiones.
- **Revisar:** si la pantalla llama al endpoint de actualización o solo cambia el estado local.

### ADM-02 🐞 🟡 La auditoría no registra varias acciones

- **Qué pasa:** acciones como aprobar una solicitud no aparecen en _Auditoría_.
- **Ejemplo:** se aprueba una solicitud y la acción no aparece en el historial.
- **Esperado:** se registran todas las acciones relevantes (aprobar o rechazar solicitudes, despachos, devoluciones, cambios de personal, restablecer claves, etc.).

### ADM-03 ✨ 🟢 El historial de auditoría es difícil de leer

- **Propuesta:** mostrar el historial con datos claros: fecha y hora, usuario, acción en lenguaje natural, entidad afectada, e iconos o colores por tipo de acción. Agregar filtros por fecha, usuario y tipo.
- **Relacionado:** ADM-02.

### ADM-04 ✨ 🟢 Abrir la solicitud al tocar su notificación

- **Propuesta:** al tocar la notificación de una solicitud pendiente, abrir directamente el detalle de esa solicitud (por ejemplo, en la Bandeja de Solicitudes).

---

## 3. Rol Mecánico

### MEC-01 🐞 🔴 La solicitud creada no aparece en "Pedidos"

- **Qué pasa:** después de crear una solicitud no se ve su detalle y tampoco aparece en _Pedidos_.
- **Esperado:** se muestra una confirmación con el detalle (código, ítems, estado _Pendiente_) y la solicitud aparece en _Pedidos_.

### MEC-02 🐞 🟡 No se ve el motivo del rechazo

- **Qué pasa:** cuando una solicitud es rechazada, en _Pedidos_ no aparece el motivo que escribió el administrador.
- **Esperado:** el detalle de una solicitud rechazada muestra el motivo del rechazo.

---

## 4. Rol Almacenista

### ALM-01 🐞 🔴 No se pueden despachar los repuestos de una solicitud aprobada

- **Qué pasa:** la pestaña _Despacho_ del almacenista solo tiene la **Salida formal de herramientas de pañol** (préstamos). No hay forma de entregar los repuestos de las solicitudes que aprobó el administrador.
- **Impacto:** las solicitudes aprobadas nunca se entregan y el stock nunca se descuenta (ver MEC-01).
- **Esperado:** la pestaña _Despacho_ tiene dos secciones:
  1. **Salida formal de herramientas de pañol:** la que ya existe, sin cambios.
  2. **Salida formal de repuestos por solicitud (nueva):** lista de solicitudes _Aprobadas_ o _Aprobadas parcialmente_. Cada una muestra mecánico, maquinaria, prioridad y repuestos aprobados con su cantidad, y tiene un botón **"Confirmar despacho"**.
- **Al confirmar el despacho:**
  - La solicitud pasa a _Entregada_.
  - Se descuenta el stock físico y se libera lo reservado.
  - El cambio de stock se ve en todos los roles: catálogo del mecánico, inventario del almacenista y alertas de stock mínimo.
  - El mecánico recibe una notificación y la acción queda registrada en _Auditoría_.
- **Backend:** ya existe. `GET /solicitudes/bandeja?estado=APROBADA` lista las solicitudes y `PUT /solicitudes/{num}/entregar?correoAlmacenista=...` despacha, descuenta stock y audita. Falta solo la interfaz en la app.

---

## 5. Préstamos de Herramientas (Almacenista y Mecánico)

### PRE-01 ✨ 🟡 Falta el detalle del antes y después del préstamo

- **Qué pasa:** al terminar el préstamo de una herramienta no se ve cómo estaba la herramienta al entregarla y cómo volvió.
- **Esperado:** en ambos roles, un detalle con:
  - **Antes (entrega):** fecha, almacenista, estado y observaciones.
  - **Después (devolución):** fecha, estado de la inspección, observaciones o daños y si hubo mora.

---

## Estado de las correcciones

Todas las observaciones fueron atendidas (pendiente de prueba manual en dispositivo).

| ID     | Solución aplicada                                                                                                                                                                                                                                                                                                                                                                            |
| ------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| AUT-01 | Backend: el login ya no revierte el contador al fallar (`noRollbackFor`)                                                                                                                                                                                                                                                                                                                     |
| AUT-02 | Nueva pantalla _Recuperación de contraseñas_ (Personal → 🔐), aprobar con clave temporal o rechazar con motivo                                                                                                                                                                                                                                                                               |
| AUT-03 | Foto de perfil en _Mi Perfil_ (todos los roles); se muestra junto a la selfie al revisar la recuperación                                                                                                                                                                                                                                                                                     |
| ADM-01 | Edición guarda nombre y teléfono (mecánico y almacenista), muestra el teléfono real y recarga la lista                                                                                                                                                                                                                                                                                       |
| ADM-02 | Backend: consulta de auditoría corregida (antes fallaba y la app mostraba datos de ejemplo); se recarga al abrir la pestaña                                                                                                                                                                                                                                                                  |
| ADM-03 | Bitácora en lenguaje claro, agrupada por día, con filtros por categoría y periodo                                                                                                                                                                                                                                                                                                            |
| ADM-04 | Tocar una notificación abre la solicitud (con Aprobar/Rechazar) o la recuperación de contraseña                                                                                                                                                                                                                                                                                              |
| MEC-01 | El catálogo muestra disponibles, reservados y en carrito; se actualiza tras enviar la solicitud. El stock físico baja al confirmar el despacho (ALM-01)                                                                                                                                                                                                                                      |
| MEC-02 | Tras enviar, botón _Ver detalle_ que abre Pedidos con la solicitud; Pedidos se recarga al entrar                                                                                                                                                                                                                                                                                             |
| MEC-03 | El detalle de la solicitud muestra el motivo del rechazo destacado                                                                                                                                                                                                                                                                                                                           |
| PRE-01 | Detalle _Antes / Después_ del préstamo en Mecánico (Herramientas) y Almacenista (Dashboard y al cerrar el retorno)                                                                                                                                                                                                                                                                           |
| ALM-01 | _Despacho_ con dos pestañas: **Repuestos** (solicitudes aprobadas, urgentes primero, lista de verificación con stock antes → después y botón _Confirmar despacho_) y **Herramientas** (la salida de pañol de siempre). Al despachar se descuenta el stock, la solicitud pasa a _Entregada_, se notifica al mecánico y, si un repuesto llega a su mínimo, se avisa a administración y almacén |

## Orden sugerido de atención

1. **🔴 Bloqueantes:** AUT-01, AUT-02, ADM-01, MEC-02, ALM-01
2. **🟡 Información incorrecta o incompleta:** MEC-01, MEC-03, ADM-02, PRE-01
3. **🟢 Usabilidad:** ADM-03, ADM-04, AUT-03

---

# Segunda ronda de observaciones

Hallazgos de la segunda prueba manual, más lo que se encontró al comparar la app con la consola de pruebas (`ManualTestingRunner`), que tiene todas las funciones del sistema.

## Resumen

| ID     | Módulo                 | Tipo | Prioridad | Descripción corta                                                                              |
| ------ | ---------------------- | ---- | --------- | ---------------------------------------------------------------------------------------------- |
| GEN-01 | Todos                  | 🐞   | 🟡        | Los repuestos y herramientas no muestran imagen en ninguna parte                               |
| GEN-02 | Todos                  | ✨   | 🟢        | Mover _Mi Perfil_ de la barra inferior a la esquina superior derecha                           |
| GEN-03 | Todos                  | 🐞   | 🟢        | Los íconos de la barra superior casi no se ven (deben ser blancos)                             |
| ADM-05 | Admin – Bandeja        | 🐞   | 🔴        | No se puede aprobar una solicitud parcialmente (repuesto por repuesto)                         |
| ADM-06 | Admin – Bandeja        | ✨   | 🟡        | Ver todas las solicitudes (todos los estados, ordenadas y con filtros)                         |
| ADM-07 | Admin – Reportes       | 🐞   | 🟡        | _Métricas y reportes_ está incompleto frente a la consola                                      |
| ADM-08 | Admin – Catálogo       | 🐞   | 🟡        | No se puede cambiar la imagen de un repuesto                                                   |
| MEC-04 | Mecánico – Navegación  | ✨   | 🟢        | Renombrar _Carrito_ → _Solicitudes_ y _Pedidos_ → _Historial_ (con sus íconos)                 |
| MEC-05 | Mecánico – Solicitudes | ✨   | 🟡        | Buscar y seleccionar la máquina al escribir unas letras                                        |
| ALM-02 | Almacén – Despacho     | ✨   | 🟡        | Herramientas a despachar con imagen y buscador con lista seleccionable                         |
| ALM-03 | Almacén – Retorno      | ✨   | 🟡        | Unir _Retorno_ y _Escanear QR_: QR arriba, retorno abajo, autocompletado al escanear           |
| ALM-04 | Almacén – Herramientas | ✨   | 🟡        | Buscador predictivo, renombrar _Activos_ → _Herramientas_ y ver el detalle de cada herramienta |
| ALM-05 | Almacén – Herramientas | ✨   | 🟢        | _Reportar extravío_ y _Nueva herramienta_ como 2 botones flotantes abajo a la derecha          |
| ALM-06 | Almacén – Dashboard    | ✨   | 🟢        | Cuadros del dashboard más pequeños                                                             |

## Generales

### GEN-01 🐞 🟡 Repuestos y herramientas sin imagen

- **Causa:** el backend envía la imagen como `imagenUrl`, pero la app la buscaba como `urlFoto`, así que nunca la recibía. Además, ninguna pantalla mostraba ni permitía subir imágenes.
- **Esperado:** miniatura en catálogos, carrito, detalle de solicitud, despacho, retorno y herramientas, con un ícono cuando no hay foto y la opción de ampliarla al tocarla.

### GEN-02 ✨ 🟢 _Mi Perfil_ arriba a la derecha

- Quitar _Mi Perfil_ de la barra inferior de los 3 roles y abrirlo desde un avatar en la esquina superior derecha. Deja más espacio para las pestañas de trabajo.

### GEN-03 🐞 🟢 Íconos de la barra superior poco visibles

- Las barras azules usaban íconos oscuros. Deben ser blancos en toda la app.

## Administrador

### ADM-05 🐞 🔴 Aprobación parcial

- En el detalle de una solicitud pendiente, cada repuesto debe tener **Aprobar / Rechazar**. La consola ya lo permite (opción 1.1 → 3, RF26), pero la app no.
- Si se rechaza algún repuesto, pedir el motivo. El botón final se adapta: _Aprobar todo_, _Aprobar parcialmente_ o _Rechazar solicitud_.

### ADM-06 ✨ 🟡 Todas las solicitudes

- La bandeja debe mostrar todos los estados (pendiente, aprobada, aprobada parcial, orden a proveedor, entregada y rechazada), las más recientes primero, con contador por estado, buscador y filtro por fecha (consola 1.2, RF31).
- Las notificaciones de toda solicitud nueva ya llegan al administrador.

### ADM-07 🐞 🟡 Métricas y reportes incompletos

- **Falta frente a la consola:** filtro de periodo de 30, 60, 90 y 180 días (REQ-04), y que la exportación respete ese periodo.
- **Mejoras:** resumen de solicitudes del periodo (total, pendientes, aprobadas, rechazadas, entregadas y tasa de aprobación), distribución por prioridad y lista de repuestos en stock mínimo.

### ADM-08 🐞 🟡 Imagen de repuestos

- El endpoint `POST /catalogo/{cod}/imagen` existe, pero la app no lo usaba. Permitir subir o cambiar la foto con la cámara o la galería.

## Mecánico

### MEC-04 ✨ 🟢 Nombres de la barra inferior

- _Carrito_ → **Solicitudes** (ícono de solicitud nueva) y _Pedidos_ → **Historial** (ícono de historial).

### MEC-05 ✨ 🟡 Búsqueda de máquinas

- Hoy se escribe el código a mano y está prellenado con `MD-RB-01`. Al escribir unas letras debe aparecer la lista de máquinas (código, modelo y estado) para elegir.
- **Backend:** falta el endpoint de búsqueda de máquinas.

## Almacenista

### ALM-02 ✨ 🟡 Despacho de herramientas

- La herramienta y el mecánico se elegían en listas desplegables sin imagen. Cambiarlas por buscadores con lista seleccionable y foto.

### ALM-03 ✨ 🟡 Retorno + QR en una sola pantalla

- El escáner va arriba y el formulario de retorno abajo. Al escanear el QR de una herramienta prestada se rellenan solos el préstamo, el mecánico y la herramienta.
- Si la herramienta no está prestada, se muestra su ficha.
- El préstamo se elige con un buscador.

### ALM-04 ✨ 🟡 Herramientas

- La pestaña _Activos_ pasa a llamarse **Herramientas**.
- Buscador predictivo por código, nombre o marca.
- Al tocar una herramienta se abre su detalle: foto (se puede cambiar), datos, estado e historial de préstamos.

### ALM-05 ✨ 🟢 Botones flotantes

- _Reportar extravío_ y _Nueva herramienta_ salen de la barra superior y pasan a ser 2 botones flotantes en la esquina inferior derecha.

### ALM-06 ✨ 🟢 Dashboard

- Cuadros de indicadores más pequeños (3 por fila).
- Quitar los datos de ejemplo que aparecían cuando fallaba la conexión.

## Estado de la segunda ronda

| ID     | Solución aplicada                                                                                                                                                                                                                                                                                                                                                                                             |
| ------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| GEN-01 | Se corrigió la lectura de `imagenUrl`. Componente `ImagenProducto` (miniatura, ícono si no hay foto, ampliar al tocar) en el catálogo del mecánico y del admin, la nueva solicitud, el detalle de solicitud, el despacho de repuestos y herramientas, el retorno, _Herramientas_, el detalle de préstamo y el stock crítico. El backend ahora envía `imagenUrl` en el detalle de solicitud y en los préstamos |
| GEN-02 | _Mi Perfil_ salió de la barra inferior en los 3 roles. Se abre desde un avatar (foto o iniciales) en la esquina superior derecha de cada pantalla                                                                                                                                                                                                                                                             |
| GEN-03 | Tema global: barra superior azul con títulos e íconos blancos                                                                                                                                                                                                                                                                                                                                                 |
| ADM-05 | En el detalle de una solicitud pendiente, cada repuesto tiene **Aprobar / Rechazar** y muestra su stock. El botón final cambia solo: _Aprobar todo_, _Aprobar parcialmente (N de M)_ o _Rechazar solicitud_, y pide el motivo si hay rechazos                                                                                                                                                                 |
| ADM-06 | La bandeja muestra todos los estados (más recientes primero; backend ordenado), con contador por estado, buscador, filtro de periodo y aviso de pendientes y urgentes. _Evaluar_ abre el detalle con decisión por repuesto                                                                                                                                                                                    |
| ADM-07 | _Métricas_ con periodo de 30/60/90/180 días, resumen (total, pendientes, aprobadas, entregadas, rechazadas, % de aprobación), top 10 de repuestos, prioridades, repuestos en stock mínimo y exportación Excel/CSV del periodo. El backend ahora filtra la exportación por fechas                                                                                                                              |
| ADM-08 | En el catálogo del admin se toca la foto (ícono de cámara) para tomarla o elegirla de la galería. También se agregó un buscador                                                                                                                                                                                                                                                                               |
| MEC-04 | Barra inferior: Catálogo · **Solicitudes** · **Historial** · Herramientas                                                                                                                                                                                                                                                                                                                                     |
| MEC-05 | Endpoint nuevo `GET /api/v1/maquinarias?termino=`. En _Nueva solicitud_ se escribe y aparecen las máquinas (código, modelo, estado) para elegir. El formulario va en 4 pasos, con cantidades editables y la urgencia en botones de color                                                                                                                                                                      |
| ALM-02 | En el despacho de herramientas, el mecánico y las herramientas se eligen con buscadores con foto. Se pueden entregar varias herramientas en un mismo préstamo y se confirma antes de registrar                                                                                                                                                                                                                |
| ALM-03 | Nueva pestaña **Retorno**: escáner QR arriba (linterna, cambio de cámara, ocultar cámara, ingreso manual) y formulario abajo. Al escanear se rellenan solos el préstamo y la herramienta. Si no está prestada se muestra su ficha. El estado de devolución se elige con botones de color                                                                                                                      |
| ALM-04 | _Activos_ → **Herramientas**: buscador predictivo, filtros por categoría y estado (con contador) y pantalla de detalle con foto editable, datos, botón de extravío e historial de préstamos                                                                                                                                                                                                                   |
| ALM-05 | _Nueva herramienta_ (al crearla ofrece agregar foto) y _Reportar extravío_ como botones flotantes abajo a la derecha                                                                                                                                                                                                                                                                                          |
| ALM-06 | Indicadores en 3 columnas, más compactos. Sin datos de ejemplo; si falla la conexión se muestra un aviso                                                                                                                                                                                                                                                                                                      |


---

# Tercera ronda de observaciones (Módulo Almacén: Despacho y Retorno)

Hallazgos de la tercera prueba manual en el flujo operativo del Almacenista:

## Resumen

| ID     | Módulo                  | Tipo | Prioridad | Descripción corta                                                                                                     |
| ------ | ----------------------- | ---- | --------- | --------------------------------------------------------------------------------------------------------------------- |
| ALM-07 | Almacén – Despacho      | ✨   | 🟡        | Cuadro buscador con lista seleccionable para herramienta (igual al de mecánico)                                       |
| ALM-08 | Almacén – Retorno       | ✨   | 🟢        | Quitar botón "Ingresar código" de la cámara                                                                           |
| ALM-09 | Almacén – Retorno       | ✨   | 🔴        | Flujo tipo catálogo: buscador predictivo y listado automático de herramientas prestadas                               |
| ALM-10 | Almacén – Retorno       | ✨   | 🔴        | Modal interactivo de retorno al seleccionar herramienta (estado físico, observaciones, confirmar)                     |
| ALM-11 | Almacén – Retorno       | 🐞   | 🔴        | Corrección de bug en escáner de cámara (manejo seguro de permisos, reintento, linterna y descarte de duplicados)      |

## Detalle de Observaciones

### ALM-07 ✨ 🟡 Cuadro buscador con lista seleccionable para herramientas
- **Observación:** En el despacho de herramientas (`RegistrarPrestamoScreen`), el mecánico contaba con un cuadro de selección (`CampoSelector`), pero las herramientas tenían botones dispersos.
- **Esperado:** Contar con un cuadro selector simétrico e intuitivo para buscar y seleccionar herramientas, mostrando la lista seleccionada debajo con opción de eliminar o agregar más antes de despachar.

### ALM-08 ✨ 🟢 Quitar botón "Ingresar código" de la cámara
- **Observación:** En el visor de cámara de retorno existía un botón secundario de "Ingresar código" innecesario y redundante con el nuevo flujo predictivo.
- **Esperado:** Visor QR despejado que conserve únicamente los controles esenciales de hardware (linterna, cambio de cámara y ocultar cámara).

### ALM-09 ✨ 🔴 Flujo estilo catálogo: buscador predictivo y listado en automático
- **Observación:** El flujo anterior requería buscar manualmente un préstamo para luego desplegar sus herramientas.
- **Esperado:** Invertir la lógica para que funcione exactamente como el catálogo:
  1. Cargar en automático todas las herramientas actualmente prestadas / en posesión de los mecánicos pendientes de devolución (con foto, código, nombre, mecánico, fecha de salida y estado "EN MORA" si aplica).
  2. Buscador predictivo en vivo que filtre en tiempo real por herramienta, código, mecánico o número de préstamo.

### ALM-10 ✨ 🔴 Modal de retorno al seleccionar herramienta
- **Observación:** El formulario de devolución estaba fijo en la parte inferior de la pantalla.
- **Esperado:** Al tocar cualquier herramienta del listado o escanear su código QR, abrir un modal emergente (`showModalBottomSheet`) con el resumen de la herramienta, selector visual de estado de devolución (`BUEN_ESTADO`, `CON_AVERIA`, `INCOMPLETA`), detalle de la inspección/faltante y confirmación inmediata con actualización en tiempo real del stock y visualización del antes/después (`PRE-01`).

### ALM-11 🐞 🔴 Bug de inicialización de la cámara
- **Observación:** La cámara fallaba o arrojaba error no controlado en entornos de prueba / web / móvil al alternar vistas o manipular linterna/cámara frontal.
- **Esperado:** Inicialización segura de `MobileScannerController` con modo QR exclusivo, captura de errores amigable en pantalla con botón de reintento ("Reintentar cámara"), flag de bloqueo durante modales para evitar lecturas duplicadas, y métodos protegidos contra fallos asíncronos.

---

## Estado de la tercera ronda

| ID     | Solución aplicada                                                                                                                                                                                                                                                                                                                                                                                          |
| ------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ALM-07 | Se implementó `CampoSelector` para "Herramienta a entregar" en [registrar_prestamo_screen.dart](file:///c:/Users/Usuario/Documents/GitHub/sgsra-md-backend/sgsra_mobile/lib/features/almacen/presentation/screens/registrar_prestamo_screen.dart). Permite buscar y seleccionar herramientas con foto y estado disponible; debajo se visualizan las herramientas añadidas con botón de retiro o agregar más.   |
| ALM-08 | Se retiró el botón "Ingresar código" del visor de la cámara en [retorno_qr_screen.dart](file:///c:/Users/Usuario/Documents/GitHub/sgsra-md-backend/sgsra_mobile/lib/features/almacen/presentation/screens/retorno_qr_screen.dart), dejando limpia la barra de escaneo con linterna, rotación y visibilidad.                                                                                          |
| ALM-09 | Se rediseñó [retorno_qr_screen.dart](file:///c:/Users/Usuario/Documents/GitHub/sgsra-md-backend/sgsra_mobile/lib/features/almacen/presentation/screens/retorno_qr_screen.dart) integrando un listado automático de todas las herramientas actualmente en préstamo (con foto, nombre, código, mecánico, préstamo y badge de mora). Se incorporó buscador predictivo en tiempo real estilo catálogo.             |
| ALM-10 | Al presionar cualquier ítem de la lista o capturar el QR con la cámara, se abre el modal inferior `_abrirModalRetorno()` con la ficha de la herramienta, selector visual de estado (`BUEN_ESTADO`, `CON_AVERIA`, `INCOMPLETA`), descripción de avería o faltante, confirmación de retorno y visualización del detalle antes/después del préstamo.                                                   |
| ALM-11 | Se configuró `MobileScannerController` con `DetectionSpeed.noDuplicates`, formato restringido a QR, pantalla de error amigable con botón de reintento (`Reintentar cámara`), flag `_modalAbierto` para pausar lecturas durante la confirmación y manejo seguro de excepciones en linterna y conmutación de cámara.                                                                                     |

---

# Cuarta ronda de observaciones (Calibración Final y Ergonomía Pre-APK)

Ajustes finales de ergonomía, control de errores y validaciones de campo identificadas previo a la compilación y empaquetado final:

## Resumen

| ID     | Módulo                             | Tipo | Prioridad | Descripción corta                                                                                                     |
| ------ | ---------------------------------- | ---- | --------- | --------------------------------------------------------------------------------------------------------------------- |
| PER-01 | Mi Perfil / Personal               | 🐞   | 🔴        | Teléfono estricto en Perú: solo 9 dígitos numéricos e inicio obligatorio con "9"                                      |
| MEC-06 | Mecánico – Catálogo                | ✨   | 🟢        | Retiro del botón superior redundante "Ver mi solicitud"                                                               |
| ADM-09 | Admin – Bandeja Solicitudes        | 🐞   | 🔴        | Bug de motivo: SnackBar se ocultaba tras el modal; migrado a validación inline con foco en el campo                   |
| ADM-10 | Admin – Catálogo Repuestos         | ✨   | 🟡        | Botones flotantes (Añadir repuesto y Proveedores) y bloqueo de letras/valores negativos en stock                      |
| ADM-11 | Admin – Personal                   | ✨   | 🟡        | Botones flotantes (Añadir usuario y Recuperar clave), bloqueo de números en nombres y validación estricta de teléfono  |
| GEN-04 | Manejo Global de Errores           | 🐞   | 🔴        | Eliminación de códigos técnicos raros (PostgreSQL, constraints, stack traces) por mensajes claros en español         |

## Detalle de Observaciones

### PER-01 🐞 🔴 Formato estricto de teléfono celular
- **Observación:** Se permitía ingresar letras, signos o cantidades arbitrarias de números en los campos de teléfono de Perfil, Gestión de Personal y Recuperación de Clave.
- **Esperado:** Formateador `digitsOnly`, límite de 9 caracteres y validador regex `^9[0-9]{8}$` que garantice que empiece exclusivamente con "9".

### MEC-06 ✨ 🟢 Retiro del botón "Ver mi solicitud" en catálogo
- **Observación:** En el catálogo de mecánico existía un botón en la AppBar ("Ver mi solicitud") redundante con la navegación principal de la barra inferior (pestaña _Solicitudes_).
- **Esperado:** Eliminar el botón de la barra superior para una interfaz más despejada y libre de duplicidad de accesos.

### ADM-09 🐞 🔴 Validación inline de motivo de rechazo en bandeja
- **Observación:** Al presionar "Rechazar solicitud" o "Aprobar parcialmente" sin motivo, el mensaje aparecía como un SnackBar en el Scaffold base detrás del modal emergente, haciéndose visible solo tras cerrarlo y provocando que el usuario presione repetidamente creyendo que la app se trabó.
- **Esperado:** Validación inline dentro del mismo modal con texto de error rojo (`errorText`) y foco automático en el campo `TextField`.

### ADM-10 ✨ 🟡 Botones flotantes y validación de stock en catálogo
- **Observación:** "Alta de repuesto" y "Proveedores" estaban en la barra superior. Además, el formulario permitía ingresar letras o números negativos en stock inicial y mínimo.
- **Esperado:**
  1. Dos botones flotantes (FAB) abajo a la derecha: "Añadir repuesto" y "Proveedores homologados".
  2. Input formatters solo numéricos (`digitsOnly`) y validación $\ge 0$ para stock inicial, mínimo y ajustes.

### ADM-11 ✨ 🟡 Botones flotantes y validación en gestión de personal
- **Observación:** Botones en AppBar sin ergonomía móvil. En los formularios de registro y edición se permitía ingresar números en el nombre y letras en el teléfono.
- **Esperado:**
  1. Botones flotantes (FAB) inferiores para "Añadir usuario" y "Recuperar contraseña" (con badge dinámico de solicitudes pendientes).
  2. Formateador de solo letras y espacios en el nombre (`validarNombre`).
  3. Formateador de solo dígitos y validador de 9 dígitos comenzando con 9 en el teléfono.

### GEN-04 🐞 🔴 Sanitización de errores técnicos en toda la aplicación
- **Observación:** Errores de base de datos como violaciones de unicidad, check constraints (`repuesto_stock_actual_check`), o excepciones no controladas mostraban códigos crudos tipo `[SQLState: 23514]` o mensajes técnicos en inglés.
- **Esperado:** Interceptor y función unificada `mensajeDeError()` que traduzca cualquier error técnico a una explicación concisa, humana y comprensible para el usuario operativo.

---

## Estado de la cuarta ronda

| ID     | Solución aplicada                                                                                                                                                                                                                                                                                                                                                                                          |
| ------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| PER-01 | Se actualizó `AppValidators.validarTelefono` con regex `^9[0-9]{8}$` y se aplicó junto con `FilteringTextInputFormatter.digitsOnly` y límite de 9 caracteres en [mi_perfil_screen.dart](file:///c:/Users/Usuario/Documents/GitHub/sgsra-md-backend/sgsra_mobile/lib/features/auth/presentation/screens/mi_perfil_screen.dart), [gestion_personal_screen.dart](file:///c:/Users/Usuario/Documents/GitHub/sgsra-md-backend/sgsra_mobile/lib/features/administrador/presentation/screens/gestion_personal_screen.dart) y [recuperar_clave_modal.dart](file:///c:/Users/Usuario/Documents/GitHub/sgsra-md-backend/sgsra_mobile/lib/features/auth/presentation/screens/recuperar_clave_modal.dart). |
| MEC-06 | Se retiró el botón de acción de la barra superior en [catalogo_screen.dart](file:///c:/Users/Usuario/Documents/GitHub/sgsra-md-backend/sgsra_mobile/lib/features/mecanico/presentation/screens/catalogo_screen.dart). El acceso al formulario de solicitud queda unificado en la pestaña inferior "Solicitudes".                                                                                      |
| ADM-09 | Se implementó validación reactiva con `_motivoFocus` y `_motivoError` en [detalle_solicitud_sheet.dart](file:///c:/Users/Usuario/Documents/GitHub/sgsra-md-backend/sgsra_mobile/lib/core/widgets/detalle_solicitud_sheet.dart). Si el usuario intenta rechazar o aprobar parcialmente sin ingresar el motivo, el campo resalta inmediatamente en rojo y recibe el foco sin cerrar el modal.           |
| ADM-10 | En [mantenimiento_catalogo_screen.dart](file:///c:/Users/Usuario/Documents/GitHub/sgsra-md-backend/sgsra_mobile/lib/features/administrador/presentation/screens/mantenimiento_catalogo_screen.dart) se colocaron dos Floating Action Buttons ("Añadir repuesto" y "Proveedores"). Se aplicó `digitsOnly` y `AppValidators.validarStock` en los modales de creación y edición de stock.                |
| ADM-11 | En [gestion_personal_screen.dart](file:///c:/Users/Usuario/Documents/GitHub/sgsra-md-backend/sgsra_mobile/lib/features/administrador/presentation/screens/gestion_personal_screen.dart) se añadieron FABs para "Añadir usuario" y "Recuperar contraseña" (con badge). Se agregó `AppValidators.validarNombre` (solo letras/espacios) y `AppValidators.validarTelefono` (solo números iniciando con 9). |
| GEN-04 | Se rediseñó `mensajeDeError()` y `_sanitizarMensajeTecnico()` en [exceptions.dart](file:///c:/Users/Usuario/Documents/GitHub/sgsra-md-backend/sgsra_mobile/lib/core/errors/exceptions.dart), interceptando errores de constraint (stock negativo, duplicidad de DNI o código, claves foráneas, errores 409/422) y reemplazando cualquier `$e` crudo en la UI por mensajes claros y amigables.       |

---

# Quinta ronda de observaciones (Conectividad, Biometría y Calibración por Rol)

Ajustes derivados de las pruebas directas sobre dispositivo móvil físico en red Wi-Fi:

## Resumen

| ID     | Módulo                             | Tipo | Prioridad | Descripción corta                                                                                                     |
| ------ | ---------------------------------- | ---- | --------- | --------------------------------------------------------------------------------------------------------------------- |
| GEN-05 | Autenticación / Red                | ✨   | 🔴        | Selector y probador de IP del backend en pantalla de Login para fácil diagnóstico en red Wi-Fi                       |
| GEN-06 | Autenticación / Huella             | 🐞   | 🔴        | Acceso biométrico funcional: precarga de último correo y guardado seguro de credenciales tras primer login con clave  |
| ADM-12 | Admin – Personal                   | 🐞   | 🔴        | TypeError _JsonMap no subtype of List: extracción correcta del arreglo `content` de Page Spring Boot                 |
| ADM-13 | Admin – Bandeja Solicitudes        | ✨   | 🟢        | Eliminación del botón "Orden a proveedor [RF28]" en solicitudes aprobadas parcialmente                                |
| ADM-14 | Admin – Catálogo Repuestos         | ✨   | 🟢        | Renombrar a "Especificación Técnica" y retirar botón/filtro flotante de proveedores                                   |
| MEC-07 | Mecánico – Notificaciones          | 🐞   | 🔴        | Corrección de consulta JPQL LIMIT 1 en DAO para asociar y notificar correctamente al mecánico custodio de extravío    |
| MEC-08 | Mecánico – Historial               | ✨   | 🟡        | Inclusión del filtro "Aprobadas parcial" en el carrusel de estados de pedidos                                         |
| MEC-09 | Mecánico – Herramientas en Poder   | 🐞   | 🔴        | Obtención dinámica del DNI del mecánico autenticado desde SessionManager para listar sus herramientas en custodia     |
| ALM-12 | Almacén – Dashboard                | ✨   | 🟢        | Reordenamiento: Repuestos Aprobados para Retiro Físico antes de Control y Listado de Préstamos                         |

## Estado de la quinta ronda

| ID     | Solución aplicada                                                                                                                                                                                                                                                                                                                                                                                          |
| ------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| GEN-05 | Se agregó `ApiService.guardarHost` e `inicializar` persistidos en [api_constants.dart](file:///c:/Users/Usuario/Documents/GitHub/sgsra-md-backend/sgsra_mobile/lib/core/constants/api_constants.dart) y botón de ajustes con diálogo de prueba de conexión en [login_screen.dart](file:///c:/Users/Usuario/Documents/GitHub/sgsra-md-backend/sgsra_mobile/lib/features/auth/presentation/screens/login_screen.dart). |
| GEN-06 | En [login_screen.dart](file:///c:/Users/Usuario/Documents/GitHub/sgsra-md-backend/sgsra_mobile/lib/features/auth/presentation/screens/login_screen.dart) se precarga el último correo y al iniciar sesión con contraseña se asocian de forma cifrada en `FlutterSecureStorage`. Al presionar el botón de huella se valida la biometría y se inicia sesión automáticamente.                             |
| ADM-12 | En [gestion_personal_screen.dart](file:///c:/Users/Usuario/Documents/GitHub/sgsra-md-backend/sgsra_mobile/lib/features/administrador/presentation/screens/gestion_personal_screen.dart) se desempaqueta la lista desde `res.data['content']` cuando el backend devuelve un objeto paginado `Page<UsuarioResumenResponse>`.                                                                         |
| ADM-13 | Se eliminó el botón de "Orden a proveedor" en [bandeja_solicitudes_screen.dart](file:///c:/Users/Usuario/Documents/GitHub/sgsra-md-backend/sgsra_mobile/lib/features/administrador/presentation/screens/bandeja_solicitudes_screen.dart).                                                                                                                                                              |
| ADM-14 | En [mantenimiento_catalogo_screen.dart](file:///c:/Users/Usuario/Documents/GitHub/sgsra-md-backend/sgsra_mobile/lib/features/administrador/presentation/screens/mantenimiento_catalogo_screen.dart) se renombró el campo a "Especificación Técnica" y se retiró el botón flotante de proveedores.                                                                                                   |
| MEC-07 | En [Prestamo_DAO.java](file:///c:/Users/Usuario/Documents/GitHub/sgsra-md-backend/sgsra-md/src/main/java/com/masterdrilling/sgsramd/DAO/Prestamo_DAO.java) se migró `findUltimoMecanicoCustodio` a consulta SQL nativa para compatibilidad con PostgreSQL `LIMIT 1` y se añadió método directo `listarPorMecanico(dni)`.                                                                            |
| MEC-08 | En [historial_solicitudes_screen.dart](file:///c:/Users/Usuario/Documents/GitHub/sgsra-md-backend/sgsra_mobile/lib/features/mecanico/presentation/screens/historial_solicitudes_screen.dart) se agregó el chip y filtrado por `APROBADA_PARCIAL`.                                                                                                                                                       |
| MEC-09 | En [repuesto_remote_datasource.dart](file:///c:/Users/Usuario/Documents/GitHub/sgsra-md-backend/sgsra_mobile/lib/features/mecanico/data/datasources/repuesto_remote_datasource.dart) se lee `SessionManager.dni()` de la sesión activa para consultar las herramientas prestadas.                                                                                                                   |
| ALM-12 | En [dashboard_almacen_screen.dart](file:///c:/Users/Usuario/Documents/GitHub/sgsra-md-backend/sgsra_mobile/lib/features/almacen/presentation/screens/dashboard_almacen_screen.dart) se movió la sección "Repuestos Aprobados para Retiro Físico" antes del listado de préstamos.                                                                                                                         |


