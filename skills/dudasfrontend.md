# Dudas y Observaciones del Frontend (sgsra_mobile)

Observaciones encontradas en las pruebas manuales de la app, ordenadas por módulo y prioridad.

**Tipos:** 🐞 Bug (no funciona como debería) · ✨ Mejora (funciona, pero se puede mejorar)
**Prioridad:** 🔴 Alta (bloquea un proceso) · 🟡 Media (afecta la información mostrada) · 🟢 Baja (usabilidad)

---

## Resumen

| ID | Módulo | Tipo | Prioridad | Descripción corta |
|----|--------|------|-----------|-------------------|
| AUT-01 | Autenticación | 🐞 | 🔴 | El contador de intentos se queda en 2 |
| AUT-02 | Autenticación / Admin | 🐞 | 🔴 | El admin no puede atender la solicitud de recuperación |
| AUT-03 | Perfil (todos los roles) | ✨ | 🟢 | Foto de perfil para validar la recuperación |
| ADM-01 | Admin – Personal | 🐞 | 🔴 | La edición de usuarios no se guarda |
| ADM-02 | Admin – Auditoría | 🐞 | 🟡 | La auditoría no registra acciones como aprobar solicitudes |
| ADM-03 | Admin – Auditoría | ✨ | 🟢 | El historial de auditoría es difícil de leer |
| ADM-04 | Notificaciones | ✨ | 🟢 | Abrir la solicitud al tocar su notificación |
| MEC-01 | Mecánico – Catálogo | 🐞 | 🟡 | El stock no se actualiza tras solicitar |
| MEC-02 | Mecánico – Pedidos | 🐞 | 🔴 | La solicitud creada no aparece en Pedidos |
| MEC-03 | Mecánico – Pedidos | 🐞 | 🟡 | No se ve el motivo del rechazo |
| ALM-01 | Almacenista – Despacho | 🐞 | 🔴 | No se pueden despachar los repuestos de una solicitud aprobada |
| PRE-01 | Préstamos (Almacenista y Mecánico) | ✨ | 🟡 | Falta el detalle del antes y después del préstamo |

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
- **Qué pasa:** en *Personal* los cambios al perfil de un usuario parecen guardarse, pero al cerrar sesión y volver a entrar ya no están.
- **Esperado:** los cambios se guardan en la base de datos y se mantienen entre sesiones.
- **Revisar:** si la pantalla llama al endpoint de actualización o solo cambia el estado local.

### ADM-02 🐞 🟡 La auditoría no registra varias acciones
- **Qué pasa:** acciones como aprobar una solicitud no aparecen en *Auditoría*.
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
- **Qué pasa:** después de crear una solicitud no se ve su detalle y tampoco aparece en *Pedidos*.
- **Esperado:** se muestra una confirmación con el detalle (código, ítems, estado *Pendiente*) y la solicitud aparece en *Pedidos*.

### MEC-02 🐞 🟡 No se ve el motivo del rechazo
- **Qué pasa:** cuando una solicitud es rechazada, en *Pedidos* no aparece el motivo que escribió el administrador.
- **Esperado:** el detalle de una solicitud rechazada muestra el motivo del rechazo.

---

## 4. Rol Almacenista

### ALM-01 🐞 🔴 No se pueden despachar los repuestos de una solicitud aprobada
- **Qué pasa:** la pestaña *Despacho* del almacenista solo tiene la **Salida formal de herramientas de pañol** (préstamos). No hay forma de entregar los repuestos de las solicitudes que aprobó el administrador.
- **Impacto:** las solicitudes aprobadas nunca se entregan y el stock nunca se descuenta (ver MEC-01).
- **Esperado:** la pestaña *Despacho* tiene dos secciones:
  1. **Salida formal de herramientas de pañol:** la que ya existe, sin cambios.
  2. **Salida formal de repuestos por solicitud (nueva):** lista de solicitudes *Aprobadas* o *Aprobadas parcialmente*. Cada una muestra mecánico, maquinaria, prioridad y repuestos aprobados con su cantidad, y tiene un botón **"Confirmar despacho"**.
- **Al confirmar el despacho:**
  - La solicitud pasa a *Entregada*.
  - Se descuenta el stock físico y se libera lo reservado.
  - El cambio de stock se ve en todos los roles: catálogo del mecánico, inventario del almacenista y alertas de stock mínimo.
  - El mecánico recibe una notificación y la acción queda registrada en *Auditoría*.
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

| ID | Solución aplicada |
|----|-------------------|
| AUT-01 | Backend: el login ya no revierte el contador al fallar (`noRollbackFor`) |
| AUT-02 | Nueva pantalla *Recuperación de contraseñas* (Personal → 🔐), aprobar con clave temporal o rechazar con motivo |
| AUT-03 | Foto de perfil en *Mi Perfil* (todos los roles); se muestra junto a la selfie al revisar la recuperación |
| ADM-01 | Edición guarda nombre y teléfono (mecánico y almacenista), muestra el teléfono real y recarga la lista |
| ADM-02 | Backend: consulta de auditoría corregida (antes fallaba y la app mostraba datos de ejemplo); se recarga al abrir la pestaña |
| ADM-03 | Bitácora en lenguaje claro, agrupada por día, con filtros por categoría y periodo |
| ADM-04 | Tocar una notificación abre la solicitud (con Aprobar/Rechazar) o la recuperación de contraseña |
| MEC-01 | El catálogo muestra disponibles, reservados y en carrito; se actualiza tras enviar la solicitud. El stock físico baja al confirmar el despacho (ALM-01) |
| MEC-02 | Tras enviar, botón *Ver detalle* que abre Pedidos con la solicitud; Pedidos se recarga al entrar |
| MEC-03 | El detalle de la solicitud muestra el motivo del rechazo destacado |
| PRE-01 | Detalle *Antes / Después* del préstamo en Mecánico (Herramientas) y Almacenista (Dashboard y al cerrar el retorno) |
| ALM-01 | *Despacho* con dos pestañas: **Repuestos** (solicitudes aprobadas, urgentes primero, lista de verificación con stock antes → después y botón *Confirmar despacho*) y **Herramientas** (la salida de pañol de siempre). Al despachar se descuenta el stock, la solicitud pasa a *Entregada*, se notifica al mecánico y, si un repuesto llega a su mínimo, se avisa a administración y almacén |

## Orden sugerido de atención

1. **🔴 Bloqueantes:** AUT-01, AUT-02, ADM-01, MEC-02, ALM-01
2. **🟡 Información incorrecta o incompleta:** MEC-01, MEC-03, ADM-02, PRE-01
3. **🟢 Usabilidad:** ADM-03, ADM-04, AUT-03
