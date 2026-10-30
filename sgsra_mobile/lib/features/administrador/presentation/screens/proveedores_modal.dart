import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// [RF27] Enlaces a proveedores homologados (Bosch Rexroth, Enerpac, Parker, Donaldson, Festo)
void mostrarModalProveedores(BuildContext context) {
  final List<Map<String, String>> proveedores = [
    {'nombre': 'Bosch Rexroth', 'tipo': 'Sistemas Hidráulicos', 'contacto': '+51 987 654 321'},
    {'nombre': 'Enerpac', 'tipo': 'Herramientas Hidráulicas', 'contacto': '+51 912 345 678'},
    {'nombre': 'Parker Hannifin', 'tipo': 'Mangueras y Conectores', 'contacto': '+51 923 456 789'},
    {'nombre': 'Donaldson', 'tipo': 'Filtración Pesada', 'contacto': '+51 934 567 890'},
    {'nombre': 'Festo', 'tipo': 'Componentes Neumáticos', 'contacto': '+51 945 678 901'},
  ];

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
            const Text(
              'Proveedores Homologados [RF27]',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: proveedores.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final item = proveedores[index];
                  return ListTile(
                    leading: const Icon(Icons.business, color: AppColors.primaryBlue),
                    title: Text(item['nombre']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${item['tipo']}\nContacto: ${item['contacto']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.phone, color: AppColors.iconBlack),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Contactando a ${item['nombre']}...')),
                        );
                      },
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