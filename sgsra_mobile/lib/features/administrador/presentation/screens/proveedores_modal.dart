import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';

/// [RF27] Enlaces a proveedores homologados (Bosch Rexroth, Enerpac, Parker, Donaldson, Festo)
/// con redirección automática a la aplicación de teléfono nativa.
void mostrarModalProveedores(BuildContext context) {
  final List<Map<String, String>> proveedores = [
    {'nombre': 'Bosch Rexroth', 'tipo': 'Sistemas Hidráulicos', 'contacto': '+51 987 654 321', 'rawPhone': '+51987654321'},
    {'nombre': 'Enerpac', 'tipo': 'Herramientas Hidráulicas', 'contacto': '+51 912 345 678', 'rawPhone': '+51912345678'},
    {'nombre': 'Parker Hannifin', 'tipo': 'Mangueras y Conectores', 'contacto': '+51 923 456 789', 'rawPhone': '+51923456789'},
    {'nombre': 'Donaldson', 'tipo': 'Filtración Pesada', 'contacto': '+51 934 567 890', 'rawPhone': '+51934567890'},
    {'nombre': 'Festo', 'tipo': 'Componentes Neumáticos', 'contacto': '+51 945 678 901', 'rawPhone': '+51945678901'},
  ];

  Future<void> _llamarNumero(String numero, String nombre) async {
    const platform = MethodChannel('com.example.sgsra_mobile/telefono');
    try {
      await platform.invokeMethod('llamar', {'numero': numero});
    } catch (_) {
      // Fallback: copiar al portapapeles y avisar al usuario
      await Clipboard.setData(ClipboardData(text: numero));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Número de $nombre copiado al portapapeles: $numero'),
            backgroundColor: AppColors.primaryBlue,
          ),
        );
      }
    }
  }

  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.pureWhite,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.business_center_rounded, color: AppColors.primaryBlue, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Proveedores Homologados [RF27]',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Text(
              'Toque el botón del teléfono para abrir la aplicación de llamadas con el número cargado automáticamente.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: proveedores.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = proveedores[index];
                  final tel = item['rawPhone'] ?? item['contacto']!;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                      child: const Icon(Icons.business, color: AppColors.primaryBlue),
                    ),
                    title: Text(item['nombre']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    subtitle: Text('${item['tipo']}\nContacto: ${item['contacto']}'),
                    trailing: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      icon: const Icon(Icons.phone_in_talk_rounded, size: 16, color: Colors.white),
                      label: const Text('Llamar', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      onPressed: () => _llamarNumero(tel, item['nombre']!),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
