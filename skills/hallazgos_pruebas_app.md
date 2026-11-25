# 🐞 Matriz de Hallazgos de Pruebas – App Móvil SGSRA

> **Documento de Control de Hallazgos (QA funcional en dispositivo físico)**
> **Sistema de Gestión de Solicitud de Repuestos y Almacén (SGSRA - Master Drilling)**
> **Alcance:** Frontend Móvil (Flutter / Android APK) y Backend (Spring Boot en Render)
> **Rama:** `KR_rama` · **Ronda 1:** 24/11/2026 · **Ronda 2:** 24/11/2026 (reaperturas) · **Ronda 3:** 25/11/2026

**Convención de IDs:** `H-GEN-xx` (todos los roles) · `H-ADM-xx` (Administrador) · `H-ALM-xx` (Almacenista) · `H-MEC-xx` (Mecánico).
- El sufijo **`b`** (p. ej. `H-ALM-04b`) indica una **reapertura**: el hallazgo volvió a aparecer después de su primera corrección.
- Se usa el prefijo `H-` para no confundir estos IDs con las etiquetas `[ADM-xx]` / `[ALM-xx]` que ya existen en comentarios del código.

**Tipos:** 🐞 Bug · 🎨 UI/UX · ✨ Mejora · 🧹 Limpieza · 🔁 Regla de negocio

**Estado:**
- ✅ Corregido en el código.
- 🚀 Corregido, pero requiere desplegar el backend en Render.
- 📱 Corregido, pero falta verificarlo en un teléfono físico.

---

## 📊 1. Resumen Ejecutivo de Hallazgos

| Prioridad      | ID          | Rol      | Pantalla            | Hallazgo (resumen)                                                    | Tipo | Capa                 | Ronda | Estado |
| :------------- | :---------- | :------- | :------------------ | :-------------------------------------------------------------------- | :--: | :------------------- | :---: | :----: |
| 🔴 **Crítica** | H-GEN-01    | Todos    | Login               | La autenticación por huella no funciona                               |  🐞  | Android / Flutter    |   1   |   📱   |
| 🔴 **Crítica** | H-GEN-03    | Todos    | Global              | No se pueden subir imágenes                                           |  🐞  | Flutter / Backend    |   1   |   🚀   |
| 🔴 **Crítica** | H-GEN-05    | Todos    | Perfil              | La foto de perfil subida no carga por completo                        |  🐞  | Backend / Flutter    |   1   |   🚀   |
| 🔴 **Crítica** | H-GEN-08    | Todos    | Global              | Una cuenta desactivada no cierra su sesión automáticamente            |  🐞  | Backend / Flutter    |   1   |   🚀   |
| 🔴 **Crítica** | H-ADM-01    | Admin    | Catálogo            | Desactivar un repuesto lo "elimina"                                   |  🐞  | Flutter / Backend    |   1   |   🚀   |
| 🔴 **Crítica** | H-ADM-01b   | Admin    | Catálogo            | Reapertura: el repuesto deshabilitado sigue desapareciendo            |  🐞  | Flutter / Despliegue |   2   |   🚀   |
| 🔴 **Crítica** | H-ALM-02    | Almacén  | Notificaciones      | Al almacenista no le llegan notificaciones                            |  🐞  | Backend              |   1   |   🚀   |
| 🔴 **Crítica** | H-ALM-02b   | Almacén  | Notificaciones      | Reapertura: solo le llegan las de prioridad ALTA                      |  🐞  | Backend / Despliegue |   2   |   🚀   |
| 🔴 **Crítica** | H-ALM-04    | Almacén  | Retorno             | La cámara QR no funciona                                              |  🐞  | Flutter / Android    |   1   |   📱   |
| 🔴 **Crítica** | H-ALM-04b   | Almacén  | Retorno             | Reapertura: el escáner QR sigue sin leer (Google Lens sí lee el QR)   |  🐞  | Flutter / Android    |   3   |   📱   |
| 🔴 **Crítica** | H-ALM-08    | Almacén  | Despacho › Préstamo | No permite prestar a mecánicos con préstamos en mora                  |  🔁  | Backend              |   3   |   🚀   |
| 🟠 **Alta**    | H-GEN-07    | Todos    | Formularios         | El teclado tapa botones y campos (inputs que no "suben")              |  🎨  | Flutter              |   1   |   📱   |
| 🟠 **Alta**    | H-GEN-10    | Todos    | Global              | A veces el teclado se cierra y queda su espacio en blanco             |  🐞  | Flutter / Android    |   3   |   📱   |
| 🟠 **Alta**    | H-ADM-02    | Admin    | Solicitudes         | El teclado cubre el panel al escribir una notificación                |  🎨  | Flutter              |   1   |   📱   |
| 🟠 **Alta**    | H-ADM-05    | Admin    | Notificaciones      | Tocar una notificación de solicitud no redirige                       |  🐞  | Flutter              |   1   |   ✅   |
| 🟠 **Alta**    | H-ALM-03    | Almacén  | Retorno             | Botón "Confirmar retorno" queda bajo la barra del teléfono            |  🎨  | Flutter              |   1   |   📱   |
| 🟠 **Alta**    | H-ALM-07    | Almacén  | Dashboard           | Tocar una solicitud aprobada no abre su modal                         |  🐞  | Flutter              |   3   |   ✅   |
| 🟠 **Alta**    | H-MEC-02    | Mecánico | Solicitud (carrito) | El teclado oculta "Enviar solicitud" al escribir la justificación     |  🎨  | Flutter              |   1   |   📱   |
| 🟡 **Media**   | H-GEN-06    | Todos    | Perfil              | Botón "Cerrar sesión" demasiado abajo                                 |  🎨  | Flutter              |   1   |   ✅   |
| 🟡 **Media**   | H-GEN-09    | Todos    | Contraseñas         | Falta el botón "ver contraseña" en algunos campos                     |  🎨  | Flutter              |   1   |   ✅   |
| 🟡 **Media**   | H-ADM-04    | Admin    | Personal            | Los botones flotantes tapan el switch de activar/desactivar           |  🎨  | Flutter              |   1   |   ✅   |
| 🟡 **Media**   | H-ALM-01    | Almacén  | Despacho            | Faltan filtros para las solicitudes                                   |  ✨  | Flutter              |   1   |   ✅   |
| 🟡 **Media**   | H-ALM-06    | Almacén  | Herramientas        | Mostrar DNI y nombre del mecánico sin abrir el detalle                |  ✨  | Flutter              |   1   |   ✅   |
| 🟡 **Media**   | H-ALM-09    | Almacén  | Herramientas        | Al crear una herramienta no se puede subir la imagen hasta después    |  ✨  | Flutter              |   3   |   ✅   |
| 🟡 **Media**   | H-ALM-10    | Almacén  | Herramientas        | No hay forma de generar/imprimir el QR de cada herramienta            |  ✨  | Flutter / Herramienta |   3   |   ✅   |
| 🟡 **Media**   | H-MEC-01    | Mecánico | Catálogo            | Ítems sin stock o desactivados al final del catálogo                  |  ✨  | Flutter              |   1   |   🚀   |
| 🟢 **Baja**    | H-GEN-02    | Todos    | Login               | Eliminar botón "Probar conexión"                                      |  🧹  | Flutter              |   1   |   ✅   |
| 🟢 **Baja**    | H-GEN-04    | Todos    | Todas               | Eliminar etiquetas `[RFxx]` visibles en la interfaz                   |  🧹  | Flutter              |   1   |   ✅   |
| 🟢 **Baja**    | H-ADM-03    | Admin    | Reportes            | Flecha para plegar "Repuestos más solicitados"                        |  ✨  | Flutter              |   1   |   ✅   |
| 🟢 **Baja**    | H-ADM-06    | Todos    | Repuestos           | Quitar "Stock Mínimo" / "Mínimo" de los repuestos (no se entiende)    |  🧹  | Flutter / Backend    |   2   |   ✅   |
| 🟢 **Baja**    | H-ALM-05    | Almacén  | Herramientas        | Eliminar botón "Herramientas extraviadas"                             |  🧹  | Flutter              |   1   |   ✅   |

