# MATRIZ INTEGRAL DE TESTING MANUAL E2E Y NUEVOS HALLAZGOS (SGSRA-MD)

Documento técnico de análisis exhaustivo de flujos de negocio de inicio a fin (End-to-End), combinaciones de prueba para consola/móvil y nuevos hallazgos detectados en la auditoría del backend.

---

## 1. Resumen Consolidado de Bugs Previos (Ya Resueltos)

| ID | Módulo | Problema Original | Estado y Solución Aplicada |
| :--- | :--- | :--- | :--- |
| **BUG-01** | Notificaciones | Matriz de alertas reactivas mezclada sin segmentación | **RESUELTO:** Segmentado por rol y prioridad (ALTA a Admin, dictámenes a Mecánico, moras a Almacén). |
| **BUG-02** | Catálogo Admin | Repuestos recién creados/editados no aparecían en listados | **RESUELTO:** Ordenamiento alfanumérico persistente `findByActivoTrueOrderByCodParteAsc` y paginación 100. |
| **BUG-03** | Almacén Repuestos | Despacho de solicitudes no descontaba stock físico | **RESUELTO:** Descuento atómico transaccional en `despacharEntregaRepuestos` con pre-check de disponibilidad. |
| **BUG-04** | Mecánico | Carrito no se limpiaba tras formalizar solicitud | **RESUELTO:** Limpieza obligatoria `carritoRepuestos.clear()` en `solicitudService` y en runner. |
| **BUG-05** | Base de Datos | `notificacion_tipo_alerta_check` violado (`SQLState 23514`) | **RESUELTO:** Función `normalizarTipoAlerta()` mapea tipos hacia los 7 válidos de PostgreSQL. |
| **SEC-01/02** | Jerarquía Admin | Restricciones de TI vs Administrador operativo | **RESUELTO:** Móvil bloquea alteración entre admins; Consola TI permite gestionar y resetear contraseñas. |

---

## 2. Nuevos Hallazgos y Casos Borde Detectados (Auditoría de Código E2E)

Tras auditar minuciosamente el código desde la creación de cuentas hasta el cierre de ciclos operativos, se identificaron los siguientes **4 nuevos hallazgos** a considerar antes de producción:

### HALLAZGO-01 (Lógica de Almacén) · Herramientas devueltas como "Incompleta" pasan a "Disponible"
- **Ubicación:** `PrestamoServiceImpl.java:136-140`
- **Condición Actual:**
  ```java
  if (itemReq.getEstadoFisico() == EstadoDevolucion.CON_AVERIA) {
      herramienta.setEstadoActual(EstadoHerramienta.EN_MANTENIMIENTO.getDescripcionSql());
  } else {
      herramienta.setEstadoActual(EstadoHerramienta.DISPONIBLE.getDescripcionSql());
  }
  ```
- **Falla:** Si un mecánico devuelve una herramienta calificada como `INCOMPLETA` (p. ej. le falta una boquilla o pieza accesoria), entra al bloque `else` y el sistema la marca erróneamente como `Disponible`, permitiendo que otro mecánico la solicite de inmediato.
- **Comportamiento Correcto:** Si es `INCOMPLETA`, debe pasar a `En Mantenimiento` o permanecer retenida en pañol con incidencia registrada, nunca `Disponible`.

---

### HALLAZGO-02 (Historial de Custodia) · `hora_retorno` en `prestamo_detalle` no se actualiza al devolver
- **Ubicación:** `PrestamoServiceImpl.java:130-155` y `ManualTestingRunner.java:395`
- **Condición Actual:** Al registrar una devolución formal, se crea la entidad `DevolucionDetalle`, pero nunca se actualiza el campo `horaRetorno` en los registros existentes de `prestamo_detalle`.
- **Falla Visual:** En `ManualTestingRunner.java:395` y en la pantalla móvil de historial de herramientas prestadas, el sistema evalúa:
  ```java
  d.getHoraRetorno() != null ? d.getHoraRetorno() : "EN POSESION / ACTIVO"
  ```
  Al ser siempre `null`, las herramientas devueltas siguen figurando visualmente como `"EN POSESION / ACTIVO"` dentro del detalle histórico del préstamo del mecánico.
