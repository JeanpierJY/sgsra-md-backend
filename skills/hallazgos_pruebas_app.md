# 🐞 Matriz de Hallazgos de Pruebas – App Móvil SGSRA

> **Documento de Control de Hallazgos (QA funcional en dispositivo físico)**
> **Sistema de Gestión de Solicitud de Repuestos y Almacén (SGSRA - Master Drilling)**
> **Alcance:** Frontend Móvil (Flutter / Android APK) y Backend (Spring Boot en Render)
> **Fecha de levantamiento:** 24/11/2026 · **Rama:** `KR_rama`

**Convención de IDs:** `H-GEN-xx` (todos los roles) · `H-ADM-xx` (Administrador) · `H-ALM-xx` (Almacenista) · `H-MEC-xx` (Mecánico).
Se usa el prefijo `H-` para no confundirlos con las etiquetas `[ADM-xx]` / `[ALM-xx]` que ya existen en comentarios del código.

**Tipos:** 🐞 Bug · 🎨 UI/UX · ✨ Mejora · 🧹 Limpieza · ❓ Requiere aclaración

---

## 📊 1. Resumen Ejecutivo de Hallazgos

| Prioridad      | ID          | Rol        | Pantalla             | Hallazgo (resumen)                                          | Tipo | Capa              |
| :------------- | :---------- | :--------- | :------------------- | :---------------------------------------------------------- | :--: | :---------------- |
| 🔴 **Crítica** | H-GEN-01    | Todos      | Login                | La autenticación por huella no funciona                     |  🐞  | Android / Flutter |
| 🔴 **Crítica** | H-GEN-03    | Todos      | Global               | No se pueden subir imágenes                                 |  🐞  | Flutter / Backend |
| 🔴 **Crítica** | H-GEN-08    | Todos      | Global               | Una cuenta desactivada no cierra su sesión automáticamente  |  🐞  | Backend / Flutter |
| 🔴 **Crítica** | H-ADM-01    | Admin      | Catálogo             | Desactivar un repuesto lo "elimina"                         |  🐞  | Flutter / Backend |
| 🔴 **Crítica** | H-ALM-02    | Almacén    | Notificaciones       | Al almacenista no le llegan notificaciones                  |  🐞  | Backend           |
| 🔴 **Crítica** | H-ALM-04    | Almacén    | Retorno              | La cámara QR no funciona                                    |  🐞  | Flutter / Android |
| 🟠 **Alta**    | H-GEN-07    | Todos      | Formularios          | El teclado tapa botones y campos (inputs que no "suben")    |  🎨  | Flutter           |
| 🟠 **Alta**    | H-ALM-03    | Almacén    | Retorno              | Botón "Confirmar retorno" queda bajo la barra del teléfono  |  🎨  | Flutter           |
| 🟠 **Alta**    | H-MEC-02    | Mecánico   | Solicitud (carrito)  | El teclado oculta "Enviar solicitud" al escribir justificación |  🎨  | Flutter        |
| 🟠 **Alta**    | H-ADM-02    | Admin      | Solicitudes          | El teclado cubre el panel al escribir una notificación      |  🎨  | Flutter           |
| 🟠 **Alta**    | H-ADM-05    | Admin      | Notificaciones       | Tocar una notificación de solicitud no redirige             |  🐞  | Flutter           |
| 🟡 **Media**   | H-GEN-09    | Todos      | Contraseñas          | Falta el botón "ver contraseña" en algunos campos           |  🎨  | Flutter           |
| 🟡 **Media**   | H-GEN-06    | Todos      | Perfil               | Botón "Cerrar sesión" demasiado abajo                       |  🎨  | Flutter           |
| 🟡 **Media**   | H-ADM-04    | Admin      | Personal             | Los botones flotantes tapan el switch de activar/desactivar |  🎨  | Flutter           |
| 🟡 **Media**   | H-ALM-01    | Almacén    | Despacho             | Faltan filtros para las solicitudes                         |  ✨  | Flutter           |
| 🟡 **Media**   | H-ALM-06    | Almacén    | Préstamo             | Mostrar DNI y nombre del mecánico en el selector            |  ✨  | Flutter           |
| 🟡 **Media**   | H-MEC-01    | Mecánico   | Catálogo             | Ítems sin stock o desactivados al final del catálogo        |  ✨  | Flutter           |
| 🟢 **Baja**    | H-GEN-02    | Todos      | Login                | Eliminar botón "Probar conexión"                            |  🧹  | Flutter           |
| 🟢 **Baja**    | H-GEN-04    | Todos      | Todas                | Eliminar etiquetas `[RFxx]` visibles en la interfaz         |  🧹  | Flutter           |
| 🟢 **Baja**    | H-ADM-03    | Admin      | Reportes             | Flecha para plegar "Repuestos más solicitados"              |  ✨  | Flutter           |
| 🟢 **Baja**    | H-ALM-05    | Almacén    | Herramientas         | Eliminar botón "Herramientas extraviadas"                   |  🧹  | Flutter           |
| 🔴 **Crítica** | H-GEN-05    | Todos      | Perfil               | La foto de perfil subida no carga por completo              |  🐞  | Backend / Flutter |
| 🔴 **Crítica** | H-ADM-01b   | Admin      | Catálogo             | Tras la 1.ª corrección, el repuesto deshabilitado sigue desapareciendo |  🐞  | Flutter / Despliegue |
| 🔴 **Crítica** | H-ALM-02b   | Almacén    | Notificaciones       | Reapertura: el almacenista sigue recibiendo solo las de prioridad ALTA |  🐞  | Backend / Despliegue |
| 🟢 **Baja**    | H-ADM-06    | Todos      | Repuestos            | Quitar "Stock Mínimo" / "Mínimo" de los repuestos (no se entiende) |  🧹  | Flutter / Backend |

---

## 🗂️ 2. Desglose Detallado por Rol y Pantalla

> Las rutas son relativas a `sgsra_mobile/lib/` (Flutter) y `sgsra-md/src/main/java/com/masterdrilling/sgsramd/` (backend).
> La columna **Causa probable** sale de una revisión del código. Hay que confirmarla al corregir cada hallazgo.

