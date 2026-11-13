# Dudas y Hallazgos del Backend (SGSRA-MD)

Documento consolidado y estructurado con el resultado de las pruebas manuales, organizado por arquitectura, roles operativos, reglas de negocio y sistema reactivo de notificaciones.

---

## 2. Generales y Transversales (Todos los Roles)

### REQ-01 · Apartado "Mi Perfil" y Datos de Contacto

- **Disponibilidad por Rol:** Administrador y Almacenista deben contar con su apartado "Mi Perfil" (al igual que el Mecánico).
- **Campos Editables por el Usuario:** En el perfil de Mecánico (y demás roles), el nombre y correo corporativo son inmutables (`readOnly = true`). Solo se debe permitir cambiar:
  - Número telefónico (exactamente 9 dígitos numéricos).
  - Contraseña propia.
- **Limpieza de Campos:**
  - **Eliminar el campo "cargo":** No tiene ninguna función dentro de la aplicación ni existe en la base de datos.
  - **Especialidad:** En lugar de textos libres o inventados, debe indicar el rol operativo del usuario (`Mecánico`, `Almacenista` o `Administrador`).

### BUG-04 · Persistencia de Stock en Listados y Limpieza de Carrito

- **Consistencia de Inventario:** Verificar si al editar/actualizar o una vez terminada la solicitud (o cuando una herramienta se declara prestada), el stock físico no se descuenta en los listados de catálogo o si se trata de un desfase visual en memoria/caché. Esto debe reflejarse consistente en todos los roles y apartados.
- **Limpieza de Carrito:** Después de enviar y formalizar una solicitud, el carrito de compras digital debe limpiarse automáticamente.

---

## 3. Módulo Mecánico

### REQ-03 · Ajustes de Navegación y Carrito

- **Nomenclatura:** Cambiar el nombre del menú `Mis Pedidos` por `Solicitudes` en el panel principal cuando corresponda a la gestión de órdenes.
- **Visualización de Carrito:** En el apartado de solicitudes desplegar automáticamente el carrito de repuestos al seleccionar `Crear solicitud`.

---

## 4. Módulo Administrador

### BUG-02 · "Listar Catálogo" no muestra repuestos creados o editados

- **Pasos:** Crear un repuesto nuevo, o editar uno existente (p. ej. `S-TEM-045`) → Listar catálogo.
- **Resultado observado:**
  - El repuesto no aparece en el listado.
  - Sí se encuentra guardado en la base de datos PostgreSQL.
  - Sí se puede editar y operar con él en otros apartados.

### DUDA-01 / SEC-01 · Jerarquía de Administradores y Seguridad

- **Creación de Administradores:**
  - En la consola de pruebas se permite crear administradores (panel concebido inicialmente para personal de TI).
  - **Regla estricta:** Un Administrador **no debe ser capaz de crear, modificar, eliminar ni deshabilitar nada de otros administradores**.
  - La creación de cuentas administrativas debe estar restringida al área de TI (mediante seed de base de datos o consola técnica dedicada).

### REQ-02 · Gestión de Contraseñas del Personal (Flujo de Recuperación)

- **Regla de Negocio:** El Administrador **NO debe poder cambiar arbitrariamente las contraseñas de otros** (únicamente asignar una contraseña inicial al crear a un mecánico o almacenista).
- **Flujo de Recuperación Formal:**
  1. El Mecánico o Almacenista solicita recuperar su contraseña desde el login indicando motivo. (Solicita DNI y numero telefonico para validar que es el, solo basta con que se los sepa, nada mas)
  2. La solicitud llega a la bandeja de notificaciones del Administrador (`RECUPERACION_CLAVE`).
  3. La función del Administrador es **únicamente aceptar o denegar** la solicitud de cambio de contraseña pendiente (asignando clave temporal al aprobar).
  4. Nunca se permite modificar la contraseña de otro Administrador.

### REQ-04 · Métricas y Reportes Estadísticos

- **Filtros Temporales:** En la opción de métricas de demanda (2.1), permitir seleccionar y filtrar los gráficos/estadísticas por periodos de:
  - `30 días`
  - `60 días`
  - `90 días`
  - `180 días`

---

## 5. Módulo Almacenista

### BUG-03 · Despacho Físico de Solicitudes

- **Problema:** Al momento de despachar una solicitud aprobada, las cantidades de repuestos o herramientas no se descontaban de la base de datos o quizas si y es solo un error de vista.
- **Comportamiento Requerido:** Al confirmar la entrega física, el stock actual de cada ítem aprobado debe descontarse en una transacción atómica validando disponibilidad suficiente.

### DUDA-02 · Dashboard de Herramientas

- **Consulta:** En el dashboard de stock de herramientas, debería incluirse una opción para listarlas usando el mismo metodo de listar catalogo PERO com menos informacion, solo codigo, nombre, stock y disponibilidad

---

## 6. Matriz y Reglas de Notificaciones Reactivas