**Totales:** 31 hallazgos (22 de la ronda 1, 3 de la ronda 2 y 6 de la ronda 3), con 3 reaperturas (`b`). Todos están corregidos en el código.

---

## 🗂️ 2. Desglose Detallado por Rol y Pantalla

> Las rutas son relativas a `sgsra_mobile/lib/` (Flutter) y `sgsra-md/src/main/java/com/masterdrilling/sgsramd/` (backend).

### 🌐 Módulo 1: Hallazgos Generales (afectan a todos los roles)

| ID           | Hallazgo | Archivo(s) afectado(s) | Causa / Análisis | Criterio de Aceptación |
| :----------- | :------- | :--------------------- | :--------------- | :--------------------- |
| **H-GEN-01** | **La huella no funciona** | `android/.../MainActivity.kt`, `core/session/session_manager.dart` | `MainActivity` heredaba de `FlutterActivity`, pero `local_auth` exige `FlutterFragmentActivity`. Además, al cerrar sesión se ejecutaba `deleteAll()`, que borraba también las credenciales de la huella. | En un dispositivo con huella registrada, aparece el diálogo biométrico y al validar se inicia sesión. Si no hay huella, se muestra un mensaje claro. |
| **H-GEN-02** | **Eliminar botón "Probar conexión"** | `auth/presentation/screens/login_screen.dart`, `core/constants/api_constants.dart` | Era una herramienta de depuración para la IP local. Con el backend en Render ya no hace falta. | La pantalla de login no muestra el botón ni el bloque de prueba de IP. |
| **H-GEN-03** | **No se pueden subir imágenes** | `core/widgets/imagen_producto.dart`, backend `LocalStorageServiceImpl` | El disco de Render es **temporal**: los archivos de `uploads/` se pierden en cada redeploy o reinicio. | La foto se sube (repuesto, herramienta, perfil), se ve al recargar y sigue ahí después de reiniciar el servidor. |
| **H-GEN-04** | **Eliminar las etiquetas `[RFxx]`** | 42 textos visibles en `features/**` | Los códigos de requerimiento quedaron en títulos, tooltips y textos de la UI. En los comentarios del código se mantienen. | Ningún texto visible contiene `[RF..]`. |
| **H-GEN-05** | **La foto de perfil no carga por completo** | `auth/.../mi_perfil_screen.dart`, backend `WebMvcResourceConfig.java` | Misma causa que H-GEN-03. Además, `"file:/" + ruta` daba una ruta inválida en Linux (404), y el avatar no tenía imagen de respaldo. | La foto subida se ve en Perfil y en Personal. Si falla, se muestran las iniciales. |
| **H-GEN-06** | **"Cerrar sesión" muy abajo en Perfil** | `auth/.../mi_perfil_screen.dart` | El botón quedaba al final del scroll o debajo de la barra del sistema. | El botón se ve sin hacer scroll y nunca lo tapa la barra del sistema. |
| **H-GEN-07** | **Inputs que no suben con el teclado** | `carrito_pedido_screen.dart`, `detalle_solicitud_sheet.dart`, `selector_buscable.dart` y otros modales | Solo 2 pantallas sumaban `viewInsets.bottom`. Los demás formularios y bottom sheets no se ajustaban al teclado. | Al abrir el teclado, el campo activo y el botón de acción quedan visibles. |
| **H-GEN-08** | **Desactivar una cuenta no cierra su sesión** | Backend `SecurityFilterConfig.java`, `core/network/dio_client.dart` | El backend tenía `permitAll()` y no revisaba el estado de la cuenta en cada petición. Dio no reaccionaba ante un 401. | La siguiente petición de una cuenta desactivada devuelve 401 y la app vuelve al login con el aviso "Cuenta desactivada". |
| **H-GEN-09** | **Botón "ver contraseña" en todos los campos** | `gestion_personal_screen.dart`, `mi_perfil_screen.dart` | En *Añadir usuario* no había icono. En *Mi perfil* un único `_ver` controlaba los 3 campos. | Cada campo de contraseña tiene su propio botón 👁. |
| **H-GEN-10** | **A veces el teclado "se bugea" y queda su espacio en blanco** *(ronda 3; difícil de reproducir)* | `app.dart`, nuevo `core/utils/teclado_guard.dart` | Se descartó la causa más común (Scaffolds anidados que restan el teclado dos veces): Flutter quita `viewInsets` del body cuando el Scaffold ya se ajusta. La causa es intermitente. Si el teclado está abierto cuando **se cierra un diálogo o bottom sheet, se cambia de pantalla o la app pasa a segundo plano**, Android a veces no avisa del cierre. Entonces Flutter conserva el `viewInsets.bottom` anterior y queda el hueco blanco hasta volver a tocar un campo. | Al cerrar diálogos, cambiar de pantalla o salir y volver a la app, el teclado se cierra primero y no queda espacio en blanco. Tocar una zona vacía también cierra el teclado. |

