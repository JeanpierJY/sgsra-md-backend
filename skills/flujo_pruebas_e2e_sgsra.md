# 🧪 Flujo Principal de Pruebas E2E con Demostraciones — SGSRA-MD

Guía paso a paso para validar de extremo a extremo todas las funcionalidades críticas de la aplicación móvil **SGSRA-MD** contra el backend desplegado en Render (`https://sgsra-md-backend.onrender.com`).

---

## 🔑 Credenciales Oficiales de Prueba (Datos Semilla)

| Rol | Correo Corporativo | Contraseña | DNI | Nombre |
| :--- | :--- | :--- | :--- | :--- |
| **Administrador** | `leao.chura@masterdrilling.com` | `admin` | `10293847` | Leao Chura |
| **Mecánico** | `carlos.baro@masterdrilling.com` | `meca` | `70000001` | Carlos Mendoza Baro |
| **Almacenista** | `marcos.baro@masterdrilling.com` | `alma` | `70000002` | Marcos Ramos Baro |

> 💡 **Nota sobre Render Cloud:** Si el servidor llevaba más de 15 minutos sin actividad y UptimeRobot no respondió, el primer login puede demorar entre 1 y 2 minutos mientras despierta el contenedor.

---

## Etapa 1: Inicio de Sesión (Contraseña y Huella), Perfil y Recuperación

### Demostración 1.1 — Login con Contraseña y Acceso Biométrico (Huella)
1. Abre la app e inicia sesión como **Mecánico**:
   - Correo: `carlos.baro@masterdrilling.com` / Contraseña: `meca`
2. **Resultado esperado:** Ingresas al módulo de Mecánico con 4 pestañas (`Catálogo`, `Solicitudes`, `Historial`, `Herramientas`).
3. Toca el ícono de **Mi Perfil** (arriba a la derecha) → verifica que aparezca tu DNI (`70000001`), correo, rol, foto de perfil y campo editable de teléfono → presiona **Cerrar sesión**.
4. De vuelta en el Login, verifica que aparece el botón **Ingresar con huella**, tócalo y autentícate con tu huella dactilar.
   - **Resultado esperado:** Inicia sesión automáticamente sin volver a escribir la contraseña.

### Demostración 1.2 — Recuperación de Contraseña + Envío por WhatsApp
1. En el Login, toca **¿Olvidó su contraseña?**.
2. Ingresa el DNI `70000001` (Carlos Mendoza Baro), escribe motivo: `"Olvido de clave en cambio de turno"`, tómate una **selfie** con la cámara frontal y envía la solicitud.
3. Cierra o cambia de sesión e inicia sesión como **Administrador** (`leao.chura@masterdrilling.com` / `admin`).
4. Ve a **Personal → Solicitudes de recuperación**, abre la solicitud pendiente, compara la selfie con la foto de perfil y toca **Aprobar**.
5. En el modal *"Solicitud aprobada"*, presiona el botón verde **WhatsApp**.
   - **Resultado esperado:** Se abre WhatsApp directo al chat del mecánico (si no tenía teléfono en BD, te pide el celular de 9 dígitos) con el mensaje prellenado:  
     `Tu contraseña temporal es: <clave>`  
     `Recuerda cambiarla una vez inicies sesión.`

---

## Etapa 2: Ciclo Completo de Solicitud y Despacho de Repuestos

### Demostración 2.1 — Mecánico emite Solicitud de Repuestos
1. Inicia sesión como **Mecánico** (`carlos.baro@masterdrilling.com` / `meca`).
2. En **Catálogo**, busca `P-REX-024` (*Bomba de pistones axiales Rexroth A4VSO 125 DR*) y agrégala al carrito (cantidad `1`).
3. Busca también `H-ESP-118` (*Manguera espiral 4SP 1 pulgada x 3000 PSI*) y agrégala (cantidad `2`).
4. Ve a la pestaña **Solicitudes**:
   - Selecciona maquinaria: `MD-RB-01` (*Raise Borer Rhino 1008 DC*).
   - Prioridad: `ALTA`.
   - Justificación técnica: `"Fuga en linea hidraulica principal durante perforacion nivel 1200"`.
5. Presiona **Enviar solicitud**.
   - **Resultado esperado:** Se genera un código `SOL-2026-XXXX` en estado `PENDIENTE` (visible en la pestaña **Historial**).

### Demostración 2.2 — Administrador evalúa la Solicitud y gestiona Catálogo
1. Inicia sesión como **Administrador** (`leao.chura@masterdrilling.com` / `admin`).
2. Verifica la **Campana de Notificaciones (🔔)**: debe mostrar la alerta de nueva solicitud `ALTA`. Toca la notificación para ir a la bandeja.
3. En **Bandeja**, abre la solicitud recién creada y pruébala con **Aprobación Parcial** (o Total):
   - Aprueba `P-REX-024` (`1` unidad) y, si deseas probar rechazo parcial, rechaza un ítem indicando el motivo (ej. `"Stock reservado para otro frente"`), o aprueba todo.