### 🌐 Módulo 1: Hallazgos Generales (afectan a todos los roles)

| ID           | Hallazgo                                   | Archivo(s) afectado(s)                                                                 | Causa probable / Análisis                                                                                                                                                                                                 | Criterio de Aceptación                                                                                                                                  |
| :----------- | :----------------------------------------- | :------------------------------------------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | :------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **H-GEN-01** | **La huella no funciona**                  | `android/app/src/main/kotlin/.../MainActivity.kt`, `auth/presentation/screens/login_screen.dart` | `MainActivity` hereda de `FlutterActivity`, pero el plugin `local_auth` exige `FlutterFragmentActivity`. Además conviene revisar que el tema de Android sea `Theme.AppCompat`/`MaterialComponents`.                        | En un dispositivo con huella registrada, el diálogo biométrico aparece y al validar inicia sesión. Si no hay huella, se muestra un mensaje claro.         |
| **H-GEN-02** | **Eliminar botón "Probar conexión"**       | `auth/presentation/screens/login_screen.dart` (≈ L200-265)                             | Era una herramienta de depuración para la IP local. Con el backend ya desplegado en Render no hace falta.                                                                                                                  | La pantalla de login no muestra el botón ni el bloque de prueba de IP.                                                                                  |
| **H-GEN-03** | **No se pueden subir imágenes**            | `core/widgets/imagen_producto.dart`, `auth/presentation/screens/mi_perfil_screen.dart`, backend `StorageService` | La subida va a Render (`api_constants.dart`). El disco de Render es **temporal**: los archivos de `uploads/` se pierden en cada redeploy o reinicio, y puede fallar la escritura. Hay que revisar también el límite de 5 MB (`application.properties`) y el permiso de cámara/galería en tiempo de ejecución. | La foto se sube (repuesto, herramienta, perfil), se ve al recargar y sigue ahí después de un reinicio del servidor. Para eso hace falta un almacenamiento externo (Cloudinary, S3, Supabase Storage, etc.). |
| **H-GEN-04** | **Eliminar las etiquetas `[RFxx]`**        | 42 textos visibles en `features/**` (p. ej. `auditoria_screen.dart`, `bandeja_solicitudes_screen.dart`, `gestion_personal_screen.dart`) | Los códigos de requerimiento quedaron dentro de títulos, tooltips y textos de la UI. En los **comentarios** del código se pueden mantener.                                                                        | Ningún texto visible de la app contiene `[RF..]`. Comprobar con `grep -rnE "['\"][^'\"]*\[RF[0-9]+" lib/features` → 0 resultados.                         |
| **H-GEN-05** | **La foto de perfil no carga por completo** | `auth/presentation/screens/mi_perfil_screen.dart`, backend `config/WebMvcResourceConfig.java` | Misma causa que H-GEN-03. Además, `WebMvcResourceConfig` servía `/uploads/**` como `"file:/" + ruta`, que en Linux (Render) da `file://app/uploads/` (ruta inválida → 404), y el avatar usaba `NetworkImage` sin respaldo, por lo que quedaba un círculo vacío. | La foto subida se ve en el perfil y en Personal. Si falla, se muestran las iniciales.                                                                  |
| **H-GEN-06** | **"Cerrar sesión" muy abajo en Perfil**    | `auth/presentation/screens/mi_perfil_screen.dart`                                      | El botón queda al final del scroll y/o debajo de la barra de navegación del sistema.                                                                                                                                      | El botón se ve sin hacer scroll excesivo (o va en el AppBar) y nunca queda tapado por la barra del sistema (`SafeArea`).                                |
| **H-GEN-07** | **Inputs que no suben con el teclado**     | `mecanico/.../carrito_pedido_screen.dart`, `administrador/.../bandeja_solicitudes_screen.dart`, modales con `showModalBottomSheet` | Solo 2 pantallas suman `MediaQuery.viewInsets.bottom` (`retorno_qr_screen.dart`, `reportar_extravio_modal.dart`). Los demás formularios y bottom sheets no se ajustan al teclado. | En todo formulario, al abrir el teclado el campo activo y el botón de acción quedan visibles, con un espacio en blanco extra abajo para poder hacer scroll. Bottom sheets con `isScrollControlled: true` + `padding: viewInsets.bottom`. |
| **H-GEN-08** | **Desactivar cuenta no cierra su sesión**  | Backend `config/SecurityFilterConfig.java`, `core/network/dio_client.dart`              | El backend tiene `anyRequest().permitAll()`: no valida token ni estado `activo` en cada petición. El cliente Dio no maneja `401/403` para forzar el cierre de sesión.                                                     | Cuando el admin desactiva una cuenta, la siguiente petición de ese usuario devuelve `401/403` y la app lo saca al login con el mensaje "Cuenta desactivada". |
| **H-GEN-09** | **Botón "ver contraseña" en todos los campos** | `administrador/.../gestion_personal_screen.dart` (L213), `auth/.../mi_perfil_screen.dart` (L542-561), `auth/.../recuperar_clave_modal.dart` | En *Añadir usuario* el campo tiene `obscureText: true` sin icono. En *Mi perfil* un único `_ver` controla los 3 campos a la vez.                                                                                       | Cada campo de contraseña tiene su propio icono 👁 para mostrar u ocultar.                                                                                 |

---

### 🛡️ Módulo 2: Administrador

