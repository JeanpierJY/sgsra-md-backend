# 📖 Manual de Usuario — SGSRA-MD (Master Drilling Perú S.A.)

**Sistema de Gestión de Solicitudes de Repuestos y Control de Almacén de Herramientas**  
**Versión:** Producción Android APK (Backend Cloud en Render)

---

## 1. Acceso al Sistema

### 1.1 Inicio de Sesión con Correo y Contraseña
1. Abre la aplicación **SGSRA-MD** en tu teléfono Android.
2. Ingresa tu **Correo corporativo** (`@masterdrilling.com`) y tu **Contraseña**.
   - Puedes tocar el ícono del ojo 👁️ para verificar los caracteres escritos.
3. Presiona **Iniciar Sesión**.
   - *Nota:* El sistema bloquea temporalmente la cuenta tras intentos fallidos consecutivos (3 fallos = 5 min, 6 fallos = 15 min, 9 fallos = bloqueo total).

### 1.2 Acceso Rápido con Huella Dactilar (Biometría)
1. Inicia sesión al menos una vez con tu correo y contraseña.
2. En la pantalla de login aparecerá el botón **Ingresar con huella**.
3. Toca el botón y coloca tu dedo en el sensor biométrico del teléfono para entrar directamente con tu última sesión guardada.

### 1.3 Recuperación de Contraseña / Cuenta Bloqueada
Si olvidaste tu contraseña o tu cuenta fue bloqueada:
1. En la pantalla de login, toca **¿Olvidó su contraseña?**.
2. Ingresa tu **DNI** o correo corporativo y el motivo de la solicitud.
3. Toma una **selfie en vivo** con la cámara frontal como verificación de identidad.
4. Envía la solicitud. El Administrador la revisará y te enviará tu clave temporal (incluso directo por **WhatsApp**).
5. Al ingresar con la clave temporal, dirígete a **Mi Perfil → Cambiar mi contraseña** para definir una contraseña definitiva.

---

## 2. Opciones Generales (Todos los Roles)

En la barra superior derecha encontrarás:
- **Campana de Notificaciones (🔔):** muestra alertas sin leer (solicitudes nuevas, aprobaciones, rechazos, moras, extravíos o stock mínimo). Al tocar una notificación, puedes revisar el detalle o navegar al módulo correspondiente.
- **Botón de Mi Perfil (Avatar / Iniciales):**
  - Permite **ver o actualizar tu foto de perfil**.
  - **Mecánico y Almacenista:** pueden actualizar su número de **teléfono móvil (9 dígitos)**. *(El Administrador no edita teléfono en su perfil).*
  - **Cambiar mi contraseña:** actualiza tu clave personal en cualquier momento.
  - **Cerrar sesión:** sale de forma segura de la cuenta.

---

## 3. Guía por Rol Operativo

### 3.1 Rol: Mecánico (`4 pestañas`)

1. **Catálogo:**
   - Explora los repuestos disponibles con foto, código de parte y stock actual.
   - Usa la barra superior para buscar por **nombre o código**.
   - Toca un repuesto para abrir su **ficha técnica** y agregarlo al carrito.
   - *Los repuestos sin stock (`0`) o deshabilitados aparecen al final o restringidos.*

2. **Solicitudes (Carrito):**
   - Selecciona la **Maquinaria** destino (ej. `MD-RB-01`).
   - Elige la **Prioridad** (`BAJA`, `MEDIA`, `ALTA`).
   - Ajusta las cantidades de cada repuesto y escribe la **Justificación técnica** (mínimo 10 caracteres).
   - Presiona **Enviar solicitud** para generar el correlativo `SOL-2026-XXXX`.
   - *Modo Offline:* si no hay señal en socavón, la solicitud se guarda localmente y se sincroniza al recuperar conexión.

3. **Historial:**
   - Consulta todas tus solicitudes enviadas con filtros por estado: `PENDIENTE`, `APROBADA`, `APROBADA_PARCIAL`, `RECHAZADA`, `ENTREGADA`.
   - Si una solicitud fue rechazada (total o parcialmente), toca la tarjeta para ver el **dictamen y motivo del rechazo**.