- **Comportamiento Correcto:** Al procesar la devolución, actualizar `prestamoDetalle.setHoraRetorno(LocalTime.now())` y guardar en BD.

---

### HALLAZGO-03 (Consistencia de Dashboard) · Herramientas en mora no actualizan `estado_actual` en la tabla `herramienta`
- **Ubicación:** `PrestamoServiceImpl.java:228-245`
- **Condición Actual:** Al ejecutarse `verificarAlertasPrestamos()`, cuando un préstamo supera los 7 días de retraso, se actualiza:
  `p.setEstadoPrestamo(EstadoPrestamo.MORA);`
  Sin embargo, **no se actualizan las herramientas asociadas** en la tabla `herramienta` (`estado_actual = 'En Mora'`).
- **Falla:** El dashboard de pañol y los listados de catálogo siguen mostrando la herramienta con `estado_actual = 'Prestada'` en lugar de `En Mora`, impidiendo que se active la alerta visual roja requerida por RF43.
- **Comportamiento Correcto:** Al pasar el préstamo a `MORA`, iterar sus detalles y ejecutar `h.setEstadoActual(EstadoHerramienta.EN_MORA.getDescripcionSql())`.

---

### HALLAZGO-04 (Compatibilidad de Esquema) · Ausencia de columna `telefono` en tabla `almacenista`
- **Ubicación:** `Query_sgsra_db.sql:59-66` vs `AutenticacionServiceImpl.java:159-170`
- **Condición:** La tabla `mecanico` cuenta con `telefono VARCHAR(15)`, pero la tabla `almacenista` no posee dicha columna en el DDL oficial.
- **Impacto:** Si un almacenista intenta recuperar su contraseña validando teléfono, el backend valida el DNI pero no puede cotejar el teléfono contra su ficha. No arroja error en BD, pero es una asimetría entre ambos perfiles operativos.
- **Recomendación:** Agregar opcionalmente `telefono VARCHAR(15)` a la tabla `almacenista` si se desea paridad total con los mecánicos.

---

## 3. Matriz Exhaustiva de Combinaciones de Testing E2E

### Módulo 1: Seguridad, Autenticación y Perfiles (RF01 - RF08, REQ-01, REQ-02, SEC-01)

| Caso de Prueba | Entrada / Acción | Resultado Esperado | Resultado Backend |
| :--- | :--- | :--- | :--- |
| **TC-SEC-01** | Login con contraseña errónea (Intentos 1 y 2) | Rechazo con conteo de intentos restantes (RF06). | `HTTP 401 Unauthorized` + decremento de cupo. |
| **TC-SEC-02** | Login con contraseña errónea (Intento 3 consecutivo) | Bloqueo automático de cuenta a estado `BLOQUEADO`. | `HTTP 403 Forbidden` (`CuentaBloqueadaException`). |
| **TC-SEC-03** | Login con cuenta bloqueada | Rechazo directo indicando contactar a soporte. | `HTTP 403 Forbidden` + log de auditoría. |
| **TC-SEC-04** | Recuperación con DNI inexistente o formato inválido | Falla con mensaje explícito sin exponer datos internos. | `HTTP 404 / 400 BadRequestException`. |
| **TC-SEC-05** | Administrador intenta usar recuperación por formulario | Bloqueo estricto: debe gestionarse con TI. | `HTTP 403 AccesoDenegadoException`. |
| **TC-SEC-06** | Mecánico solicita recuperación con teléfono disconforme | Falla si el teléfono no coincide con el registrado. | `HTTP 400 BadRequestException`. |
| **TC-SEC-07** | Solicitud de recuperación duplicada | Bloqueo: ya existe una solicitud `PENDIENTE`. | `HTTP 400 BadRequestException`. |
| **TC-SEC-08** | Admin aprueba recuperación asignando clave temporal | Clave temporal hasheada con BCrypt, cuenta pasa a `ACTIVO`, intentos a 0. | `HTTP 200 OK` + notificación push/BD. |
| **TC-SEC-09** | Admin rechaza recuperación con motivo | Solicitud pasa a `RECHAZADA` con motivo visible al usuario. | `HTTP 200 OK`. |
| **TC-SEC-10** | Edición de perfil propio (nombre, correo o DNI) | Bloqueado: campos `readOnly = true`, solo teléfono mutable (REQ-01). | Backend ignora campos fijos; solo altera teléfono. |
| **TC-SEC-11** | Cambio de contraseña propia con clave actual errónea | Falla de validación criptográfica en BCrypt. | `HTTP 400 BadRequestException`. |