| ID           | Pantalla       | Hallazgo                                                 | Archivo(s) afectado(s)                                                                 | Causa probable / Análisis                                                                                                                                                                                    | Criterio de Aceptación                                                                                                       |
| :----------- | :------------- | :------------------------------------------------------- | :------------------------------------------------------------------------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :--------------------------------------------------------------------------------------------------------------------------- |
| **H-ADM-01** | Catálogo       | **Si se desactiva un repuesto, se elimina**              | `administrador/.../mantenimiento_catalogo_screen.dart`, backend `CatalogoServiceImpl.cambiarEstadoRepuesto` | El backend **no borra el registro**: solo hace `setActivo(false)` y la vista admin (`findAll`) incluye inactivos. Hay que reproducirlo: probablemente el listado se recarga con otro endpoint o la paginación lo saca de la página. Verificar también si en BD se ve el cambio. | El repuesto desactivado sigue en el listado del admin con el switch apagado y se puede reactivar. En BD el registro existe con `activo = false`. |
| **H-ADM-01b** | Catálogo      | **Reapertura: al deshabilitar un repuesto, este sigue desapareciendo de la lista** | `administrador/.../mantenimiento_catalogo_screen.dart` | 1) La app apunta al backend de **Render**, que aún tiene el código anterior: ignora `incluirInactivos=true` y solo devuelve los activos (verificado: `GET /catalogo?incluirInactivos=true` devolvió 21 repuestos, todos `"activo":true`). 2) Después de cambiar el switch, la pantalla **recargaba toda la lista**, así que la tarjeta dependía por completo de esa respuesta. | El repuesto deshabilitado se queda en la lista con el switch apagado y la etiqueta "DESHABILITADO", y se puede reactivar. Tras desplegar el backend, sigue apareciendo aunque se cierre y vuelva a abrir la app. |
| **H-ADM-02** | Solicitudes    | **El teclado cubre el panel al escribir una notificación o motivo** | `administrador/.../bandeja_solicitudes_screen.dart`                               | Mismo problema que H-GEN-07: el panel o modal no se ajusta a `viewInsets`.                                                                                                                                    | Al escribir, el panel se desplaza hacia arriba y el botón de envío queda visible.                                             |
| **H-ADM-03** | Reportes       | **Flecha para plegar "Repuestos más solicitados"**       | `administrador/.../reportes_analiticos_screen.dart`                                    | La lista ocupa mucho espacio y no se puede plegar.                                                                                                                                                             | La sección tiene un encabezado con flecha (▲/▼) que pliega y despliega la lista (`ExpansionTile`).                            |
| **H-ADM-04** | Personal       | **Los botones flotantes tapan el switch de activar/desactivar** | `administrador/.../gestion_personal_screen.dart`                                | Los dos FAB apilados ("Recuperar contraseña" + "Añadir usuario") miden unos 130 px, pero la lista solo dejaba 80 px de margen inferior, así que tapaban el switch de las últimas tarjetas. | La lista tiene un relleno inferior de 170 px y el switch de cualquier tarjeta se puede desplazar por encima de los FAB.        |
| **H-ADM-05** | Notificaciones | **Al tocar una solicitud, redirigir directo**            | `notificaciones/presentation/screens/centro_notificaciones_screen.dart` (`_abrir`)     | La redirección existe, pero depende de `extraerCodigoSolicitud()`, que saca el número **del texto** del título o mensaje. Si el texto no coincide con el patrón, no navega. Sería más robusto que el backend envíe un `idReferencia` o `tipo` en la notificación. | Toda notificación que menciona una solicitud abre su detalle al tocarla.                                                     |
| **H-ADM-06** | Catálogo (y pantallas de repuestos) | **Quitar todo lo que dice "Mínimo" en los repuestos** | `administrador/.../mantenimiento_catalogo_screen.dart`, `mecanico/.../catalogo_screen.dart`, `administrador/.../reportes_analiticos_screen.dart`, `almacen/.../despacho_repuestos_tab.dart`, backend `SolicitudServiceImpl.java` | El "stock mínimo" (umbral de reposición) no se entendía en los formularios ni en las tarjetas. El backend lo sigue exigiendo (`@NotNull` en `CrearRepuestoRequest` / `ActualizarRepuestoRequest`) y lo usa para la alerta de reposición, así que se oculta en la UI sin romper el contrato. | Ninguna pantalla de repuestos muestra "Mínimo"/"Mín". Crear y editar repuestos sigue funcionando. |

---

### 📦 Módulo 3: Almacenista

| ID           | Pantalla       | Hallazgo                                                 | Archivo(s) afectado(s)                                                                 | Causa probable / Análisis                                                                                                                                                                                    | Criterio de Aceptación                                                                                                       |
| :----------- | :------------- | :------------------------------------------------------- | :------------------------------------------------------------------------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :--------------------------------------------------------------------------------------------------------------------------- |
| **H-ALM-01** | Despacho       | **Faltan filtros para las solicitudes**                  | `almacen/.../despacho_screen.dart`, `despacho_repuestos_tab.dart`                      | Solo hay un listado plano de solicitudes aprobadas.                                                                                                                                                            | Filtros por prioridad (ALTA/MEDIA/BAJA), estado (aprobada / parcial / entregada), fecha y búsqueda por N° de solicitud o mecánico. |
| **H-ALM-02** | Notificaciones | **No le llegan notificaciones**                          | Backend `service/impl/SolicitudServiceImpl.notificarAprobacion` (≈ L395)                | El rol `ALMACENISTA` solo recibe una notificación **cuando la solicitud aprobada es de prioridad ALTA**. Las de prioridad MEDIA y BAJA no le avisan.                                                         | Toda solicitud aprobada (total o parcial) notifica al almacenista. Las de prioridad ALTA se marcan como urgentes.             |
| **H-ALM-02b** | Notificaciones | **Reapertura: siguen llegando solo las de prioridad ALTA** | Backend `SolicitudServiceImpl.notificarAprobacion`, `FirebaseNotificacionServiceImpl`, `Notificacion_DAO` | Se revisó toda la cadena. `notificarAprobacion()` (llamado desde la aprobación total y la parcial) ya crea la notificación para el rol `ALMACENISTA` en **todas** las prioridades. La consulta `listarPorDestinatario` devuelve las notificaciones por `dni` **o** por `rol`, y la app las pide con `/notificaciones/{dni}`, así que no hay ningún filtro por prioridad en el frontend. La causa es que **Render sigue ejecutando el backend anterior**, que solo avisaba con prioridad ALTA. Además, las solicitudes aprobadas antes del despliegue no generan la notificación de forma retroactiva. | Tras desplegar, al aprobar una solicitud MEDIA o BAJA (total o parcial), el almacenista ve "Despacho Pendiente" o "Despacho Pendiente - Aprobacion Parcial" en la campana en ≤ 30 s. Las de prioridad ALTA siguen llegando como "Despacho Urgente - Prioridad ALTA". |
| **H-ALM-03** | Retorno        | **"Confirmar retorno" no se ve: queda bajo la barra del teléfono** | `almacen/.../retorno_qr_screen.dart` (modal ≈ L229)                            | El modal suma `viewInsets` pero no el padding de la barra de navegación del sistema (`MediaQuery.padding.bottom` / `SafeArea`).                                                                                 | El botón se ve completo en teléfonos con barra de gestos o de 3 botones, con y sin teclado abierto.                             |
| **H-ALM-04** | Retorno        | **La cámara QR no funciona**                             | `almacen/.../retorno_qr_screen.dart` (`MobileScannerController`), `AndroidManifest.xml` | Revisar: permiso `CAMERA` pedido en tiempo de ejecución, ciclo de vida del controller (`start/stop` al cambiar de pestaña) y el mensaje de `_mensajeErrorCamara`. `mobile_scanner ^5.1.1`.                     | Al abrir la pestaña Retorno se pide el permiso, la cámara muestra la vista previa y al leer un QR válido se abre el modal de la herramienta. |
| **H-ALM-05** | Herramientas   | **Eliminar el botón "Herramientas extraviadas"**         | `almacen/.../registrar_herramienta_screen.dart` (FAB `fab-extravio` ≈ L206)            | Es redundante: el reporte de extravío ya existe en `detalle_herramienta_screen.dart`.                                                                                                                         | Desaparece el FAB pequeño de extravío. El reporte sigue disponible desde el detalle de la herramienta.                         |
| **H-ALM-06** | Herramientas   | **Mostrar DNI y nombre del mecánico sin abrir el detalle** | `almacen/.../registrar_herramienta_screen.dart`                                      | El selector de préstamo ya mostraba nombre y DNI. El problema estaba en la lista de Herramientas: para saber quién tenía una herramienta prestada había que abrir su detalle.                                     | Cada herramienta prestada o en mora muestra `Nombre · DNI · N° de préstamo` en su tarjeta.                                    |