Asegurar que el sistema de notificaciones funcione bajo las siguientes reglas estrictas por rol:

### 6.1 Notificaciones para el Administrador

1. **Solicitudes:** Únicamente solicitudes con **Prioridad ALTA** emitidas por mecánicos.
2. **Extravíos:** Alerta inmediata cuando una herramienta/repuesto sea declarado como **extraviado** (con imputación del custodio).
3. **Seguridad:** Solicitudes de **cambio / recuperación de contraseña** emitidas por personal operativo.

### 6.2 Notificaciones para el Mecánico

1. **Solicitudes:** Aviso cuando **cualquier solicitud** suya sea aprobada o aprobada parcialmente.
2. **Retornos / Préstamos:** Aviso preventivo cuando el préstamo de una herramienta/repuesto esté **a punto de llegar a 7 días** (próximo a caer en estado atrasado/mora).
3. **Extravíos:** Alerta formal cuando una herramienta extraviada esté **relacionada a él** como último custodio registrado.

### 6.3 Notificaciones para el Almacenista

1. **Moras / Retornos:** Aviso cuando el préstamo de una herramienta/repuesto **cumpla 7 días** y pase a estado atrasado (en mora).
2. **Despacho:** Aviso inmediato cuando una solicitud de **Prioridad ALTA sea APROBADA** para coordinar el retiro físico urgente en el pañol.

---

## 7. Tabla Resumen de Prioridades

| Prioridad | ID      | Rol                | Asunto / Descripción                                                            |
| :-------- | :------ | :----------------- | :------------------------------------------------------------------------------ |
| **Alta**  | BUG-01  | Todos              | Funcionamiento estricto de la matriz de notificaciones por rol                  |
| **Alta**  | BUG-03  | Almacenista        | Descuento atómico de stock al despachar solicitudes                             |
| **Alta**  | BUG-02  | Administrador      | Listar catálogo mostrando ítems creados/editados                                |
| **Alta**  | BUG-04  | Mecánico / Almacén | Consistencia de stock post-solicitud y limpieza de carrito                      |
| **Media** | SEC-01  | Administrador      | Jerarquía: prohibir alterar a otros admins; solo aceptar/denegar recuperaciones |
| **Media** | REQ-02  | Administrador      | Flujo formal de recuperación y aprobación de clave                              |
| **Media** | REQ-04  | Administrador      | Filtros de métricas por 30, 60, 90 y 180 días                                   |
| **Baja**  | REQ-01  | Todos              | Perfiles: bloquear nombre/correo, eliminar campo cargo y corregir especialidad  |
| **Baja**  | REQ-03  | Mecánico           | Renombrar menú a Solicitudes y desplegar carrito                                |
| **Baja**  | DUDA-02 | Almacenista        | Definir necesidad de listado dentro del dashboard de herramientas               |

## 8. Nuevo Análisis: Resolución de Bugs y Consultas de Arquitectura

### BUG-05 (RESUELTO) · Violación del Check Constraint `notificacion_tipo_alerta_check` en PostgreSQL

- **Síntomas Observados:**
  1. Al enviar solicitud de recuperación de clave: `violates check constraint "notificacion_tipo_alerta_check"` (intentaba insertar `tipo_alerta = 'RECUPERACION_CLAVE'`).
  2. Al aprobar solicitud parcial: `violates check constraint "notificacion_tipo_alerta_check"` (intentaba insertar `tipo_alerta = 'SOLICITUD_APROBADA_PARCIAL'`).
  3. Al registrar solicitud con prioridad ALTA: `violates check constraint "notificacion_tipo_alerta_check"` (intentaba insertar `tipo_alerta = 'PRIORIDAD_ALTA'`).
- **Causa Raíz:**
  La tabla `notificacion` en PostgreSQL (`Query_sgsra_db.sql:281`) posee una restricción fija:
  `CHECK (tipo_alerta IN ('INFO', 'SOLICITUD', 'APROBACION', 'RECHAZO', 'MORA', 'EXTRAVIO', 'STOCK_MINIMO'))`.
  Al recibir cadenas descriptivas no contenidas en el `CHECK`, PostgreSQL rechazaba la transacción con `SQLState: 23514`.
- **Solución Implementada:**
  En `FirebaseNotificacionServiceImpl.java` se incorporó el método `normalizarTipoAlerta(String tipoAlerta)` que mapea automáticamente cualquier tipo a los 7 valores estándar de base de datos:
  - `PRIORIDAD_ALTA`, `NUEVA_SOLICITUD` $\rightarrow$ `'SOLICITUD'`
  - `SOLICITUD_APROBADA_PARCIAL`, `DESPACHO_URGENTE`, `ENTREGA` $\rightarrow$ `'APROBACION'`
  - `SOLICITUD_RECHAZADA` $\rightarrow$ `'RECHAZO'`
  - `ALERTA_PREVENTIVA` $\rightarrow$ `'MORA'`
  - `RECUPERACION_CLAVE`, `DESBLOQUEO`, `SEGURIDAD` $\rightarrow$ `'INFO'`
  - `EXTRAVIO` $\rightarrow$ `'EXTRAVIO'`
  - `STOCK_CRITICO` $\rightarrow$ `'STOCK_MINIMO'`
  El detalle específico se conserva intacto en el título y cuerpo del mensaje, garantizando que el `INSERT` siempre cumpla el constraint en PostgreSQL.