---

### Módulo 2: Catálogo de Repuestos y Solicitudes del Mecánico (RF09 - RF20, BUG-04)

| Caso de Prueba | Entrada / Acción | Resultado Esperado | Resultado Backend |
| :--- | :--- | :--- | :--- |
| **TC-SOL-01** | Intentar crear solicitud con carrito digital vacío | Rechazo previo: "El carrito está vacío". | Bloqueado en UI y en `ValidadorSolicitud`. |
| **TC-SOL-02** | Agregar repuesto con stock en 0 al carrito | Permitido agregar (para requerir compra o despacho futuro). | Almacenado en carrito en memoria. |
| **TC-SOL-03** | Enviar solicitud con maquinaria inexistente | Error de integridad relacional: máquina no existe. | `HTTP 404 RecursoNoEncontradoException`. |
| **TC-SOL-04** | Justificación técnica menor a 10 caracteres | Falla de validación obligatoria (RF16). | `HTTP 400 BadRequestException`. |
| **TC-SOL-05** | Emisión exitosa con Prioridad BAJA o MEDIA | Genera `SOL-2026-XXXX` en `PENDIENTE`, limpia carrito, **NO** notifica a Admin. | `HTTP 200 OK` + `carritoRepuestos.clear()`. |
| **TC-SOL-06** | Emisión exitosa con Prioridad ALTA | Genera solicitud, limpia carrito y **emite alerta reactiva inmediata** a Administradores. | `HTTP 200 OK` + `notificacionService` (ALTA). |
| **TC-SOL-07** | Aislamiento entre mecánicos | Mecánico B consulta historial; solo ve sus propias órdenes. | `findByMecanicoDniMecanico` estricto. |

---

### Módulo 3: Dictamen Administrativo, Aprobaciones y Almacén (RF21 - RF32, BUG-03)

| Caso de Prueba | Entrada / Acción | Resultado Esperado | Resultado Backend |
| :--- | :--- | :--- | :--- |
| **TC-ADM-01** | Aprobación total de solicitud PENDIENTE | Solicitud pasa a `APROBADA`, ítems a `APROBADO`, notifica al mecánico. | `HTTP 200 OK` + auditoría SHA-256. |
| **TC-ADM-02** | Aprobación total de solicitud Prioridad ALTA | Solicitud aprobada + alerta reactiva a Almacenista para despacho urgente. | `HTTP 200 OK` + notificación `ALMACENISTA`. |
| **TC-ADM-03** | Rechazo total con motivo < 15 caracteres | Bloqueo por regla de negocio (RF25). | `HTTP 400 BadRequestException`. |
| **TC-ADM-04** | Rechazo total formal con motivo válido | Solicitud pasa a `RECHAZADA`, registra `dictamen_rechazo` y `detalle_rechazo`. | `HTTP 200 OK` + notificación con motivo al mecánico. |
| **TC-ADM-05** | Aprobación parcial con ítem rechazado sin causa | Bloqueo: cada ítem denegado exige sustento técnico. | `HTTP 400 BadRequestException`. |
| **TC-ADM-06** | Aprobación mixta (unos aprobados, otros rechazados) | Estado final `APROBADA_PARCIAL`. | `HTTP 200 OK`. |
| **TC-ADM-07** | Aprobación parcial donde todos los ítems fueron denegados | Estado final transiciona automáticamente a `RECHAZADA`. | `s.setEstadoSolicitud(EstadoSolicitud.RECHAZADA)`. |
| **TC-ALM-01** | Despacho de solicitud con stock suficiente | Descuenta stock físico de BD atómicamente, estado pasa a `ENTREGADA`. | `saveAndFlush()` con rollback transaccional seguro. |
| **TC-ALM-02** | Despacho de solicitud con stock insuficiente | Bloquea entrega, no descuenta nada (rollback íntegro). | `HTTP 400 BadRequestException`. |
| **TC-ALM-03** | Stock cae por debajo de stock mínimo tras despacho | Despacha y dispara alerta automática a Administrador por `STOCK_MINIMO`. | `HTTP 200 OK` + alerta `STOCK_MINIMO`. |