### 🛡️ Módulo 2: Administrador

| ID            | Pantalla | Hallazgo | Archivo(s) afectado(s) | Causa / Análisis | Criterio de Aceptación |
| :------------ | :------- | :------- | :--------------------- | :--------------- | :--------------------- |
| **H-ADM-01**  | Catálogo | **Si se desactiva un repuesto, se elimina** | `mantenimiento_catalogo_screen.dart`, backend `CatalogoController` | El backend no borra el registro (`setActivo(false)`), pero el admin consumía `/catalogo`, que solo devuelve los activos. | El repuesto desactivado sigue en la lista con el switch apagado y se puede reactivar. |
| **H-ADM-01b** | Catálogo | **Reapertura: el repuesto deshabilitado sigue desapareciendo** | `mantenimiento_catalogo_screen.dart` | 1) Render tiene el backend anterior e ignora `incluirInactivos=true` (verificado: devolvió 21 repuestos, todos activos). 2) Al cambiar el switch, la pantalla recargaba toda la lista. | La tarjeta queda con el switch apagado y la etiqueta "DESHABILITADO". Tras desplegar, se mantiene aunque se cierre la app. |
| **H-ADM-02**  | Solicitudes | **El teclado cubre el panel al escribir un motivo** | `core/widgets/detalle_solicitud_sheet.dart` | Es un caso de H-GEN-07: el panel no se ajustaba a `viewInsets`. | Al escribir, el panel sube y el botón de envío queda visible. |
| **H-ADM-03**  | Reportes | **Flecha para plegar "Repuestos más solicitados"** | `reportes_analiticos_screen.dart` | La lista ocupaba mucho espacio y no se podía plegar. | La sección tiene una flecha ▲/▼ que la pliega y la despliega. |
| **H-ADM-04**  | Personal | **Los FAB tapan el switch de activar/desactivar** | `gestion_personal_screen.dart` | Los dos FAB miden unos 130 px y la lista solo dejaba 80 px de margen. | Relleno inferior de 170 px: cualquier switch se puede desplazar por encima de los FAB. |
| **H-ADM-05**  | Notificaciones | **Al tocar una solicitud, abrirla directamente** | `centro_notificaciones_screen.dart`, `admin_main_screen.dart` | La redirección no llevaba al admin a la Bandeja con la solicitud abierta. | Toda notificación de solicitud abre su detalle con aprobar/rechazar. |
| **H-ADM-06**  | Catálogo y pantallas de repuestos | **Quitar todo lo que dice "Mínimo"** | `mantenimiento_catalogo_screen.dart`, `catalogo_screen.dart`, `reportes_analiticos_screen.dart`, `despacho_repuestos_tab.dart`, backend `SolicitudServiceImpl` | El "stock mínimo" no se entendía. El backend lo exige (`@NotNull`) y lo usa para la alerta de reposición, así que se oculta en la UI sin romper el contrato. | Ninguna pantalla de repuestos muestra "Mínimo" ni "Mín", y crear y editar repuestos sigue funcionando. |

### 📦 Módulo 3: Almacenista

| ID            | Pantalla | Hallazgo | Archivo(s) afectado(s) | Causa / Análisis | Criterio de Aceptación |
| :------------ | :------- | :------- | :--------------------- | :--------------- | :--------------------- |
| **H-ALM-01**  | Despacho | **Faltan filtros para las solicitudes** | `despacho_repuestos_tab.dart` | Solo había un listado plano. | Buscador, filtro de prioridad y filtro de periodo. |
| **H-ALM-02**  | Notificaciones | **No le llegan notificaciones** | Backend `SolicitudServiceImpl.notificarAprobacion` | El almacenista solo recibía aviso de las aprobaciones de prioridad ALTA. | Toda aprobación, total o parcial, notifica al almacenista. |
| **H-ALM-02b** | Notificaciones | **Reapertura: solo llegan las de prioridad ALTA** | Backend `SolicitudServiceImpl`, `FirebaseNotificacionServiceImpl`, `Notificacion_DAO` | Se revisó toda la cadena (backend → BD → app) y el código es correcto. Render sigue ejecutando el backend anterior, y las aprobaciones previas al despliegue no generan aviso de forma retroactiva. | Tras desplegar, una aprobación MEDIA/BAJA muestra "Despacho Pendiente" en la campana en ≤ 30 s. |
| **H-ALM-03**  | Retorno | **"Confirmar retorno" queda bajo la barra del teléfono** | `retorno_qr_screen.dart` | El modal no sumaba `MediaQuery.padding.bottom`. | El botón se ve completo con barra de gestos o de 3 botones, con y sin teclado. |
| **H-ALM-04**  | Retorno | **La cámara QR no funciona** | `retorno_qr_screen.dart` | Con un controller propio, `mobile_scanner` no gestionaba el ciclo de vida: tras pedir el permiso o volver de segundo plano, la cámara quedaba en negro. | La vista previa aparece después de conceder el permiso y al volver a la app. |
| **H-ALM-04b** | Retorno | **Reapertura: el escáner sigue sin leer. Solo funciona con Google Lens, que lee cualquier enlace** | `pubspec.yaml`, `retorno_qr_screen.dart` | Hay **dos causas**: 1) `mobile_scanner 5.2.3` es anterior al motor Impeller de Android (Flutter 3.50). En Android, el análisis de cuadros se podía **detener para siempre mientras la vista previa seguía activa** (corregido en 7.4.1: *"barcode scanning permanently stalling when a camera frame was never released"*). Además, en release, R8 podía eliminar clases internas de ML Kit (regla ProGuard añadida en 7.4.1). 2) El lector solo aceptaba un QR cuyo contenido fuera **exactamente** el código (`HER-TOR-004`). Si el QR trae un **enlace** o texto (p. ej. generado en una web: `https://…/HER-TOR-004` o `?codigo=HER-TOR-004`), Google Lens lo lee, pero la app no lo reconocía. | El escáner lee el QR de la herramienta y abre el modal de retorno, tanto si el QR contiene solo el código como si contiene un enlace o texto que lo incluye. |
| **H-ALM-05**  | Herramientas | **Eliminar el botón "Herramientas extraviadas"** | `registrar_herramienta_screen.dart` | Es redundante: el reporte ya existe en el detalle de la herramienta. | Desaparece el FAB y el reporte sigue disponible desde el detalle. |
| **H-ALM-06**  | Herramientas | **DNI y nombre del mecánico sin abrir el detalle** | `registrar_herramienta_screen.dart` | Para saber quién tenía la herramienta había que abrir su detalle. | Cada herramienta prestada o en mora muestra `Nombre · DNI · N° de préstamo`. |
| **H-ALM-07**  | Dashboard | **Tocar una solicitud aprobada no abre su modal** *(ronda 3)* | `dashboard_almacen_screen.dart` | Las tarjetas de "Repuestos Aprobados para Retiro Físico" eran `ListTile` **sin `onTap`**. Las de préstamos sí lo tenían. | Al tocar una solicitud aprobada se abre el mismo modal de despacho que en la pestaña Despacho. Si se despacha, el dashboard se actualiza. |
| **H-ALM-08**  | Despacho › Préstamo | **No permite prestar a mecánicos con mal historial (préstamos en mora)** *(ronda 3)* | Backend `PrestamoServiceImpl.registrarPrestamo`, `CupoPrestamoValidator` | El backend ejecutaba `validarAusenciaDeMoras()` y respondía *"Bloqueo preventivo: el mecánico registra préstamos con tiempo vencido sin regularizar"*. **Regla de negocio:** sancionar a un mecánico corresponde a Administración, no al almacén. **Observación del QA:** si se eliminan los préstamos en mora, sí permite prestar, lo que confirma que el bloqueo venía solo de esa validación. | Se puede prestar a un mecánico aunque tenga préstamos en mora. Se mantiene el límite de 5 herramientas simultáneas (RF36). |
| **H-ALM-09**  | Herramientas | **Al agregar una herramienta no se puede subir la imagen hasta después de crearla** *(ronda 3)* | `registrar_herramienta_screen.dart`, `core/widgets/imagen_producto.dart` | El endpoint de imagen (`POST /inventario/herramientas/{cod}/imagen`) necesita que la herramienta ya exista. Por eso el formulario no tenía campo de foto y la ofrecía en un segundo diálogo después de guardar. | El formulario "Nueva herramienta" tiene un campo de foto opcional con vista previa. Al guardar se crea la herramienta y la foto se sube automáticamente. |
| **H-ALM-10**  | Herramientas | **Generar los QR de cada herramienta para que el escáner sea 100 % funcional** *(ronda 3, derivado de H-ALM-04b)* | Nuevo `almacen/presentation/widgets/qr_herramienta.dart`, `detalle_herramienta_screen.dart`, `registrar_herramienta_screen.dart`, nuevo `herramientas_qr/imprimir_qr_herramientas.html` | La app escaneaba QR, pero no existía ninguna forma de **generarlos**. Las etiquetas se hacían por fuera (webs de QR que a veces guardan un enlace en lugar del código). | Cada herramienta tiene un QR cuyo contenido es **solo su código** (`HER-PIST-003`). Se puede ver en la app y se pueden imprimir todas las etiquetas de una vez. |