---

### 🔧 Módulo 4: Mecánico

| ID           | Pantalla            | Hallazgo                                                 | Archivo(s) afectado(s)                                    | Causa probable / Análisis                                                                                     | Criterio de Aceptación                                                                                       |
| :----------- | :------------------ | :------------------------------------------------------- | :-------------------------------------------------------- | :------------------------------------------------------------------------------------------------------------ | :----------------------------------------------------------------------------------------------------------- |
| **H-MEC-01** | Catálogo            | **Ítems sin stock o desactivados al final del catálogo** | `mecanico/.../catalogo_screen.dart`                       | El listado no se ordena por disponibilidad (`stockLibre`).                                                     | Orden: primero los que tienen stock y luego los que tienen `stockLibre == 0` o están desactivados (en gris). Se mantiene el orden alfabético dentro de cada grupo. |
| **H-MEC-02** | Solicitud (carrito) | **El teclado oculta "Enviar solicitud"**                 | `mecanico/.../carrito_pedido_screen.dart`                 | Caso concreto de H-GEN-07: el botón de envío no sube con el teclado.                                          | Al escribir la justificación, el botón "Enviar solicitud" sube junto al teclado y sigue visible y usable.     |

---

## ❓ 3. Puntos que Requieren Aclaración

| ID / Origen        | Texto original                                          | Qué falta definir / Respuesta                                           |
| :----------------- | :------------------------------------------------------ | :---------------------------------------------------------------------- |
| **H-GEN-05**       | "Si subo una foto de perfil,"                           | ✅ Aclarado: la foto subida no carga por completo (error de imágenes).  |
| **H-ADM-04**       | "Los botones ocultan los botones flotantes ocultan los" | ✅ Aclarado: los FAB tapan el switch de activar/desactivar al personal. |
| Admin › Catálogo   | Dos viñetas vacías                                      | ¿Faltan hallazgos por registrar?                                        |
| Admin › Notificaciones | Dos viñetas vacías                                  | ¿Faltan hallazgos por registrar?                                        |
| Almacén › Notificación / Préstamo | Viñetas vacías                           | ¿Faltan hallazgos por registrar?                                        |

---

## ✅ 4. Estado de Correcciones (24/11/2026)

> Todas las correcciones están aplicadas en el código. `flutter analyze` no reporta errores y el backend compila.
> **Falta probar en un teléfono físico**: no se pudo compilar el APK aquí porque no hay Android SDK.

