**Resumen:**
Con tus definiciones cerradas, la arquitectura queda blindada para operar como producto real en Master Drilling: toda la mensajería y alertas se centralizarán en una tabla `notificacion` en PostgreSQL 18 consultada vía API REST; respecto a Flutter, tu lógica de negocio es 100% reutilizable en Android, pero hay que ajustar 3 detalles puntuales de plataforma (URL de red local, eliminación de `dart:html` en descargas y permisos en AndroidManifest) para compilar el APK sin fallos; y la protección contra edición entre administradores se resuelve con reglas estrictas de jerarquía en el backend (sin inflar la interfaz con un cuarto rol), dejando la creación de cuentas de jefatura al área de Sistemas/TI de la empresa.

---

### 1. Respuesta Técnica sobre el APK en 3 Celulares (¿Es cierto que Flutter no requiere cambios?)

Es **95% cierto**, toda tu arquitectura (`BLoC`, modelos, casos de uso, pantallas y lógica) funciona idéntica en Android sin reescribir código. Sin embargo, como desarrollaste y probaste inicialmente en **Web (Chrome)**, hay **3 ajustes obligatorios** antes de ejecutar `flutter build apk --release` para que no falle al compilar o conectarse desde los 3 celulares:

1. **La dirección IP del Servidor (`api_constants.dart`):**

- En Web usabas `http://localhost:8080/api/v1`. En un celular físico, `localhost` apunta al propio teléfono, no a tu laptop.

- **Qué hacer:** Debes colocar la IP IPv4 local de la laptop donde corre Spring Boot (ej. `[http://192.168.1.45:8080/api/v1](http://192.168.1.45:8080/api/v1)`), conectar los 3 celulares y la laptop a la misma red Wi-Fi (o compartir datos desde uno de los celulares), y habilitar el puerto `8080` en el Firewall de Windows.

2. **Eliminar importaciones exclusivas de navegador (`dart:html`):**

- En `reportes_analiticos_screen.dart` (Hallazgo H02), para descargar el Excel/CSV en Chrome se usó `dart:html` (`html.Blob`, `html.AnchorElement`). Si compilas un APK con `import 'dart:html';`, **Flutter abortará la compilación** porque Android no tiene DOM de navegador.

- **Qué hacer:** Reemplazar esa descarga por `path_provider` + `open_filex` (o `share_plus`) para guardar el `.xlsx`/`.csv` en la carpeta de descargas del celular y abrirlo con Excel/WPS móvil.

3. **Permisos en `AndroidManifest.xml`:**

- Ya tienes declarados `INTERNET`, `CAMERA` y `USE_BIOMETRIC`. Solo debes agregar `android:usesCleartextTraffic="true"` dentro de la etiqueta `<application>` para que Android permita peticiones HTTP sin certificado SSL hacia tu IP local (`[http://192.168.](http://192.168.)x.x:8080`).

---

### 2. Resolución del Hallazgo Grave: Protección entre Administradores

Tu observación es crítica en seguridad de sistemas: **un Administrador no debe poder bloquear, editar ni cambiar la contraseña de otro Administrador**.

- **Decisión de Arquitectura (Sin crear un 4to rol en UI):** No hace falta crear pantallas de "Super Administrador" que compliquen el flujo móvil. En su lugar, aplicamos **Seguridad Jerárquica en el Backend (`AutenticacionServiceImpl.java`)**:

1. **Bloqueo de jerarquía horizontal:** Si un usuario con rol `ADMINISTRADOR` intenta editar, deshabilitar o resetear la contraseña de otro usuario cuyo rol sea `ADMINISTRADOR` (y no sea él mismo), el backend lanza `AccesoDenegadoException` (_HTTP 403 Forbidden: "No tiene privilegios para modificar cuentas de nivel administrativo"_).
2. **Gestión por TI / Sistemas:** La creación inicial o baja de cuentas de `ADMINISTRADOR` queda reservada exclusivamente para el administrador de base de datos / área de Sistemas de Master Drilling (mediante script SQL inicial o consola segura del servidor), tal como ocurre en entornos corporativos reales.