### 🔧 Módulo 4: Mecánico

| ID           | Pantalla | Hallazgo | Archivo(s) afectado(s) | Causa / Análisis | Criterio de Aceptación |
| :----------- | :------- | :------- | :--------------------- | :--------------- | :--------------------- |
| **H-MEC-01** | Catálogo | **Ítems sin stock o desactivados al final** | `catalogo_screen.dart`, `repuesto_*` | El listado no se ordenaba por disponibilidad y solo cargaba 20 ítems. | Orden: con stock, sin stock y deshabilitados (en gris), con orden alfabético dentro de cada grupo. |
| **H-MEC-02** | Solicitud (carrito) | **El teclado oculta "Enviar solicitud"** | `carrito_pedido_screen.dart` | Es un caso de H-GEN-07. | Al escribir la justificación, "Enviar solicitud" sube con el teclado. |

---

## ❓ 3. Puntos que Requieren Aclaración

| ID / Origen | Texto original | Qué falta definir / Respuesta |
| :---------- | :------------- | :---------------------------- |
| **H-GEN-05** | "Si subo una foto de perfil," | ✅ Aclarado: la foto subida no carga por completo. |
| **H-ADM-04** | "Los botones ocultan los botones flotantes ocultan los" | ✅ Aclarado: los FAB tapan el switch de activar/desactivar. |
| **H-GEN-10** | "No sé en qué momento ni en qué parte…" | Se aplicó una corrección preventiva global. Si vuelve a ocurrir, anotar **la pantalla y la acción previa** (cerrar un diálogo, cambiar de pestaña, volver desde otra app) para acotarlo. |
| **H-ALM-04b** | "…a menos que use Google Lens… para que lea cualquier enlace" | Confirmar **qué contiene el QR impreso**: solo el código o un enlace. La app ahora acepta ambos. Si es un enlace de un acortador (p. ej. `qrco.de/xyz`) que **no** incluye el código, hay que reimprimir el QR con el código de la herramienta. |
| Admin › Catálogo | Dos viñetas vacías | ¿Faltan hallazgos por registrar? |
| Admin › Notificaciones | Dos viñetas vacías | ¿Faltan hallazgos por registrar? |
| Almacén › Notificación / Préstamo | Viñetas vacías | ¿Faltan hallazgos por registrar? |

---

## ✅ 4. Estado de Correcciones

> Todas las correcciones están aplicadas en el código. `flutter analyze` no reporta errores y el backend compila.
> **Falta probarlas en un teléfono físico:** el APK no se pudo compilar aquí porque no hay Android SDK.

