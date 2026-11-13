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
2. **Extravíos:** Alerta inmediata cuando una herramienta/repuesto sea declarado como **extraviado** en mina (con imputación del custodio).
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
