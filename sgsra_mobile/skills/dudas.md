1. ¿Por qué auditoria_operacion NO tiene FOREIGN KEY?
Una bitácora de auditoría legal/forense debe ser indestructible e independiente a las demás tablas
Si un atacante o empleado despedido intenta hacer login con un DNI o usuario que no existe en la base de datos, el sistema debe auditar ese intento fallido.

2. ¿Por qué notificacion NO tiene FOREIGN KEY?
Porque esta dirigida a todos los usuario y el sistema global, no se podrian emetir alertas grupales.

3. 