**Resumen:**
Con tus definiciones cerradas, la arquitectura queda blindada para operar como producto real en Master Drilling: toda la mensajería y alertas se centralizarán en una tabla `notificacion` en PostgreSQL 18 consultada vía API REST; respecto a Flutter, tu lógica de negocio es 100% reutilizable en Android, pero hay que ajustar 3 detalles puntuales de plataforma (URL de red local, eliminación de `dart:html` en descargas y permisos en AndroidManifest) para compilar el APK sin fallos; y la protección contra edición entre administradores se resuelve con reglas estrictas de jerarquía en el backend (sin inflar la interfaz con un cuarto rol), dejando la creación de cuentas de jefatura al área de Sistemas/TI de la empresa.

---

### 1. Respuesta Técnica sobre el APK en 3 Celulares (¿Es cierto que Flutter no requiere cambios?)

Es **95% cierto**, toda tu arquitectura (`BLoC`, modelos, casos de uso, pantallas y lógica) funciona idéntica en Android sin reescribir código. Sin embargo, como desarrollaste y probaste inicialmente en **Web (Chrome)**, hay **3 ajustes obligatorios** antes de ejecutar `flutter build apk --release` para que no falle al compilar o conectarse desde los 3 celulares:

1. **La dirección IP del Servidor (`api_constants.dart`):**
* En Web usabas `http://localhost:8080/api/v1`. En un celular físico, `localhost` apunta al propio teléfono, no a tu laptop.


* **Qué hacer:** Debes colocar la IP IPv4 local de la laptop donde corre Spring Boot (ej. `[http://192.168.1.45:8080/api/v1](http://192.168.1.45:8080/api/v1)`), conectar los 3 celulares y la laptop a la misma red Wi-Fi (o compartir datos desde uno de los celulares), y habilitar el puerto `8080` en el Firewall de Windows.


2. **Eliminar importaciones exclusivas de navegador (`dart:html`):**
* En `reportes_analiticos_screen.dart` (Hallazgo H02), para descargar el Excel/CSV en Chrome se usó `dart:html` (`html.Blob`, `html.AnchorElement`). Si compilas un APK con `import 'dart:html';`, **Flutter abortará la compilación** porque Android no tiene DOM de navegador.


* **Qué hacer:** Reemplazar esa descarga por `path_provider` + `open_filex` (o `share_plus`) para guardar el `.xlsx`/`.csv` en la carpeta de descargas del celular y abrirlo con Excel/WPS móvil.


3. **Permisos en `AndroidManifest.xml`:**
* Ya tienes declarados `INTERNET`, `CAMERA` y `USE_BIOMETRIC`. Solo debes agregar `android:usesCleartextTraffic="true"` dentro de la etiqueta `<application>` para que Android permita peticiones HTTP sin certificado SSL hacia tu IP local (`[http://192.168.](http://192.168.)x.x:8080`).





---

### 2. Resolución del Hallazgo Grave: Protección entre Administradores

Tu observación es crítica en seguridad de sistemas: **un Administrador no debe poder bloquear, editar ni cambiar la contraseña de otro Administrador**.

* **Decisión de Arquitectura (Sin crear un 4to rol en UI):** No hace falta crear pantallas de "Super Administrador" que compliquen el flujo móvil. En su lugar, aplicamos **Seguridad Jerárquica en el Backend (`AutenticacionServiceImpl.java`)**:
1. **Bloqueo de jerarquía horizontal:** Si un usuario con rol `ADMINISTRADOR` intenta editar, deshabilitar o resetear la contraseña de otro usuario cuyo rol sea `ADMINISTRADOR` (y no sea él mismo), el backend lanza `AccesoDenegadoException` (*HTTP 403 Forbidden: "No tiene privilegios para modificar cuentas de nivel administrativo"*).
2. **Gestión por TI / Sistemas:** La creación inicial o baja de cuentas de `ADMINISTRADOR` queda reservada exclusivamente para el administrador de base de datos / área de Sistemas de Master Drilling (mediante script SQL inicial o consola segura del servidor), tal como ocurre en entornos corporativos reales.



---

### 3. Plan de Implementación Cerrado (100% Producción PostgreSQL + Flutter APK)

A partir de tus respuestas, este es el listado definitivo de modificaciones que ejecutaremos en el código:

#### Fase A: Base de Datos PostgreSQL 18 y Backend (Spring Boot)

1. **Tabla y API de Notificaciones (`RF46` - `RF50`):**
* Crear tabla física `notificacion` (`id_notificacion`, `dni_destinatario`, `rol_destinatario`, `titulo`, `mensaje`, `tipo_alerta`, `leida`, `fecha_creacion`).
* Disparar inserciones automáticas en PostgreSQL cuando:
* Mecánico envía solicitud (`RF17`) $\rightarrow$ Notifica a `ADMINISTRADOR`.


* Admin aprueba/rechaza total o parcialmente (`RF23`, `RF24`, `RF26`) $\rightarrow$ Notifica al `MECANICO` solicitante.


* Almacenista reporta extravío (`RF41`, `RF42`) $\rightarrow$ Notifica al `MECANICO` custodio y deja registro auditado para `ADMINISTRADOR`.


* Stock de repuesto cae por debajo de `stock_minimo` o préstamo supera tiempo límite (`RF43`/`RF48`) $\rightarrow$ Notifica a `ADMINISTRADOR` / `ALMACENISTA`.




