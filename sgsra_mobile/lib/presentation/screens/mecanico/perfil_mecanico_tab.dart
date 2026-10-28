import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';

class PerfilMecanicoTab extends StatelessWidget {
  const PerfilMecanicoTab({super.key});

  // Instanciación estática de controladores para evitar recreación cíclica en memoria durante el build
  static final TextEditingController _nombreController = TextEditingController(text: "Carlos Mendoza");
  static final TextEditingController _telefonoController = TextEditingController(text: "987654321");

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Ficha técnica del Mecánico 
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 44,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.construction, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 12),
                const Text("Carlos Mendoza", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                  child: const Text("MECANICO", style: TextStyle(color: Color(0xFF0D47A1), fontWeight: FontWeight.bold, fontSize: 11)),
                ),
                const SizedBox(height: 12),
                const Text("Código Operativo: MEC-4029", style: TextStyle(color: Colors.grey, fontSize: 13)),
                const Text("Mantenimiento ", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                const Text("Ingreso: 15 ene. 2026, 03:00 a. m.", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text("DATOS PERSONALES DE CONTACTO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 8),
        TextField(
          decoration: const InputDecoration(labelText: "Nombre Completo del Operario"),
          controller: _nombreController, // Referencia corregida libre de errores 'const'
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: const InputDecoration(labelText: "Teléfono de Contacto (9 dígitos)", prefixIcon: Icon(Icons.phone, size: 16)),
          controller: _telefonoController, // Referencia corregida libre de errores 'const'
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 44)),
          onPressed: () {
            // Acción futura para envío de datos actualizados al controlador del backend
          },
          child: const Text("Guardar Cambios de Perfil"),
        ),
        const SizedBox(height: 16),
        // Panel de Seguridad del Sistema 
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("SEGURIDAD & MANTENIMIENTO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const Divider(height: 20),
                const Text("Autenticación Biométrica", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const Text("Sensor de huella dactilar configurado.", style: TextStyle(color: Colors.grey, fontSize: 12)),
                const Text("ACTIVO Y VINCULADO", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11)),
                const Divider(height: 24),
                const Text("Restablecer Datos de Demostración", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const Text("Limpia la cola de borradores locales.", style: TextStyle(color: Colors.grey, fontSize: 12)),
                TextButton(onPressed: () {}, child: const Text("Reiniciar Base de Datos Local", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Botón de Cierre de Sesión 
        OutlinedButton(
          style: OutlinedButton.styleFrom(foregroundColor: Colors.red.shade700, side: BorderSide(color: Colors.red.shade200)),
          onPressed: () {
            context.read<AuthBloc>().add(LogoutRequested());
          },
          child: const Text("Cerrar Sesión Activa"),
        )
      ],
    );
  }
}
