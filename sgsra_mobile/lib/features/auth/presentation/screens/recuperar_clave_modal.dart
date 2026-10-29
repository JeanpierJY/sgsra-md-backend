import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';

/// [RF04] Modal para solicitud de recuperación de contraseña vía correo corporativo
void mostrarModalRecuperarClave(BuildContext context) {
  final formKey = GlobalKey<FormState>();
  final correoController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Recuperar Contraseña [RF04]'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ingrese su correo corporativo registrado para recibir instrucciones.'),
            const SizedBox(height: 16),
            TextFormField(
              controller: correoController,
              decoration: const InputDecoration(labelText: 'Correo Corporativo'),
              validator: AppValidators.validarCorreo,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
          onPressed: () {
            if (formKey.currentState!.validate()) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Instrucciones enviadas a su correo.')),
              );
            }
          },
          child: const Text('Enviar'),
        ),
      ],
    ),
  );
}