| ID | Corrección aplicada | Archivos |
| :-- | :-- | :-- |
| **H-GEN-01** | `MainActivity` hereda de `FlutterFragmentActivity`. `SessionManager.cerrar()` borra solo los datos de sesión, sin tocar la huella. | `MainActivity.kt`, `session_manager.dart` |
| **H-GEN-02** | Se quitaron el botón y el diálogo de configuración/prueba de servidor. Al iniciar, la app descarta cualquier IP guardada. | `login_screen.dart`, `api_constants.dart` |
| **H-GEN-03 / 05** | Las imágenes se guardan en PostgreSQL (`archivo_almacenado`) y se sirven desde `ArchivoController` en las mismas URLs `/uploads/...`. Se eliminó `WebMvcResourceConfig`. El avatar muestra un indicador de carga y vuelve a las iniciales si falla. | `ArchivoAlmacenado.java`, `ArchivoAlmacenado_DAO.java`, `LocalStorageServiceImpl.java`, `ArchivoController.java`, `Dockerfile`, `mi_perfil_screen.dart` |
| **H-GEN-04** | Se quitaron las 42 etiquetas `[RFxx]` visibles. | Varias pantallas |
| **H-GEN-06** | "Cerrar sesión" está debajo de la cabecera del perfil. | `mi_perfil_screen.dart` |
| **H-GEN-07** | `viewInsets` en los bottom sheets, `scrollPadding`, diálogos desplazables y margen para la barra del sistema. | `carrito_pedido_screen.dart`, `detalle_solicitud_sheet.dart`, `selector_buscable.dart`, `retorno_qr_screen.dart`, `reportar_extravio_modal.dart`, `catalogo_screen.dart`, `mi_perfil_screen.dart`, `solicitudes_recuperacion_screen.dart` |
| **H-GEN-08** | `CuentaActivaFilter` responde 401 `CUENTA_INACTIVA`. Dio cierra la sesión y vuelve al login (≤ 30 s). | `CuentaActivaFilter.java`, `dio_client.dart`, `session_manager.dart`, `app.dart` |
| **H-GEN-09** | Botón 👁 independiente en cada campo de contraseña. | `gestion_personal_screen.dart`, `mi_perfil_screen.dart` |
| **H-GEN-10** | Protección global del teclado: `TecladoNavigatorObserver` cierra el teclado en cada push/pop/replace de ruta (pantallas, diálogos, bottom sheets y menús). `TecladoGuard` lo cierra cuando la app pasa a segundo plano y al tocar una zona vacía. Así Android notifica el cierre a tiempo y no queda el `viewInsets` "pegado". No cambia nada visual. | `core/utils/teclado_guard.dart` (nuevo), `app.dart` |
| **H-ADM-01** | Nuevo parámetro `GET /catalogo?incluirInactivos=true`, usado por el admin. | `CatalogoController.java`, `mantenimiento_catalogo_screen.dart` |
| **H-ADM-01b** | El switch actualiza solo su tarjeta y vuelve al estado anterior si la API falla. Al recargar se conservan los deshabilitados conocidos. Etiqueta "DESHABILITADO · no visible para mecánicos". | `mantenimiento_catalogo_screen.dart` |
| **H-ADM-02** | El panel de la solicitud sube con el teclado. | `detalle_solicitud_sheet.dart` |
| **H-ADM-03** | Flecha para plegar "Repuestos más solicitados". | `reportes_analiticos_screen.dart` |
| **H-ADM-04** | Relleno inferior de 170 px en Personal. | `gestion_personal_screen.dart` |
| **H-ADM-05** | La notificación lleva a la Bandeja y abre el detalle con aprobar/rechazar. | `navegacion_solicitud.dart`, `centro_notificaciones_screen.dart`, `admin_main_screen.dart` |
| **H-ADM-06** | Se quitó el campo "Stock Mínimo" al crear y al editar: se envía `0` al crear y se conserva el valor al editar. Ya no se muestran "Mínimo" ni "Mín". Las alertas dicen "stock bajo". | `mantenimiento_catalogo_screen.dart`, `catalogo_screen.dart`, `reportes_analiticos_screen.dart`, `despacho_repuestos_tab.dart`, `SolicitudServiceImpl.java` |
| **H-ALM-01** | Filtros en Despacho: buscador, prioridad y periodo. | `despacho_repuestos_tab.dart` |
| **H-ALM-02 / 02b** | El almacenista recibe aviso de **toda** aprobación: ALTA como urgente y MEDIA/BAJA como "Despacho Pendiente". | `SolicitudServiceImpl.java` |
| **H-ALM-03** | El modal de retorno suma la barra del sistema. | `retorno_qr_screen.dart` |
| **H-ALM-04** | `WidgetsBindingObserver` para el ciclo de vida de la cámara, sin arranques duplicados. El mismo QR se puede volver a leer después de 3 s. | `retorno_qr_screen.dart` |
| **H-ALM-04b** | 1) **`mobile_scanner` pasa de `^5.1.1` (5.2.3) a `^7.1.0` (resuelve 7.5.0)**. Incluye compatibilidad con Impeller (`SurfaceProducer`), la corrección del análisis que se detenía con la vista previa activa y la regla ProGuard de ML Kit para release. El único cambio de API fue `errorBuilder: (ctx, err)`, sin el tercer argumento. 2) Nuevo `_extraerCodigo()`, que reconoce el código aunque el QR traiga un enlace o texto. Busca primero un código de herramienta prestada dentro del contenido, luego los parámetros `codigo/cod/code/codHerramienta/id`, después el último segmento de la URL y, por último, el patrón `LETRAS-XXX[-XXX]`. | `pubspec.yaml`, `pubspec.lock`, `retorno_qr_screen.dart` |
| **H-ALM-05** | Se quitó el FAB de extravío. | `registrar_herramienta_screen.dart` |
| **H-ALM-06** | Nombre, DNI y N° de préstamo del custodio en cada tarjeta. | `registrar_herramienta_screen.dart` |
| **H-ALM-07** | Las tarjetas de solicitudes aprobadas del dashboard tienen `onTap`. Abren `mostrarDespachoSolicitud()`, el mismo modal de la pestaña Despacho, y recargan el dashboard si se despachó. El subtítulo agrega "Toque para ver y despachar", igual que las tarjetas de préstamos. | `dashboard_almacen_screen.dart` |
| **H-ALM-08** | `registrarPrestamo()` ya no llama a `validarAusenciaDeMoras()`. Se mantiene `validarCupoDisponible()` (máx. 5 herramientas). El aviso de mora al mecánico ya no dice "su cupo queda bloqueado". | `PrestamoServiceImpl.java`, `CupoPrestamoValidator.java` |
| **H-ALM-09** | El diálogo "Nueva herramienta" tiene arriba un campo de foto opcional, con miniatura de 64 px y los botones "Agregar foto", "Cambiar foto" y "Quitar". Al guardar se crea la herramienta y luego se sube la foto. Se quitó el segundo diálogo "¿Desea agregarle una foto ahora?". `seleccionarYSubirImagen()` se dividió en `elegirImagen()` y `subirImagen()`, sin cambiar su comportamiento en las demás pantallas. | `registrar_herramienta_screen.dart`, `imagen_producto.dart` |
| **H-ALM-10** | 1) **En la app:** la ficha de la herramienta tiene el botón "Ver código QR", con el mismo estilo que "Reportar extravío" pero en azul, que muestra el QR, el código y el nombre. Al crear una herramienta se muestra su QR automáticamente para etiquetarla. Se usa `qr_flutter` y el QR contiene solo el código, con corrección de errores M. 2) **Impresión masiva:** `herramientas_qr/imprimir_qr_herramientas.html` (se abre con doble clic en Chrome o Edge). Carga las herramientas desde `GET /api/v1/inventario/herramientas` y genera una hoja de etiquetas (QR, código y nombre) con buscador, selección por casilla y tamaño de 3, 4 o 5 cm. Se imprime o se guarda como PDF. Si no hay conexión, permite pegar los códigos a mano. | `qr_herramienta.dart`, `detalle_herramienta_screen.dart`, `registrar_herramienta_screen.dart`, `pubspec.yaml`, `imprimir_qr_herramientas.html` |
| **H-MEC-01** | Catálogo completo, ordenado: con stock, sin stock y deshabilitados (atenuados y sin poder pedirse). | `catalogo_screen.dart`, `repuesto_entity.dart`, `repuesto_model.dart`, `repuesto_remote_datasource.dart` |
| **H-MEC-02** | "Enviar solicitud" sube junto con el teclado. | `carrito_pedido_screen.dart` |

