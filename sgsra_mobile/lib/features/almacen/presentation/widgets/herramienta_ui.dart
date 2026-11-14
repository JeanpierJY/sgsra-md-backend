import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/imagen_producto.dart';
import '../../domain/entities/almacen_entities.dart';

/// Normaliza el estado del backend ("En Mora", "EN_MORA"...) a una clave: EN_MORA
String claveEstadoHerramienta(String e) => e.trim().toUpperCase().replaceAll(' ', '_');

Color colorEstadoHerramienta(String e) => switch (claveEstadoHerramienta(e)) {
      'DISPONIBLE' => Colors.green[700]!,
      'PRESTADA' => AppColors.primaryBlue,
      'EN_MORA' => Colors.orange[800]!,
      'EN_MANTENIMIENTO' => Colors.amber[900]!,
      'EXTRAVIADA' => AppColors.errorRed,
      _ => Colors.grey[700]!,
    };

String etiquetaEstadoHerramienta(String e) => switch (claveEstadoHerramienta(e)) {
      'DISPONIBLE' => 'Disponible',
      'PRESTADA' => 'Prestada',
      'EN_MORA' => 'En mora',
      'EN_MANTENIMIENTO' => 'Mantenimiento',
      'EXTRAVIADA' => 'Extraviada',
      'BAJA_TECNICA' => 'De baja',
      _ => e,
    };

class EstadoHerramientaPill extends StatelessWidget {
  final String estado;
  const EstadoHerramientaPill(this.estado, {super.key});

  @override
  Widget build(BuildContext context) {
    final c = colorEstadoHerramienta(estado);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(etiquetaEstadoHerramienta(estado),
          style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 11.5)),
    );
  }
}

/// Fila de herramienta con foto, nombre, código, marca y estado
class FilaHerramienta extends StatelessWidget {
  final HerramientaEntity h;
  final Widget? trailing;
  final double tamanoImagen;
  const FilaHerramienta(this.h, {super.key, this.trailing, this.tamanoImagen = 52});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      ImagenProducto(url: h.imagenUrl, size: tamanoImagen, iconoVacio: Icons.handyman_outlined,
          color: colorEstadoHerramienta(h.estadoActual)),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(h.nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text('${h.codHerramienta}  ·  ${h.marca}',
              style: const TextStyle(fontSize: 12, color: Colors.black54), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 3),
          EstadoHerramientaPill(h.estadoActual),
        ]),
      ),
      if (trailing != null) trailing!,
    ]);
  }
}