---

### 3. Plan de Implementación Cerrado (100% Producción PostgreSQL + Flutter APK)

A partir de tus respuestas y del avance consolidado, este es el cronograma estructurado en fases para la finalización del sistema:

#### ✅ Fase A: Backend Spring Boot y Base de Datos (Completada al 100%)

- **Tabla y API de Notificaciones (`RF46` - `RF50`):** Tabla física, normalización contra check constraint de BD, endpoints listar, paginar y marcar leídas.
- **Aprobación Parcial (`RF26`) y Despacho:** Endpoint `PUT /aprobar-parcial`, estado `ENTREGADA` y endpoint `PUT /entregar` con descuento de stock físico.
- **Seguridad Jerárquica y Modo TI (`RF06`, `RF07`, `SEC-01`):** Bloqueo horizontal entre administradores en API; soporte y reseteo directo en consola TI.
- **Auditoría SHA-256 (`RF49`):** Asientos criptográficos inmutables por cada operación crítica.
- **Subida de Imágenes:** `LocalStorageServiceImpl` con límite < 5 MB y exposición en `/uploads/**`.

---

#### ✅ Fase 2.9: Cierre de Calibración Backend (Completada al 100%)

Se cerraron con éxito los 4 puntos detectados en la auditoría E2E y nuevos requerimientos:

1. **Lógica de Devolución:** En `PrestamoServiceImpl`, las herramientas devueltas como `INCOMPLETA` pasan automáticamente a `En Mantenimiento` / retenidas con incidencia en pañol, nunca `Disponible`.
2. **Historial de Préstamo:** Se actualiza `hora_retorno` en `prestamo_detalle` al procesar la devolución física para que el historial refleje la hora exacta de retorno y no figure como `"EN POSESION / ACTIVO"`.
3. **Alerta de Mora:** Al pasar un préstamo a `MORA` en `verificarAlertasPrestamos()`, se actualizan las herramientas asociadas en la tabla `herramienta` a `estado_actual = 'En Mora'` para habilitar el resalte rojo en pañol (RF43).
4. **Evidencia Selfie en Recuperación:** Se agregó la columna `foto_selfie_url` en `SolicitudRecuperacionClave`, soporte multipart en `POST /api/v1/auth/recuperar-clave` con guardado en `./uploads/selfies/` y exposición de `fotoSelfieUrl` en `SolicitudRecuperacionResponse` para que el Administrador valide la identidad antes de aprobar.

---

#### 🚀 Fase 3: Core Móvil, Red WiFi & Componentes Transversales (Android APK Ready)
1. **Eliminación limpia de dependencias Web:** Reemplazar `dart:html` / `universal_html` en `reportes_analiticos_screen.dart` utilizando `path_provider` y `open_filex` para guardar y abrir reportes Excel/CSV en descargas de Android.
2. **Parametrización de Red Local:** Centralizar en `api_constants.dart` la IP IPv4 dinámica de la laptop host y verificar `usesCleartextTraffic="true"` en `AndroidManifest.xml`.
3. **Centro Universal de Notificaciones (`RF50`):**
   - Ícono de campana con badge dinámico de no leídas en el AppBar de los 3 paneles principales (`MecanicoMainScreen`, `AdminMainScreen`, `AlmacenMainScreen`).
   - Pantalla/modal de notificaciones con pestañas _No leídas_ / _Leídas_ y botón _"Marcar todas como leídas"_.