---

## 🔄 5. Checklist de Ejecución

```markdown
### Ronda 1 – Críticos
- [x] H-GEN-01  MainActivity → FlutterFragmentActivity y la huella no se borra al cerrar sesión
- [x] H-GEN-03  Imágenes persistidas en PostgreSQL
- [x] H-GEN-08  Validar cuenta activa en el backend + interceptor 401 en Dio → logout
- [x] H-ADM-01  Corregir la "eliminación" al desactivar un repuesto
- [x] H-ALM-02  Notificar al ALMACENISTA en toda aprobación
- [x] H-ALM-04  Ciclo de vida de la cámara QR en Retorno

### Ronda 1 – Teclado y SafeArea
- [x] H-GEN-07  Formularios y bottom sheets (viewInsets + isScrollControlled + espacio inferior)
- [x] H-MEC-02  Carrito: "Enviar solicitud" sube con el teclado
- [x] H-ADM-02  Bandeja: el panel del motivo sube con el teclado
- [x] H-ALM-03  Retorno: "Confirmar retorno" respeta la barra del sistema
- [x] H-GEN-06  Perfil: reubicar "Cerrar sesión"
- [x] H-ADM-04  Personal: relleno inferior para los FAB

### Ronda 1 – Mejoras y limpieza
- [x] H-GEN-09  Botón 👁 independiente en cada contraseña
- [x] H-ADM-05  Redirección desde notificaciones
- [x] H-ALM-01  Filtros en Despacho
- [x] H-ALM-06  DNI y nombre del custodio en Herramientas
- [x] H-MEC-01  Catálogo ordenado por disponibilidad
- [x] H-ADM-03  Sección plegable "Repuestos más solicitados"
- [x] H-GEN-02  Quitar "Probar conexión"
- [x] H-ALM-05  Quitar el FAB "Herramientas extraviadas"
- [x] H-GEN-04  Quitar [RFxx] visibles (42)

### Ronda 2 – Reaperturas y ajustes
- [x] H-ADM-01b El switch ya no recarga la lista y conserva los deshabilitados
- [x] H-ALM-02b Revisión de la cadena de notificaciones del almacenista
- [x] H-ADM-06  Quitar "Stock Mínimo" / "Mínimo"

### Ronda 3 – Nuevos hallazgos
- [x] H-GEN-10  Protección global del teclado (rutas + segundo plano + tocar fuera)
- [x] H-ALM-07  Dashboard: tocar una solicitud aprobada abre el modal de despacho
- [x] H-ALM-08  Préstamo permitido aunque el mecánico tenga moras (backend)
- [x] H-ALM-04b mobile_scanner 7.x + extracción del código desde enlace/texto
- [x] H-ALM-09  Foto opcional en el formulario "Nueva herramienta"
- [x] H-ALM-10  QR por herramienta en la app + hoja HTML para imprimir todas las etiquetas
- [ ] H-ALM-10  Imprimir las etiquetas, pegarlas en cada herramienta y probar el escáner con 2 o 3 de ellas

### Despliegue y verificación
- [ ] Desplegar el backend en Render (H-GEN-03/05/08, H-ADM-01/01b/06, H-ALM-02b, H-ALM-08, H-MEC-01)
- [ ] Verificar `GET /catalogo?incluirInactivos=true` (debe incluir los repuestos con `"activo":false`)
- [ ] Aprobar una solicitud MEDIA/BAJA y confirmar que llega "Despacho Pendiente" al almacenista
- [ ] Prestar a un mecánico con un préstamo en mora (debe permitirlo)
- [ ] Compilar el APK (desinstalar antes la versión anterior) y probar: huella, QR (código y enlace), teclado y foto al crear herramienta
- [ ] Completar los puntos de la sección 3 (aclaraciones)
- [ ] Prueba de regresión con los 3 roles
```

---

## 🧾 6. Registro Detallado de Cambios (Changelog)

> Esta sección lista **cada archivo tocado**, qué cambió y por qué.
> Rutas Flutter relativas a `sgsra_mobile/` y rutas backend relativas a `sgsra-md/`.

### 6.1 Backend (Spring Boot)

#### Archivos nuevos

| Archivo | Hallazgo | Especificación |
| :-- | :-- | :-- |
| `src/main/java/.../model/entity/ArchivoAlmacenado.java` | H-GEN-03 / 05 | Entidad de la tabla `archivo_almacenado`: `ruta` (PK, `varchar(200)`), `content_type`, `datos` (`bytea`), `tamano_bytes` y `fecha_subida`. La crea `ddl-auto=update`. |
| `src/main/java/.../DAO/ArchivoAlmacenado_DAO.java` | H-GEN-03 / 05 | `JpaRepository<ArchivoAlmacenado, String>`. |
| `src/main/java/.../controller/ArchivoController.java` | H-GEN-03 / 05 | `GET /uploads/{carpeta}/{archivo}`: devuelve la imagen desde la BD o, si no está, desde el disco (imágenes semilla). Responde 404 si no existe en ninguno. Cache de 30 días. |
| `src/main/java/.../config/CuentaActivaFilter.java` | H-GEN-08 | Filtro de `/api/v1/**` (excepto login, recuperar clave y OPTIONS). Si la cuenta no existe o está `INACTIVO`, responde 401 `{"codigo":"CUENTA_INACTIVA"}`. |

