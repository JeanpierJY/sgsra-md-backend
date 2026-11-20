INSTRUCCIONES INICIO EN WEB
1.Abrir PgAdmin4, apretar en servers, debería aparecer un mensaje de servidor conectado

2. Terminal 1 Compilar BackEnd:
   .\sgsra-md\mvnw.cmd -f sgsra-md/pom.xml spring-boot:run

3. Terminal 2 Compilar FrontEnd:
   cd sgsra_mobile

cmd /c "rd /s /q build"

flutter run -d chrome

=============================================
Si falla la compilacion frontend usar:
Stop-Process -Name "dart", "chrome" -Force -ErrorAction SilentlyContinue

Repetir proceso terminal 2

=============================================
Usuarios predeterminados:
leao.chura@masterdrilling.com
admin1234

carlos.baro@masterdrilling.com
meca

marcos.baro@masterdrilling.com
alma

=============================================
Comandos Generar APK

# 1. Entrar a la carpeta móvil

cd sgsra_mobile

# 2. Compilar el APK release

& "C:\Users\Usuario\flutter\bin\flutter.bat" build apk --release

# 3. Sobrescribir el apk en la carpeta raíz del proyecto

Copy-Item build\app\outputs\flutter-apk\app-release.apk ..\sgsra-md.apk -Force