---

### DUDA-03 · Privacidad y Aislamiento de Solicitudes por Mecánico

- **Pregunta:** _"Si inicio sesión como otro mecánico, ¿las solicitudes están vinculadas SOLO a mi usuario o todos pueden verlas?"_
- **Respuesta Arquitectónica:**
  - **Aislamiento Total por Usuario:** En la base de datos, cada registro en la tabla `solicitud` posee la clave foránea `dni_mecanico REFERENCES usuario(dni)`.
  - En la API REST (`GET /api/v1/solicitudes/historial`), el backend consulta exclusivamente:
    `solicitudRepository.findByMecanicoDniMecanicoOrderByFechaEmisionDescHoraEmisionDesc(usuario.getDni(), pageable)`.
  - **Resultado:** Un mecánico **solo ve sus propias solicitudes**. Jamás puede ver las solicitudes de otros mecánicos en su historial. Los únicos roles con visión global son el `ADMINISTRADOR` (evaluación y dictamen) y el `ALMACENISTA` (despacho de aprobadas).
- **Ajuste en Consola de Pruebas (`ManualTestingRunner`):**
  - Se agregó la opción **`1.6 Cambiar Mecánico Activo`** en el menú de Mecánico para alternar dinámicamente entre mecánicos registrados (p. ej. Carlos Baro `70000001` vs. Jeanpierre Quispe `60828394`), permitiendo validar de forma interactiva que cada cuenta tiene su propio historial y carrito independiente.

---

### BUG-06 / SEC-02 · Gestión de Administradores desde Consola TI vs. Frontend Móvil

- **Pregunta / Caso:** _"En consola el de TI sí debería tener acceso a hacer lo que quiera con los demás administradores, ¿cómo configuramos esto?"_
- **Estrategia Implementada:**
  - **En la Aplicación Móvil (Flutter / REST):** Se mantiene la regla jerárquica estricta (SEC-01). Ningún usuario desde el teléfono puede modificar, suspender o alterar a otro Administrador.
  - **En la Consola de Pruebas (`ManualTestingRunner`):** Al representar la herramienta directa del área de Sistemas / Soporte TI:
    1. **Opción 4.2:** Permite crear usuarios con rol `ADMINISTRADOR` (`3. ADMINISTRADOR [TI Consola]`), persistiendo en `Usuario` y `Administrador`.
    2. **Opción 4.3:** Permite editar datos de contacto de cualquier usuario, incluyendo administradores.
    3. **Opción 4.4:** Permite suspender o reactivar administradores secundarios (protegiendo únicamente la cuenta raíz `10293847` Leao Chura para evitar bloqueos totales del sistema).
    4. **Opción 4.6 (Nueva):** Permite **restablecer directamente contraseñas por DNI** en modo soporte TI sin requerir el flujo de solicitud previa.

---

### DUDA-04 · Optimización y Fusión de Pantallas en el Rol Almacenista

- **Pregunta:** _"Me he dado cuenta de que el almacenista tiene muchas cosas, ¿se pueden combinar algunas pantallas?"_
- **Propuesta de Unificación UI/UX:**
  Actualmente se contemplaban 6 pestañas en la barra inferior de navegación, lo cual satura la interfaz en móviles:
  1. **El Escáner QR (`escanear_qr_screen.dart`) NO debe ser una pestaña fija:**
     - Debe ser un **Botón Flotante Central (FAB)** o un botón en la barra superior (AppBar) accesible desde cualquier pestaña.
     - **Comportamiento Reactivo Inteligente:** Al escanear una herramienta, si está `Disponible`, la app abre automáticamente el modal _"Registrar Préstamo"_; si está `Prestada`, abre _"Registrar Devolución e Inspección Física"_ (RF38 - RF40). Esto ahorra 2 pestañas y agiliza el trabajo del pañolero.
  2. **Estructura Reducida a 4 Pestañas Limpias:**
     - **Pestaña 1: Operaciones / Dashboard:** Préstamos activos en taller, alertas rojas de mora y despacho de repuestos aprobados.
     - **Pestaña 2: Herramientas:** Catálogo general con búsqueda, filtro por categoría y botón `+` para alta de nueva herramienta (foto + ficha).
     - **Pestaña 3: Historial:** Registro histórico de devoluciones, averías e incidencias.
     - **Pestaña 4: Mi Perfil:** Teléfono y cambio de contraseña propia.