#### Archivos modificados

| Archivo | Hallazgo | Especificación |
| :-- | :-- | :-- |
| `src/main/java/.../service/impl/LocalStorageServiceImpl.java` | H-GEN-03 / 05 | Guarda las imágenes en PostgreSQL. Mantiene las validaciones (5 MB, `image/*`, extensiones permitidas) y el formato de URL `/uploads/{carpeta}/{uuid}.{ext}`. Nuevo `obtenerArchivo()`, con protección contra *path traversal*. |
| `src/main/java/.../controller/CatalogoController.java` | H-ADM-01 / H-MEC-01 | `GET /catalogo` acepta `incluirInactivos` (por defecto `false`). |
| `src/main/java/.../service/impl/SolicitudServiceImpl.java` | H-ALM-02 / 02b / H-ADM-06 | `notificarAprobacion()` avisa al almacenista en todas las prioridades. La alerta de reposición se titula "Stock Bajo" y no menciona el mínimo; el tipo interno `STOCK_MINIMO` no cambia. |
| `src/main/java/.../service/impl/PrestamoServiceImpl.java` | **H-ALM-08** | `registrarPrestamo()` ya no ejecuta `validarAusenciaDeMoras()`: un mecánico con préstamos en mora puede recibir nuevos préstamos. Se mantiene el límite de 5 herramientas simultáneas. El aviso de mora al mecánico dice ahora "Devuelva las herramientas cuanto antes", en lugar de "Su cupo para nuevos préstamos queda bloqueado". |
| `src/main/java/.../service/validator/CupoPrestamoValidator.java` | **H-ALM-08** | Se documenta que `validarAusenciaDeMoras()` ya no se usa en el registro de préstamos. Se conserva por si Administración decide reactivar la sanción. |
| `Dockerfile` | H-GEN-03 | Copia `uploads/` (imágenes semilla) a la imagen final. |

#### Archivos eliminados

| Archivo | Hallazgo | Motivo |
| :-- | :-- | :-- |
| `src/main/java/.../config/WebMvcResourceConfig.java` | H-GEN-05 | `"file:/" + ruta` daba una ruta inválida en Linux (404 en Render). Lo reemplaza `ArchivoController`. |

### 6.2 Frontend móvil (Flutter / Android)

#### Dependencias

| Archivo | Hallazgo | Especificación |
| :-- | :-- | :-- |
| `pubspec.yaml` / `pubspec.lock` | **H-ALM-04b** | `mobile_scanner: ^5.1.1` → `^7.1.0` (resuelve 7.5.0). Requiere Flutter ≥ 3.29; el proyecto usa 3.50. |
| `pubspec.yaml` / `pubspec.lock` | **H-ALM-10** | Nueva dependencia `qr_flutter: ^4.1.0`, escrita en Dart puro, sin código nativo. |

#### Herramienta fuera de la app

| Archivo | Hallazgo | Especificación |
| :-- | :-- | :-- |
| `herramientas_qr/imprimir_qr_herramientas.html` | **H-ALM-10** | Página autónoma que usa `qrcodejs 1.0.0` desde cdnjs. Llama a `GET {API}/inventario/herramientas?size=1000`; el CORS del backend ya permite cualquier origen. Genera una etiqueta por herramienta con su QR (solo el código, nivel M), el código y el nombre. CSS de impresión: oculta los controles y las etiquetas desmarcadas, y evita cortar una etiqueta entre páginas. |

#### Archivos nuevos

| Archivo | Hallazgo | Especificación |
| :-- | :-- | :-- |
| `lib/core/utils/navegacion_solicitud.dart` | H-ADM-05 | `ValueNotifier` global para pedir al módulo Admin que abra una solicitud en la Bandeja. |
| `lib/features/almacen/presentation/widgets/qr_herramienta.dart` | **H-ALM-10** | `mostrarQrHerramienta(context, codigo, nombre)`: diálogo con `QrImageView` de 220 px sobre fondo blanco, el código en azul y el nombre. |
| `lib/core/utils/teclado_guard.dart` | **H-GEN-10** | `cerrarTeclado()`, `TecladoNavigatorObserver` (cierra el teclado en cada push/pop/remove/replace de ruta) y `TecladoGuard` (lo cierra al pasar a `paused`/`hidden` y al tocar una zona vacía con `HitTestBehavior.translucent`; los campos y botones conservan su toque). |

#### Archivos modificados