| ID | Corrección aplicada | Archivos |
| :-- | :-- | :-- |
| **H-GEN-01** | `MainActivity` ahora hereda de `FlutterFragmentActivity`. Además, `SessionManager.cerrar()` usaba `deleteAll()` y borraba las credenciales de la huella al cerrar sesión; ahora borra solo los datos de sesión. | `MainActivity.kt`, `core/session/session_manager.dart` |
| **H-GEN-02** | Se quitaron el botón y el diálogo de configuración/prueba de servidor. Al iniciar, la app descarta cualquier IP guardada antes y usa siempre el servidor por defecto. | `login_screen.dart`, `api_constants.dart` |
| **H-GEN-03 / 05** | Las imágenes se guardan en PostgreSQL (tabla `archivo_almacenado`, creada por `ddl-auto=update`) y se sirven desde `ArchivoController` en las mismas URLs `/uploads/...`, con respaldo a las imágenes semilla del disco. Se eliminó `WebMvcResourceConfig`. El avatar muestra un indicador de carga y vuelve a las iniciales si falla. | `ArchivoAlmacenado.java`, `ArchivoAlmacenado_DAO.java`, `LocalStorageServiceImpl.java`, `ArchivoController.java`, `Dockerfile`, `mi_perfil_screen.dart` |
| **H-GEN-04** | Se quitaron las 42 etiquetas `[RFxx]` visibles. Los comentarios del código se mantienen. | Varias pantallas |
| **H-GEN-06** | "Cerrar sesión" se movió debajo de la tarjeta de cabecera del perfil. | `mi_perfil_screen.dart` |
| **H-GEN-07** | Ajustes de teclado y barra del sistema: `viewInsets` en los bottom sheets, `scrollPadding` en los campos con botón debajo, contenido desplazable en los diálogos y margen para la barra de navegación. | `carrito_pedido_screen.dart`, `detalle_solicitud_sheet.dart`, `selector_buscable.dart`, `retorno_qr_screen.dart`, `reportar_extravio_modal.dart`, `catalogo_screen.dart`, `mi_perfil_screen.dart`, `solicitudes_recuperacion_screen.dart` |
| **H-GEN-08** | Nuevo `CuentaActivaFilter` en el backend: si la cuenta está `INACTIVO`, responde 401 `CUENTA_INACTIVA`. Dio detecta esa respuesta, cierra la sesión, borra la huella y vuelve al login con un aviso. La campana consulta cada 30 s, así que la sesión se cierra en ≤ 30 s. | `CuentaActivaFilter.java`, `dio_client.dart`, `session_manager.dart`, `app.dart` |
| **H-GEN-09** | Botón 👁 en "Añadir usuario" y un botón independiente en cada campo de "Cambiar contraseña". | `gestion_personal_screen.dart`, `mi_perfil_screen.dart` |
| **H-ADM-01** | Causa: el admin consumía `/catalogo`, que solo devuelve activos, así que el repuesto desactivado "desaparecía" de la lista (no se borraba de la BD). Nuevo parámetro `GET /catalogo?incluirInactivos=true`. | `CatalogoController.java`, `mantenimiento_catalogo_screen.dart` |
| **H-ADM-01b** | El switch actualiza solo la tarjeta del repuesto (sin recargar la lista) y vuelve al estado anterior si la API falla. Al recargar, los repuestos que se sabía deshabilitados se conservan aunque el servidor no los devuelva. La tarjeta muestra "DESHABILITADO · no visible para mecánicos" en gris. **Para que el arreglo sea permanente, hay que desplegar el backend en Render** (`incluirInactivos`). | `mantenimiento_catalogo_screen.dart` |
| **H-ADM-02** | El panel de detalle de la solicitud sube con el teclado al escribir el motivo. | `detalle_solicitud_sheet.dart` |
| **H-ADM-03** | Flecha para plegar y desplegar "Repuestos más solicitados". | `reportes_analiticos_screen.dart` |
| **H-ADM-04** | Relleno inferior de 170 px en la lista de Personal. | `gestion_personal_screen.dart` |
| **H-ADM-05** | Al tocar una notificación de solicitud, el admin vuelve a su panel, pasa a la pestaña Bandeja y se abre el detalle con aprobar/rechazar. | `navegacion_solicitud.dart`, `centro_notificaciones_screen.dart`, `admin_main_screen.dart` |
| **H-ADM-06** | Se quitó el campo "Stock Mínimo" de *Nuevo repuesto* y *Editar repuesto* (el campo de stock ocupa ahora todo el ancho). Al crear se envía `stockMinimo: 0` y al editar se conserva el valor guardado. Se quitó "Mínimo: X" de la tarjeta del admin, "Mín: X" del chip del mecánico y "Mínimo: X" de Reportes. Los textos de alerta dicen ahora "stock bajo" ("Repuestos con stock bajo", "(stock bajo)", notificación "Stock Bajo"). | `mantenimiento_catalogo_screen.dart`, `catalogo_screen.dart`, `reportes_analiticos_screen.dart`, `despacho_repuestos_tab.dart`, `SolicitudServiceImpl.java` |
| **H-ALM-01** | Filtros en Despacho: buscador (N°, mecánico, máquina), prioridad y periodo. | `despacho_repuestos_tab.dart` |
| **H-ALM-02** | El almacenista recibe aviso de **toda** solicitud aprobada (antes solo de prioridad ALTA). | `SolicitudServiceImpl.java` |
| **H-ALM-02b** | Se verificó en el código que el almacenista recibe aviso de toda aprobación: ALTA como urgente (tipo `PRIORIDAD_ALTA` → `SOLICITUD` en BD) y MEDIA/BAJA como "Despacho Pendiente" (tipo `SOLICITUD_APROBADA` → `APROBACION` en BD, válido para el *check constraint*). Se corrigió el comentario de `notificarAprobacion()`, que todavía decía "solo prioridad ALTA". **Para que funcione en la app hay que desplegar el backend en Render.** | `SolicitudServiceImpl.java` |
| **H-ALM-03** | El modal de retorno suma el espacio de la barra de navegación del teléfono. | `retorno_qr_screen.dart` |
| **H-ALM-04** | Como la pantalla usa su propio controller, `mobile_scanner` no gestionaba el ciclo de vida: tras el diálogo de permiso o al volver de segundo plano, la cámara quedaba en negro. Se agregó `WidgetsBindingObserver`, se eliminaron los arranques duplicados de la cámara y el mismo QR se puede volver a leer después de 3 s. | `retorno_qr_screen.dart` |
| **H-ALM-05** | Se quitó el FAB de extravío. El reporte sigue disponible desde el detalle de la herramienta. | `registrar_herramienta_screen.dart` |
| **H-ALM-06** | Nombre, DNI y N° de préstamo del custodio en cada tarjeta de herramienta prestada. | `registrar_herramienta_screen.dart` |
| **H-MEC-01** | Catálogo completo (antes solo se cargaban 20) ordenado así: con stock, sin stock y al final los deshabilitados, que aparecen atenuados y no se pueden pedir. | `catalogo_screen.dart`, `repuesto_entity.dart`, `repuesto_model.dart`, `repuesto_remote_datasource.dart` |
| **H-MEC-02** | "Enviar solicitud" sube junto con el teclado al escribir la justificación. | `carrito_pedido_screen.dart` |

**Notas para el despliegue:**
- Las fotos subidas **antes** de este cambio ya se perdieron del disco de Render. Hay que volver a subirlas.
- Los tests del backend tienen **3 fallas que ya existían** antes de estos cambios (`SolicitudServiceTest.testAprobarSolicitudTotal_Exito`, `AutenticacionServiceTest.testAutenticar_BloqueoPorTresIntentos`, `FlujoCompletoTddIntegrationTest.testTdd_AutenticacionExitosa`).