* Endpoints REST: `GET /api/v1/notificaciones/{dni}`, `PUT /api/v1/notificaciones/{id}/leer` y `PUT /api/v1/notificaciones/leer-todas/{dni}`.


2. **Aprobación Parcial (`RF26`) y Despacho de Repuestos en Almacén:**
* Activar el endpoint `PUT /api/v1/solicitudes/{solicitudNum}/aprobar-parcial` (que ya existe en tu `SolicitudController`) y agregar estado `ENTREGADA` cuando el almacenista despache físicamente los repuestos aprobados descontando el `stock_actual`.




3. **Bloqueo Escalonado, Solicitud de Desbloqueo y Protección Admin (`RF06`, `RF07`):**
* Implementar tiempos de bloqueo progresivo (3 fallos = 5 min, 6 fallos = 15 min, 9 fallos = bloqueo total hasta intervención de Admin).
* Endpoint `POST /api/v1/auth/solicitar-desbloqueo` que crea una alerta al Administrador.
* Endpoint `PUT /api/v1/auth/usuarios/dni/{dni}/reset-clave` para que el Administrador asigne una nueva clave temporal a mecánicos/almacenistas (bloqueando estrictamente si el objetivo es otro `ADMINISTRADOR`).


4. **Filtros Avanzados en Auditoría (`RF31`, `RF49`):**
* Corregir la consulta de `AuditoriaOperacion_DAO` para soportar filtros combinados por rango de fechas, acción y usuario sin errores de inferencia de tipos en PostgreSQL.


5. **Base de Datos (PostgreSQL 18): Agregar la columna imagen_url VARCHAR(255) en las tablas físicas repuesto y herramienta.**

Almacenamiento Físico (StorageService): Crear una carpeta local en el servidor (ej. uploads/imagenes/) y exponerla mediante WebMvcConfigurer como recurso estático (/uploads/**).

Endpoints MultipartFile:

Actualizar o crear endpoints POST /api/v1/catalogo/{codParte}/imagen y POST /api/v1/inventario/herramientas/{codHerramienta}/imagen que reciban la foto (MultipartFile), validen que pese menos de 5 MB (RF32 Ex3), la guarden en disco y actualicen imagen_url en PostgreSQL.

Incluir el campo imagenUrl en los DTOs de respuesta (RepuestoResponse y FichaHerramientaResponse).


#### Fase B: Frontend Móvil (Flutter APK Multiplataforma)

1. **Centro de Notificaciones Universal (`RF50`) y Alerta de Mora (`RF43`):**
* Añadir ícono de campana con badge contador en los 3 módulos (`MecanicoMainScreen`, `AdminMainScreen`, `AlmacenMainScreen`) abriendo el historial de notificaciones (*No leídas* / *Leídas*).


* Resaltar en rojo brillante las filas con tiempo excedido en el tablero de préstamos del pañol (`RF43`).




2. **Mejoras en Pañol (`RF33`, `RF38`) y Admin (`RF26`, `RF31`):**
* **Almacén:** Agregar catálogo general de herramientas (agrupadas por modelo/nombre con stock disponible) y botón directo *"Procesar Devolución"* al escanear el QR de una herramienta prestada.


* **Admin:** Implementar checkboxes por ítem en el expediente de solicitud para aprobación/rechazo parcial (`RF26`) y barra de filtros en Auditoría (`RF31`).


* **Perfil (`RF07`):** Bloquear edición de DNI, nombre y correo; permitir editar solo teléfono.




3. **Adaptación Multiplataforma para Compilar APK:**
* Eliminar `dart:html` en `reportes_analiticos_screen.dart` usando guardado nativo de archivos para Android.
* Configurar `usesCleartextTraffic="true"` en `AndroidManifest.xml` y parametrizar la IP de conexión.



4. **En la Fase B: Frontend Móvil (Flutter APK)**
Dependencia: Agregar image_picker en pubspec.yaml (y los permisos de galería/cámara en AndroidManifest.xml).

Captura de Foto (Admin y Almacenista): En los formularios de creación/edición de repuestos (mantenimiento_catalogo_screen.dart) y alta de herramientas (registrar_herramienta_screen.dart), agregar un selector con dos botones: "Tomar Foto" (cámara) o "Elegir de Galería", enviando la imagen al backend mediante FormData de Dio.

Renderizado y Fallback (RF09, RF12, RF35, RF45):

Mostrar la imagen con Image.network('${ApiService.serverUrl}${item.imagenUrl}') en las tarjetas del catálogo de repuestos, en el modal de ficha técnica (RF12), en el catálogo de herramientas del pañol y al escanear el QR (RF35).

Configurar errorBuilder en el widget de imagen para que, si un ítem antiguo aún no tiene foto o se pierde la red momentáneamente (RF12 Ex2), muestre un ícono vectorial corporativo por defecto sin romper la pantalla.

Con este ajuste incorporado, ¿arrancamos directamente con el código de la Fase A (SQL + Entidades + Endpoints de Notificaciones, Seguridad Jerárquica y Subida de Imágenes en Spring Boot)?

---

¿Empezamos implementando la **Fase A (Backend Spring Boot + SQL PostgreSQL para Notificaciones, Seguridad Jerárquica y Desbloqueo)** para dejar la API 100% lista antes de pasar a las pantallas de Flutter y generar el APK?