---

### Módulo 4: Control de Herramientas y Pañol (RF33 - RF45)

| Caso de Prueba | Entrada / Acción | Resultado Esperado | Resultado Backend |
| :--- | :--- | :--- | :--- |
| **TC-PAN-01** | Préstamo de herramienta en estado distinto de 'Disponible' | Rechazo inmediato: no se puede prestar herramienta prestada/en mora/averiada. | `HTTP 400 BadRequestException`. |
| **TC-PAN-02** | Préstamo a mecánico que ya tiene 5 herramientas | Bloqueo por cupo máximo excedido (RF36). | `CupoPrestamoValidator: validarCupoDisponible`. |
| **TC-PAN-03** | Préstamo a mecánico con herramienta en mora | Bloqueo preventivo por moras activas pendientes. | `CupoPrestamoValidator: validarAusenciaDeMoras`. |
| **TC-PAN-04** | Despacho exitoso de herramienta | Estado de herramienta pasa a `Prestada`, crea préstamo con firma obligatoria. | `HTTP 200 OK` + `EstadoHerramienta.PRESTADA`. |
| **TC-PAN-05** | Devolución en 'Buen Estado' | Herramienta pasa a `Disponible`, préstamo se cierra. | `HTTP 200 OK` + `EstadoHerramienta.DISPONIBLE`. |
| **TC-PAN-06** | Devolución 'Con Avería' | Herramienta pasa a `En Mantenimiento` para taller. | `HTTP 200 OK` + `EstadoHerramienta.EN_MANTENIMIENTO`. |
| **TC-PAN-07** | Verificación de préstamos con 5-6 días | Emisión de alerta preventiva al mecánico sin cambiar estado. | `HTTP 200 OK` + alerta `ALERTA_PREVENTIVA` (MORA). |
| **TC-PAN-08** | Verificación de préstamos con 7+ días | Préstamo pasa a `MORA`, emite alerta a Almacén y Mecánico. | `HTTP 200 OK` + alerta `MORA`. |
| **TC-PAN-09** | Reportar herramienta extraviada | Herramienta pasa a `Extraviada`, imputa último custodio, notifica a Admin y Mecánico. | `HTTP 200 OK` + `auditoriaService`. |

---

## 4. Próximos Pasos Sugeridos

1. **Revisión del usuario de los 4 nuevos hallazgos:** Evaluar si se desea que apliquemos las soluciones de los hallazgos 01, 02 y 03 en `PrestamoServiceImpl.java`.
2. **Ejecución del testing manual guiado en consola:** Probar la nueva opción de cambio de mecánico (`1.6`), creación de administradores en modo TI (`4.2`) y reseteo de claves (`4.6`).
3. **Commit en GitHub Desktop:** Registrar este análisis y la documentación consolidada en la rama `JS_Rama`.