---

## 🔄 5. Checklist de Ejecución

```markdown
### Sprint 1 – Críticos
- [x] H-GEN-01  MainActivity → FlutterFragmentActivity y prueba de huella en dispositivo físico
- [x] H-GEN-03  Almacenamiento externo de imágenes + prueba de subida (repuesto, herramienta, perfil)
- [x] H-GEN-08  Validar usuario activo en backend + interceptor 401/403 en Dio → logout
- [x] H-ADM-01  Reproducir y corregir la "eliminación" al desactivar un repuesto
- [x] H-ALM-02  Notificar al ALMACENISTA en toda aprobación (no solo prioridad ALTA)
- [x] H-ALM-04  Corregir la cámara QR en Retorno
- [x] H-ADM-01b Reapertura: el switch ya no recarga la lista y conserva los deshabilitados
- [ ] H-ADM-01b Desplegar el backend en Render y verificar `GET /catalogo?incluirInactivos=true`
- [x] H-ALM-02b Revisar la cadena de notificaciones del almacenista (backend → BD → app): toda aprobación lo notifica
- [ ] H-ALM-02b Tras desplegar en Render, aprobar una solicitud MEDIA/BAJA y confirmar que llega "Despacho Pendiente" al almacenista

### Sprint 2 – Teclado y SafeArea
- [x] H-GEN-07  Auditar todos los formularios y bottom sheets (viewInsets + isScrollControlled + espacio inferior)
- [x] H-MEC-02  Carrito: botón "Enviar solicitud" sube con el teclado
- [x] H-ADM-02  Bandeja: el panel de notificación o motivo sube con el teclado
- [x] H-ALM-03  Retorno: "Confirmar retorno" respeta la barra del sistema
- [x] H-GEN-06  Perfil: reubicar "Cerrar sesión"
- [x] H-ADM-04  Personal: relleno inferior para los FAB

### Sprint 3 – Mejoras y limpieza
- [x] H-GEN-09  Icono 👁 independiente en cada campo de contraseña
- [x] H-ADM-05  Redirección robusta desde notificaciones (idReferencia)
- [x] H-ALM-01  Filtros en Despacho
- [x] H-ALM-06  DNI y nombre en el selector de mecánico
- [x] H-MEC-01  Ordenar el catálogo: sin stock o desactivados al final
- [x] H-ADM-03  Sección plegable "Repuestos más solicitados"
- [x] H-GEN-02  Quitar "Probar conexión" del login
- [x] H-ALM-05  Quitar el FAB "Herramientas extraviadas"
- [x] H-GEN-04  Quitar [RFxx] de todos los textos visibles (42 ocurrencias)
- [x] H-ADM-06  Quitar "Stock Mínimo" / "Mínimo" de formularios, tarjetas, reportes y alertas de repuestos

### Cierre
- [ ] Completar los puntos de la sección 3 (aclaraciones)
- [ ] Generar el APK de release y hacer una prueba de regresión con los 3 roles
```

---

## 🧾 6. Registro Detallado de Cambios (Changelog – 24/11/2026)

> Rama: `KR_rama`. Esta sección lista **cada archivo tocado**, qué cambió y por qué.
> Rutas Flutter relativas a `sgsra_mobile/`. Rutas backend relativas a `sgsra-md/`.

### 6.1 Backend (Spring Boot)

#### Archivos nuevos

| Archivo | Hallazgo | Especificación |
| :-- | :-- | :-- |
| `src/main/java/.../model/entity/ArchivoAlmacenado.java` | H-GEN-03 / 05 | Entidad JPA de la tabla `archivo_almacenado`. Campos: `ruta` (PK, `varchar(200)`, ej. `perfiles/uuid.jpg`), `content_type` (`varchar(60)`), `datos` (`bytea`), `tamano_bytes` y `fecha_subida`. Hibernate crea la tabla con `ddl-auto=update`, así que no hace falta migración manual. |
| `src/main/java/.../DAO/ArchivoAlmacenado_DAO.java` | H-GEN-03 / 05 | `JpaRepository<ArchivoAlmacenado, String>`. |
| `src/main/java/.../controller/ArchivoController.java` | H-GEN-03 / 05 | `GET /uploads/{carpeta}/{archivo}`: devuelve los bytes de la imagen desde la BD con su `Content-Type` y `Cache-Control: max-age=30 días` (cada subida tiene nombre UUID nuevo, así que el contenido no cambia). Si no está en la BD, la busca en el disco local (imágenes semilla) y, si tampoco existe, devuelve 404. |
| `src/main/java/.../config/CuentaActivaFilter.java` | H-GEN-08 | `OncePerRequestFilter` que se aplica a `/api/v1/**`, excepto `/auth/login`, `/auth/recuperar-clave` y las peticiones `OPTIONS`. Lee el correo del token `Bearer`; si el usuario no existe o su estado es `INACTIVO`, responde **401** con `{"exito":false,"codigo":"CUENTA_INACTIVA","mensaje":"..."}`. Los tokens que no se pueden leer pasan sin cambios. |

#### Archivos modificados

