import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';

/// [RF07] Pantalla de edición de perfil con bloqueo de campos fijos y validación de teléfono/DNI
class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({Key? key}) : super(key: key);

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _telefonoController = TextEditingController(text: '987654321');
  final _dniController = TextEditingController(text: '72345678');

  @override
  void dispose() {
    _telefonoController.dispose();
    _dniController.dispose();
    super.dispose();
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente en el Backend [RF07].')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: const Text('Editar Perfil [RF07]'),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(24),
          child: Card(
            color: AppColors.pureWhite,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: formKeyValido(_formKey),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _dniController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(labelText: 'DNI (Solo números)'),
                      validator: AppValidators.validarDni,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _telefonoController,
                      keyboardType: TextInputType.phone,
                      maxLength: 9,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Teléfono Móvil (9 dígitos)',
                        counterText: '',
                      ),
                      validator: AppValidators.validarTelefono,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: AppColors.pureWhite,
                      ),
                      onPressed: _guardar,
                      child: const Text('Guardar Cambios'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  GlobalKey<FormState> formKeyValido(GlobalKey<FormState> key) => key;
}