| Archivo | Hallazgo | Especificación |
| :-- | :-- | :-- |
| `android/app/src/main/kotlin/.../MainActivity.kt` | H-GEN-01 | Hereda de `FlutterFragmentActivity`. |
| `lib/app.dart` | H-GEN-08 / **H-GEN-10** | Registra `navigatorKey` y `scaffoldMessengerKey`. **(H-GEN-10)** Agrega `navigatorObservers: [TecladoNavigatorObserver()]` y `builder: TecladoGuard(...)`. |
| `lib/core/session/session_manager.dart` | H-GEN-01 / 08 | `cerrar()` borra solo la sesión. Nuevos `cerrarPorCuentaDesactivada()` y `forzarCierreSesion()`. |
| `lib/core/network/dio_client.dart` | H-GEN-08 | Un 401 con `CUENTA_INACTIVA` fuerza el cierre de sesión. |
| `lib/core/constants/api_constants.dart` | H-GEN-02 | Descarta el host personalizado. Se eliminó `urlPruebaConexion()` y el import de `foundation` que ya no se usaba. |
| `lib/core/widgets/imagen_producto.dart` | **H-ALM-09** | `seleccionarYSubirImagen()` ahora usa dos funciones nuevas: `elegirImagen(context, {titulo})`, que devuelve el `XFile` sin subirlo, y `subirImagen(context, endpoint, foto)`. Las pantallas que ya lo usaban funcionan igual. |
| `lib/core/widgets/detalle_solicitud_sheet.dart` | H-ADM-02 / H-GEN-07 | `Padding(viewInsets.bottom)`, `scrollPadding` de 160 y la barra del sistema. |
| `lib/core/widgets/selector_buscable.dart` | H-GEN-07 | Se ajusta al teclado y a la barra del sistema. |
| `lib/features/auth/presentation/screens/login_screen.dart` | H-GEN-02 / 04 | Sin configuración ni prueba de IP. |
| `lib/features/auth/presentation/screens/mi_perfil_screen.dart` | H-GEN-05 / 06 / 07 / 09 | Avatar con `Image.network` y respaldo a las iniciales, "Cerrar sesión" más arriba, 👁 por campo y diálogo desplazable. |
| `lib/features/administrador/presentation/screens/admin_main_screen.dart` | H-ADM-05 | Escucha `NavegacionSolicitud` y abre la solicitud en la Bandeja. |
| `lib/features/notificaciones/presentation/screens/centro_notificaciones_screen.dart` | H-ADM-05 | El admin es redirigido a la Bandeja. |
| `lib/features/administrador/presentation/screens/mantenimiento_catalogo_screen.dart` | H-ADM-01 / 01b / 06 / H-GEN-04 | `incluirInactivos: true` y switch optimista con reversión. Conserva los deshabilitados y muestra la etiqueta "DESHABILITADO". Sin el campo "Stock Mínimo" (`stockMinimo: 0` al crear, valor conservado al editar). |
| `lib/features/administrador/presentation/screens/gestion_personal_screen.dart` | H-ADM-04 / H-GEN-09 | Relleno de 170 px y 👁 en "Añadir usuario". |
| `lib/features/administrador/presentation/screens/reportes_analiticos_screen.dart` | H-ADM-03 / 06 | `_Tarjeta` plegable. La sección "Repuestos con stock bajo" ya no muestra "Mínimo: X". |
| `lib/features/administrador/presentation/screens/solicitudes_recuperacion_screen.dart` | H-GEN-07 | Diálogo desplazable. |
| `lib/features/almacen/presentation/screens/dashboard_almacen_screen.dart` | **H-ALM-07** | Importa `despacho_repuestos_tab.dart`. Cada tarjeta de solicitud aprobada tiene `onTap`, que llama a `mostrarDespachoSolicitud(context, solicitudNum)` y ejecuta `_cargarDatos()` si se despachó. Subtítulo: "Toque para ver y despachar". |
| `lib/features/almacen/presentation/screens/despacho_repuestos_tab.dart` | H-ALM-01 / H-ADM-06 | Buscador, chips de prioridad y periodo. "(llega al mínimo)" → "(stock bajo)". |
| `lib/features/almacen/presentation/screens/retorno_qr_screen.dart` | H-ALM-03 / 04 / **04b** | Ciclo de vida de la cámara, `DetectionSpeed.normal` + control de repetidos de 3 s y `padding.bottom` en el modal. **(H-ALM-04b)** `errorBuilder: (ctx, err)` (API de 7.x) y nuevo `_extraerCodigo(raw)`, usado por `_procesarCodigo()`. |
| `lib/features/almacen/presentation/screens/registrar_herramienta_screen.dart` | H-ALM-05 / 06 / **09** | Sin el FAB de extravío y con `_FilaCustodio`. **(H-ALM-09)** El diálogo "Nueva herramienta" usa `StatefulBuilder` con un campo de foto opcional (vista previa con `Image.memory`). Al guardar, crea la herramienta y, si hay foto, llama a `subirImagen(...)`; si no, muestra "{cod} registrada". El `DropdownButtonFormField` usa `isExpanded: true` para que entre en el diálogo. **(H-ALM-10)** Después de crear la herramienta, se muestra su QR con `mostrarQrHerramienta()`. |
| `lib/features/almacen/presentation/screens/detalle_herramienta_screen.dart` | **H-ALM-10** | Botón "Ver código QR" (borde azul) encima de "Reportar extravío". |
| `lib/features/almacen/presentation/screens/reportar_extravio_modal.dart` | H-GEN-07 | Suma la barra del sistema. |
| `lib/features/mecanico/domain/entities/repuesto_entity.dart` · `data/models/repuesto_model.dart` · `data/datasources/repuesto_remote_datasource.dart` | H-MEC-01 | Campo `activo` en la entidad. Se pide `size: 500` e `incluirInactivos: true`. |
| `lib/features/mecanico/presentation/screens/catalogo_screen.dart` | H-MEC-01 / H-GEN-07 / H-ADM-06 | Orden en tres grupos y deshabilitados atenuados. El chip dice solo "Físico: X". |
| `lib/features/mecanico/presentation/screens/carrito_pedido_screen.dart` | H-MEC-02 | `scrollPadding` de 140 y `keyboardDismissBehavior.onDrag`. |
| `auditoria_screen.dart`, `bandeja_solicitudes_screen.dart`, `proveedores_modal.dart`, `detalle_herramienta_screen.dart`, `registrar_prestamo_screen.dart`, `herramientas_prestadas_screen.dart`, `historial_solicitudes_screen.dart`, `core/utils/app_router.dart` | H-GEN-04 | Se quitaron las etiquetas `[RFxx]` visibles. |

### 6.3 Cambios de contrato / operación

- **API:** `GET /api/v1/catalogo?incluirInactivos=true` es nuevo y opcional. Sin el parámetro, responde igual que antes.
- **API:** `GET /uploads/{carpeta}/{archivo}` ahora lo sirve un controlador, pero la URL no cambia.
- **API:** cualquier petición `/api/v1/**` de una cuenta `INACTIVO` responde `401 CUENTA_INACTIVA`.
- **API (H-ALM-08):** `POST` de registro de préstamo ya no responde 400 "Bloqueo preventivo" por moras. Solo valida el cupo de 5 herramientas.
- **BD:** nueva tabla `archivo_almacenado`, creada automáticamente al arrancar.
- **Datos:** las fotos subidas antes de este cambio se perdieron del disco de Render y hay que volver a subirlas.
- **Despliegue:** las correcciones del backend **no se ven en la app hasta desplegar en Render**, porque la app usa ese servidor. Al 25/11/2026, Render todavía ejecuta el código anterior.
- **APK:** el cambio de `MainActivity` y la actualización de `mobile_scanner` (código nativo) **exigen recompilar e instalar el APK**. No basta con un hot reload. Se recomienda desinstalar la versión anterior.
- **Verificación:**
  - `flutter analyze` no muestra errores y el backend compila.
  - Los tests del backend dan 30 casos con 3 fallas que **ya existían** antes de estos cambios: `SolicitudServiceTest.testAprobarSolicitudTotal_Exito`, `AutenticacionServiceTest.testAutenticar_BloqueoPorTresIntentos` y `FlujoCompletoTddIntegrationTest.testTdd_AutenticacionExitosa`.
  - `PrestamoServiceTest` y `PrestamoIntegrationTest` pasan.
  - Falta compilar el APK y probarlo en un teléfono físico.