4. **Herramientas:**
   - Organizada en **3 pestañas**:
     - **En curso:** herramientas actualmente en tu custodia.
     - **Retraso/Alerta:** préstamos en `MORA` o herramientas reportadas como `EXTRAVIADA`.
     - **Devueltas:** historial de herramientas ya liquidadas en pañol.

---

### 3.2 Rol: Administrador (`5 pestañas`)

1. **Bandeja (Despacho / Solicitudes):**
   - Muestra las solicitudes en orden FIFO con filtros por **prioridad** y rango temporal.
   - Toca una solicitud pendiente para:
     - **Aprobar todo**
     - **Aprobar parcialmente:** marca ítem por ítem cuáles se aprueban y cuáles se rechazan (con motivo obligatorio).
     - **Rechazar todo:** ingresa la justificación técnica (mínimo 15 caracteres).

2. **Auditoría:**
   - Bitácora inalterable de operaciones del sistema con sellado `SHA-256`, IP de origen y filtros por usuario/DNI, acción y rango de fechas.

3. **Catálogo:**
   - Crea nuevos repuestos (**Añadir repuesto**), edita stock/descripción, sube o cambia la fotografía del repuesto y activa/desactiva repuestos con el switch.
   - Usa los filtros **Todos**, **Habilitados** y **Deshabilitados** debajo del buscador.
   - Toca el ícono de empresa en la barra superior para abrir **Proveedores Homologados** y llamar directamente desde tu teléfono.

4. **Reportes:**
   - Visualiza métricas de demanda, repuestos más solicitados (sección desplegable) y exporta reportes en formato **Excel (`.xlsx`)** o **CSV**.

5. **Personal:**
   - Busca trabajadores, activa/desactiva cuentas con el switch y edita su nombre completo.
   - Ingresa a **Solicitudes de recuperación** para comparar la selfie enviada con la foto de perfil:
     - **Aprobar:** genera o asigna una clave temporal y presiona **WhatsApp** para enviársela directo al chat del trabajador con el mensaje prellenado.
     - **Rechazar:** registra el motivo del rechazo.

---

### 3.3 Rol: Almacenista (`4 pestañas`)

1. **Dashboard:**
   - Muestra contadores en vivo del pañol (`Disponibles`, `Prestadas`, `En Mora`, `Mantenimiento`, `Extraviadas`).
   - Lista los **Repuestos Aprobados para Retiro Físico** (toca una solicitud para revisar su detalle) y los **Préstamos Activos**.

2. **Despacho:**
   - **Pestaña Repuestos:** selecciona una solicitud `APROBADA` o `APROBADA_PARCIAL`, verifica las cantidades aprobadas y presiona **Despachar / Entregar** para descontar el stock y marcarla como `ENTREGADA`.
   - **Pestaña Herramientas:** selecciona al mecánico (por nombre/DNI), agrega hasta **5 herramientas** disponibles, registra la firma de recepción y confirma el préstamo.

3. **Retorno:**
   - Escanea el **código QR** de la herramienta con la cámara trasera (o búscala manualmente por código/nombre).
   - Selecciona el estado físico de retorno: `BUEN_ESTADO`, `CON_AVERIA` o `INCOMPLETA`, añade observaciones si corresponde y presiona **Confirmar retorno**.

4. **Herramientas:**
   - Catálogo completo del pañol con filtros por categoría (`Manuales`, `Hidráulicas`, `Neumáticas`, `Eléctricas`) y estado (`Disponible`, `Prestada`, `En Mora`, `Mantenimiento`, `Extraviada`).
   - Muestra directamente quién tiene cada herramienta prestada y su DNI.
   - **Nueva herramienta (+):** registra una herramienta nueva, sube su fotografía y visualiza/descarga su **etiqueta QR**.
   - **Reportar extravío:** imputa la pérdida de una herramienta al último custodio registrado y cambia su estado a `Extraviada`.
