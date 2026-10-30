instrucciones
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
Repetir proceso

=============================================
leao.chura@masterdrilling.com 
admin

carlos.baro@masterdrilling.com 
meca

marcos.baro@masterdrilling.com 
alma

Inserción de 3 usuarios funcionales desde carpeta principal Terminal 3:

Invoke-RestMethod -Uri "http://localhost:8080/api/v1/auth/login" -Method POST -ContentType "application/json" -Body '{"correoCorporativo":"leao.chura@masterdrilling.com","contrasena":"admin"}'

Invoke-RestMethod -Uri "http://localhost:8080/api/v1/auth/usuarios" -Method POST -ContentType "application/json" -Body '{"dni":"70000001","nombre":"Carlos Mendoza Baro","correoCorporativo":"carlos.baro@masterdrilling.com","contrasena":"meca","rol":"MECANICO","especialidad":"Hidraulica","cargo":"Mecanico de Planta","telefono":"987654321"}'

Invoke-RestMethod -Uri "http://localhost:8080/api/v1/auth/usuarios" -Method POST -ContentType "application/json" -Body '{"dni":"70000002","nombre":"Marcos Ramos Baro","correoCorporativo":"marcos.baro@masterdrilling.com","contrasena":"alma","rol":"ALMACENISTA","sedeAsignada":"Taller Lurin"}'
