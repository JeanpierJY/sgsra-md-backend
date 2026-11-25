import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/constants/app_colors.dart';

/// [H-ALM-10] Muestra el código QR de una herramienta.
///
/// El QR contiene SOLO el código (p. ej. "HER-PIST-003"), que es exactamente lo que el
/// escáner de la pestaña Retorno busca. Sirve para mostrarlo en pantalla, tomar una
/// captura o comprobar que la etiqueta impresa es correcta.
Future<void> mostrarQrHerramienta(BuildContext context, String codigo, String nombre) {
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Código QR', textAlign: TextAlign.center),
      content: SizedBox(
        width: 260,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(8),
              child: QrImageView(
                data: codigo,
                version: QrVersions.auto,
                size: 220,
                errorCorrectionLevel: QrErrorCorrectLevel.M,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(codigo,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1, color: AppColors.primaryBlue)),
            const SizedBox(height: 4),
            Text(nombre, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Colors.black54)),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
      ],
    ),
  );
}
