# SGSRA-MD (Master Drilling Perú S.A.)
Sistema de Gestión de Solicitudes de Repuestos para Maquinarias Pesadas y Control de Almacén de Herramientas.

---

## 🌐 BACKEND EN LA NUBE (RENDER CLOUD)

El backend de Spring Boot y la base de datos PostgreSQL se encuentran desplegados y disponibles públicamente en:
- **API URL Base:** `https://sgsra-md-backend.onrender.com/api/v1`
- **Swagger UI (Documentación interactiva):** `https://sgsra-md-backend.onrender.com/swagger-ui.html`
- **Endpoint de verificación de estado (Health/Catálogo):** `https://sgsra-md-backend.onrender.com/api/v1/catalogo`

### ⚡ ¿Cómo funciona el encendido del servidor?
1. **Comportamiento en Plan Gratuito (Spin Down / Reposo):**
   - Si no recibe peticiones durante 15 minutos continuos, Render suspende temporalmente el contenedor para ahorrar recursos.
   - **Tiempo de arranque:** La primera petición tras el reposo demora entre **1 a 2 minutos** mientras el contenedor Docker de Java 21 / Spring Boot arranca y conecta con PostgreSQL.
2. **Prevención activa con UptimeRobot (Keep-Alive 24/7):**
   - Actualmente se utiliza [UptimeRobot.com](https://uptimerobot.com) configurado con un monitor HTTP GET cada 5 minutos apuntando a `https://sgsra-md-backend.onrender.com/api/v1/catalogo`. Esto evita que el contenedor entre en modo reposo y mantiene el servidor despierto 24/7.
3. **Encendido Manual de Contingencia:**
   - Si por alguna razón UptimeRobot se pausa o la app móvil muestra un error de conexión inicial, basta con abrir en cualquier navegador (PC o celular):
     👉 `https://sgsra-md-backend.onrender.com/api/v1/catalogo`
   - Esperar 1 a 2 minutos hasta que aparezca el JSON con los datos. En ese instante el servidor estará 100% activo y la app conectará de inmediato.

> ⚠️ **Nota sobre Almacenamiento Multimedia:** En Render, el sistema de archivos del contenedor es efímero. Si el servicio se reinicia o se despliega una nueva versión, los archivos subidos a `./uploads/` se eliminan. Se tiene planificado migrar la persistencia multimedia a un servicio en la nube (Cloudinary, AWS S3 o Firebase Storage).

---

## 💻 INSTRUCCIONES INICIO EN LOCAL (DESARROLLO OPCIONAL)

1. **Base de Datos:**
   Abrir PgAdmin4 y verificar que el servidor local o de Render esté conectado.

2. **Terminal 1 - Compilar y Levantar Backend Spring Boot:**
   ```powershell
   .\sgsra-md\mvnw.cmd -f sgsra-md/pom.xml spring-boot:run
   ```

3. **Terminal 2 - Compilar Frontend Flutter (Web):**
   ```powershell
   cd sgsra_mobile
   cmd /c "rd /s /q build"
   flutter run -d chrome
   ```

*Si falla la compilación web usar:*
```powershell
Stop-Process -Name "dart", "chrome" -Force -ErrorAction SilentlyContinue
```

---

## 👥 USUARIOS OFICIALES DE PRUEBA

| Rol | Correo Corporativo | Contraseña |
| :--- | :--- | :--- |
| **Administrador** | `leao.chura@masterdrilling.com` | `admin` |
| **Mecánico** | `carlos.baro@masterdrilling.com` | `meca` |
| **Almacenista** | `marcos.baro@masterdrilling.com` | `alma` |

---

## 📱 GENERACIÓN DE APK RELEASE ANDROID

Para generar el APK de producción conectado a Render:

```powershell
# 1. Entrar a la carpeta móvil
cd sgsra_mobile

# 2. Compilar el APK release
& "C:\Users\Usuario\flutter\bin\flutter.bat" build apk --release

# 3. Sobrescribir el apk en la carpeta raíz del proyecto
Copy-Item build\app\outputs\flutter-apk\app-release.apk ..\sgsra-md.apk -Force
```