4. Ve a la pestaña **Catálogo**:
   - Prueba los filtros **Todos**, **Habilitados** y **Deshabilitados**.
   - Desactiva temporalmente un repuesto con el switch (ej. `F-HYD-882`) y verifica que pasa a **Deshabilitados** sin eliminarse; luego vuelve a habilitarlo.
5. Ve a **Reportes** para verificar las métricas actualizadas y a **Auditoría** para comprobar el registro con hash `SHA-256`.

### Demostración 2.3 — Almacenista despacha los Repuestos
1. Inicia sesión como **Almacenista** (`marcos.baro@masterdrilling.com` / `alma`).
2. En **Dashboard**, verifica la notificación (🔔) y confirma que la solicitud aparece en **Repuestos Aprobados para Retiro Físico**.
3. Ve a **Despacho → Repuestos**, abre la solicitud `SOL-2026-XXXX` y presiona **Despachar / Entregar**.
   - **Resultado esperado:** La solicitud cambia a estado `ENTREGADA` y el stock de `P-REX-024` se descuenta automáticamente en PostgreSQL (puedes comprobarlo luego en el Catálogo).

---

## Etapa 3: Ciclo Completo de Herramientas en Pañol (Préstamo, Retorno QR, Alta y Reporte)

### Demostración 3.1 — Almacenista presta una Herramienta al Mecánico
1. Como **Almacenista**, ve a **Despacho → Herramientas**.
2. Selecciona al mecánico **Carlos Mendoza Baro** (`DNI 70000001`).
3. Elige una herramienta en estado **Disponible** (ej. `HER-BOM-009` o cualquiera disponible en lista), registra la firma del mecánico y confirma el préstamo.
   - **Resultado esperado:** La herramienta cambia a estado `Prestada` y en la pestaña **Herramientas** muestra el nombre `Carlos Mendoza Baro` y su `DNI 70000001`.
4. *(Opcional)* Inicia sesión como **Mecánico** y entra a **Herramientas → En curso** para verificar que la herramienta aparece bajo su custodia.

### Demostración 3.2 — Almacenista recibe Devolución con QR / Buscador
1. Como **Almacenista**, ve a la pestaña **Retorno**.
2. Escanea el **código QR** de la herramienta prestada (o búscala en el buscador predictivo superior por su código).
3. En el modal de inspección física:
   - Selecciona `BUEN_ESTADO` (o `CON_AVERIA` si deseas probar el paso automático a `Mantenimiento`) y agrega una observación (ej. `"Retorno conforme tras guardia"`).
   - Presiona **Confirmar retorno**.
   - **Resultado esperado:** El préstamo se cierra y la herramienta vuelve a `Disponible` (o `Mantenimiento` si tuvo avería).

### Demostración 3.3 — Almacenista crea una Nueva Herramienta
1. En la pestaña **Herramientas**, toca el botón flotante **Nueva herramienta (+)**.
2. Completa los datos de demostración:
   - Código: `HER-PRU-099`
   - Nombre: `Llave dinamometrica de prueba 1/2`
   - Marca: `Stanley`
   - Categoría: `Manuales`
   - Adjunta una foto desde cámara o galería (opcional) y guarda.
   - **Resultado esperado:** La herramienta se crea correctamente en estado `Disponible` sin error de `correoAlmacenista`, aparece en el catálogo y permite generar/visualizar su etiqueta QR.

### Demostración 3.4 — Almacenista reporta una Herramienta (Extravío)
1. En la misma pestaña **Herramientas**, asegúrate de tener una herramienta prestada (ej. `HER-TOR-004` prestada a Carlos Mendoza Baro) o usa la herramienta recién prestada.
2. Toca el botón de **Reportar extravío** (o abre el detalle de la herramienta prestada y selecciona reportar extravío).
3. Selecciona la herramienta y escribe el motivo del reporte: `"Extravio reportado en frente de perforacion nivel 1200 durante cambio de guardia"`.
4. Confirma el reporte.
   - **Resultado esperado:**
     - La herramienta cambia a estado **Extraviada** (badge rojo).
     - Se imputa la responsabilidad al último custodio (`Carlos Mendoza Baro`).
     - El contador de **Extraviadas** en el **Dashboard** del almacenista se incrementa en tiempo real y se genera la notificación correspondiente.
     - En la vista del **Mecánico → Herramientas → Retraso/Alerta**, la herramienta aparece marcada como `EXTRAVIADA`.