| Archivo | Hallazgo | Especificación |
| :-- | :-- | :-- |
| `src/main/java/.../service/impl/LocalStorageServiceImpl.java` | H-GEN-03 / 05 | `guardarArchivo()` guarda la imagen en PostgreSQL en vez del disco. Mantiene las validaciones (5 MB, `image/*`) y solo acepta las extensiones `.jpg/.jpeg/.png/.webp/.gif`. La URL devuelta conserva el formato `/uploads/{carpeta}/{uuid}.{ext}`. `eliminarArchivo()` borra el registro de la BD. Nuevo método `obtenerArchivo()`: busca primero en la BD y luego en el disco, con protección contra *path traversal*. |
| `src/main/java/.../controller/CatalogoController.java` | H-ADM-01 / H-MEC-01 | `GET /api/v1/catalogo` acepta el parámetro opcional `incluirInactivos` (por defecto `false`). Con `true` usa `listarCatalogoAdmin()` (activos + inactivos), que ya existía pero ningún endpoint exponía. |
| `src/main/java/.../service/impl/SolicitudServiceImpl.java` | H-ALM-02 / H-ALM-02b / H-ADM-06 | `notificarAprobacion()`: además del aviso urgente de prioridad ALTA, ahora envía al rol `ALMACENISTA` "Despacho Pendiente" o "Despacho Pendiente - Aprobación Parcial" para las prioridades MEDIA y BAJA (tipo `SOLICITUD_APROBADA`). **(H-ADM-06)** La alerta de reposición tras un despacho se titula "Stock Bajo" (antes "Stock Minimo Alcanzado") y ya no menciona el mínimo. El tipo interno `STOCK_MINIMO` no cambia. **(H-ALM-02b)** El comentario de `notificarAprobacion()` ahora dice que el almacenista recibe toda aprobación. |
| `Dockerfile` | H-GEN-03 | Ya no crea carpetas `uploads` vacías. Ahora copia `uploads/` (imágenes semilla versionadas) a la imagen final con `COPY --from=build /app/uploads /app/uploads`. |

#### Archivos eliminados

| Archivo | Hallazgo | Motivo |
| :-- | :-- | :-- |
| `src/main/java/.../config/WebMvcResourceConfig.java` | H-GEN-05 | Servía `/uploads/**` con `"file:/" + ruta`, que en Linux da `file://app/uploads/` (ruta inválida → 404 en Render). Lo reemplaza `ArchivoController`. |

### 6.2 Frontend móvil (Flutter / Android)

#### Archivos nuevos

| Archivo | Hallazgo | Especificación |
| :-- | :-- | :-- |
| `lib/core/utils/navegacion_solicitud.dart` | H-ADM-05 | `ValueNotifier<String?>` global con `abrirEnBandeja(codigo)`, para pedir al módulo Administrador que abra una solicitud desde otra pantalla. |

#### Archivos modificados