4. **Seguridad, Bloqueo Escalonado y Recuperación con Selfie (`RF04`, `RF06`, `REQ-02`):**
   - **Bloqueo Escalonado Reactivo:** Primeros 3 fallos consecutivos $\rightarrow$ espera 5 minutos con cuenta regresiva en pantalla; siguientes 3 fallos (6 en total) $\rightarrow$ espera 10 minutos; tras 9 fallos $\rightarrow$ Bloqueo Total (`BLOQUEADO`), inhabilitando el login.
   - **Formulario Modal de Recuperación:** Permite ingresar DNI (8 dígitos) y teléfono (9 dígitos).
   - **Captura de Foto Selfie:** Exige tomar una selfie en vivo con la cámara frontal (`image_picker` con `CameraDevice.front`) y la adjunta al envío de la solicitud hacia Administración para verificación visual del operario.
5. **Pantalla Mi Perfil Universal (`RF07`, `REQ-01`):**
   - Bloqueo estricto de DNI, nombre, especialidad y correo (`readOnly = true`); permitir editar únicamente teléfono y cambio de contraseña propia.

---

#### 📱 Fase 4: Flujos Operativos y Vistas Especializadas por Rol

1. **Módulo Mecánico:**
   - Despliegue de fotos de repuestos en catálogo y ficha técnica (`RF09`, `RF12`) con fallback `errorBuilder` corporativo si no hay foto o se pierde la red.
   - Despliegue automático de la vista del carrito de repuestos al pulsar "Crear Solicitud" (`REQ-03`) y limpieza post-envío (`BUG-04`).
   - Historial cromático personal de solicitudes (`RF19`, `RF20`) y consulta de herramientas bajo su custodia (`RF36`, `RF40`).
2. **Módulo Administrador:**
   - Ordenamiento FIFO de solicitudes pendientes (más antiguas arriba en la bandeja - `RF21`).
   - Modal de aprobación parcial por ítem (`RF26`) con motivo general obligatorio si hay ítems denegados.
   - Barra de búsqueda dinámica y selector por rol en Gestión de Personal (`admin/`).
   - Filtros avanzados combinados en Auditoría (`RF31`): rango de fechas, usuario/DNI, acción y código de máquina.
   - Selector fotográfico (`image_picker`) con cámara o galería en mantenimiento de repuestos (`RF32`).
   - Actualmente el apartado de audiotria esta cargando datos en plano, no desde la base de datos, actualizar esto y eliminar los registros planos.
3. **Módulo Almacenista (Ergonomía de Pañol Consolidada):**
   - Rediseño a 4 pestañas principales: Operaciones/Dashboard, Herramientas, Historial de Devoluciones y Mi Perfil.
   - Botón Flotante Central (FAB) para Escáner QR inteligente: si la herramienta está `Disponible` abre _"Registrar Préstamo"_; si está `Prestada` abre _"Registrar Devolución e Inspección Física"_ (`Buen Estado`, `Con Avería`, `Incompleta`).
   - Resaltado en rojo brillante con ícono de reloj en la tabla de préstamos para activos con mora vencida (`RF43`).
   - Bandeja de despacho de repuestos aprobados (`PUT /api/v1/solicitudes/{id}/entregar`) con confirmación de entrega y descuento de stock en tiempo real.
   - Selector fotográfico (`image_picker`) para registro de nuevas herramientas en pañol (`RF44`, `RF45`).

---

#### 📦 Fase 5: Pruebas Integradas E2E en Red WiFi, Compilación APK y Despliegue

1. **Conectividad WiFi LAN:** Validar conexión HTTP entre los 3 celulares físicos y la laptop Spring Boot en el puerto 8080.
2. **Ciclo Cruzado E2E:** Mecánico solicita $\rightarrow$ Admin aprueba/parcial $\rightarrow$ Almacenista despacha repuestos; Almacén presta herramienta $\rightarrow$ Mecánico custodia $\rightarrow$ Almacén liquida por QR.
3. **Compilación APK Release:** Ejecutar `flutter build apk --release` verificando 0 advertencias críticas y 0 imports web.
4. **Instalación y Puesta en Marcha:** Instalar el APK en los 3 dispositivos Android de Master Drilling Perú S.A. y verificar operatividad 100% offline de internet externo.