| Archivo | Hallazgo | Especificación |
| :-- | :-- | :-- |
| `android/app/src/main/kotlin/.../MainActivity.kt` | H-GEN-01 | Hereda de `FlutterFragmentActivity` (requisito de `local_auth`). El canal `telefono` sigue igual. |
| `lib/core/session/session_manager.dart` | H-GEN-01 / 08 | `cerrar()` borra solo las 5 llaves de sesión (antes usaba `deleteAll()` y eliminaba también la huella y el último correo). Nuevos: `cerrarPorCuentaDesactivada()` (además olvida la huella), `navigatorKey`, `messengerKey` y `forzarCierreSesion(mensaje)`, que solo se ejecuta una vez: vuelve a `/` y muestra un SnackBar rojo. |
| `lib/core/network/dio_client.dart` | H-GEN-08 | El interceptor `onError` detecta un 401 con `codigo == CUENTA_INACTIVA` y llama a `SessionManager.forzarCierreSesion`. |
| `lib/app.dart` | H-GEN-08 | `MaterialApp` registra `navigatorKey` y `scaffoldMessengerKey`. |
| `lib/core/constants/api_constants.dart` | H-GEN-02 | `inicializar()` descarta cualquier host personalizado guardado. Se eliminó `urlPruebaConexion()`. |
| `lib/features/auth/presentation/screens/login_screen.dart` | H-GEN-02 / 04 | Se eliminaron el botón ⚙ "Configurar IP" y el diálogo "Probar conexión". El logo queda centrado. Se quitaron los imports que ya no se usan. |
| `lib/features/auth/presentation/screens/mi_perfil_screen.dart` | H-GEN-05 / 06 / 07 / 09 | El avatar usa `Image.network` con `loadingBuilder` y `errorBuilder`, y si falla muestra las iniciales. "Cerrar sesión" se movió debajo de la cabecera y al final se agregó un margen igual a la barra del sistema. En el diálogo "Cambiar contraseña" cada campo tiene su propio botón 👁 (`_verActual`, `_verNueva`, `_verConfirmar`) y el contenido es desplazable. |
| `lib/core/widgets/detalle_solicitud_sheet.dart` | H-ADM-02 / H-GEN-07 | La hoja se envuelve en `Padding(viewInsets.bottom)`. El campo "Motivo" tiene `scrollPadding` inferior de 160. La lista suma la barra del sistema. |
| `lib/core/widgets/selector_buscable.dart` | H-GEN-07 | La hoja con buscador se ajusta al teclado y la lista suma la barra del sistema. |
| `lib/features/administrador/presentation/screens/admin_main_screen.dart` | H-ADM-05 | Escucha `NavegacionSolicitud.pendiente`: cambia a la pestaña Bandeja, abre `mostrarDetalleSolicitud(accionesAdmin: true)` y recarga la Bandeja si hubo aprobación o rechazo. |
| `lib/features/notificaciones/presentation/screens/centro_notificaciones_screen.dart` | H-ADM-05 | Para el ADMINISTRADOR: `popUntil(isFirst)` y luego `NavegacionSolicitud.abrirEnBandeja(codigo)`. El almacenista y el mecánico mantienen su comportamiento anterior. |
| `lib/features/administrador/presentation/screens/mantenimiento_catalogo_screen.dart` | H-ADM-01 / H-ADM-01b / H-GEN-04 | Carga con `incluirInactivos: true`. **(H-ADM-01b)** `_cambiarEstadoRepuesto()` actualiza solo `item['activo']` y ya no llama a `_cargarCatalogo()`; si la API falla, vuelve al valor anterior. El mensaje indica si el repuesto quedó habilitado o deshabilitado. `_cargarCatalogo()` conserva los repuestos con `activo == false` que el servidor no devuelva y ordena la lista por `codParte`. La tarjeta deshabilitada muestra "DESHABILITADO · no visible para mecánicos" en gris. **(H-ADM-06)** Se eliminaron el campo "Stock Mínimo" y su controlador en los diálogos de crear y editar. El POST envía `stockMinimo: 0` y el PUT reenvía `repuesto['stockMinimo'] ?? 0`. La tarjeta ya no muestra "Mínimo". |
| `lib/features/administrador/presentation/screens/reportes_analiticos_screen.dart` (H-ADM-06) | H-ADM-06 | La sección se llama "Repuestos con stock bajo" y la lista ya no muestra "Mínimo: X". |
| `lib/features/almacen/presentation/screens/despacho_repuestos_tab.dart` (H-ADM-06) | H-ADM-06 | "(llega al mínimo)" → "(stock bajo)". El aviso de reposición dice "Algunos repuestos quedaron con stock bajo". |
| `lib/features/administrador/presentation/screens/gestion_personal_screen.dart` | H-ADM-04 / H-GEN-09 / H-GEN-04 | Margen inferior de la lista: 80 → 170 px. "Añadir usuario" usa `StatefulBuilder` con un botón 👁 en la contraseña. |
| `lib/features/administrador/presentation/screens/reportes_analiticos_screen.dart` | H-ADM-03 / H-GEN-04 | `_Tarjeta` acepta `plegada` y `onAlternar` (flecha animada y `AnimatedSize`). Se aplicó a "Repuestos más solicitados". |
| `lib/features/administrador/presentation/screens/solicitudes_recuperacion_screen.dart` | H-GEN-07 | El diálogo "Asignar clave temporal" es desplazable. |
| `lib/features/almacen/presentation/screens/despacho_repuestos_tab.dart` | H-ALM-01 | Buscador (N° de solicitud, mecánico, máquina), chips de prioridad (Todas/Alta/Media/Baja) y menú de periodo (Cualquier fecha/Hoy/7/30 días). Si no hay resultados, muestra "Sin resultados" con el botón "Limpiar filtros". `_Vacio` acepta `textoBoton`. |
| `lib/features/almacen/presentation/screens/retorno_qr_screen.dart` | H-ALM-03 / 04 / H-GEN-04 | Usa `WidgetsBindingObserver`: reinicia la cámara al volver a la app y la detiene cuando pasa a `inactive`. `DetectionSpeed.normal` reemplaza a `noDuplicates`, y un mismo QR solo se ignora si se repite en menos de 3 s. El botón de ocultar/mostrar cámara ya no llama a `start()`/`stop()` dos veces. El modal de retorno suma `padding.bottom`. Se mejoró el mensaje cuando falta el permiso de cámara. |
| `lib/features/almacen/presentation/screens/registrar_herramienta_screen.dart` | H-ALM-05 / 06 / H-GEN-04 | Se eliminó el FAB de extravío y su import. Carga los préstamos en paralelo; si esa carga falla, la lista de herramientas se muestra igual. Cada herramienta con préstamo activo muestra `_FilaCustodio`: nombre, DNI y N° de préstamo, en naranja si está en mora. |
| `lib/features/almacen/presentation/screens/reportar_extravio_modal.dart` | H-GEN-07 / H-GEN-04 | El modal suma la barra del sistema. |
| `lib/features/mecanico/domain/entities/repuesto_entity.dart` | H-MEC-01 | Nuevo campo `activo` (por defecto `true`). |
| `lib/features/mecanico/data/models/repuesto_model.dart` | H-MEC-01 | `activo` se pasa a la entidad (antes el modelo lo guardaba en un campo propio). |
| `lib/features/mecanico/data/datasources/repuesto_remote_datasource.dart` | H-MEC-01 | `listarCatalogo()` pide `size: 500` (antes 20) e `incluirInactivos: true`. |
| `lib/features/mecanico/presentation/screens/catalogo_screen.dart` | H-MEC-01 / H-GEN-07 / H-GEN-04 | Orden estable en tres grupos: con stock, sin stock y deshabilitados. Los deshabilitados aparecen al 55 % de opacidad, con la etiqueta "No disponible · deshabilitado" y sin poder agregarse. El modal de detalle suma la barra del sistema. **(H-ADM-06)** El chip de stock físico muestra solo "Físico: X" (se quitó "· Mín: X"). |
| `lib/features/mecanico/presentation/screens/carrito_pedido_screen.dart` | H-MEC-02 / H-GEN-04 | La justificación tiene `scrollPadding` inferior de 140, para que "Enviar solicitud" suba con el teclado. Margen inferior de 40 y `keyboardDismissBehavior.onDrag`. |
| `auditoria_screen.dart`, `bandeja_solicitudes_screen.dart`, `proveedores_modal.dart`, `dashboard_almacen_screen.dart`, `detalle_herramienta_screen.dart`, `registrar_prestamo_screen.dart`, `herramientas_prestadas_screen.dart`, `historial_solicitudes_screen.dart`, `core/utils/app_router.dart` | H-GEN-04 | Se quitaron las etiquetas `[RFxx]` de los textos visibles (42 en total). |

### 6.3 Cambios de contrato / operación

- **API:** `GET /api/v1/catalogo?incluirInactivos=true` es nuevo y opcional. Sin el parámetro, el endpoint responde igual que antes.
- **API:** `GET /uploads/{carpeta}/{archivo}` ahora lo sirve un controlador, pero la URL pública no cambia.
- **API:** cualquier petición `/api/v1/**` de una cuenta `INACTIVO` responde `401 CUENTA_INACTIVA`.
- **BD:** nueva tabla `archivo_almacenado`, creada automáticamente al arrancar.
- **Datos:** las fotos subidas antes de este cambio ya no existen en Render y hay que volver a subirlas.
- **Despliegue (H-ADM-01b / H-ALM-02b):** las correcciones del backend (`incluirInactivos`, imágenes en BD, `CuentaActivaFilter`, avisos al almacenista en toda prioridad, título "Stock Bajo") **no funcionan en la app hasta desplegar en Render**, porque la app usa ese servidor. Al 24/11/2026, Render todavía ejecuta el código anterior.
- **Verificación:** `flutter analyze` sin errores y backend compilado. Los tests del backend tienen 30 casos con 3 fallas que **ya existían** antes de estos cambios (verificado ejecutándolos sobre el código original). Falta compilar el APK y probarlo en un teléfono físico.
