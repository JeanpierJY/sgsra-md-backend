import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sgsra_mobile/features/auth/presentation/screens/login_screen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/dio_client.dart';

class PerfilAdminScreen extends StatefulWidget {
  const PerfilAdminScreen({Key? key}) : super(key: key);

  @override
  State<PerfilAdminScreen> createState() => _PerfilAdminScreenState();
}

class _PerfilAdminScreenState extends State<PerfilAdminScreen> {
  final DioClient _dioClient = DioClient();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController(text: 'Leao Chura');
  final _telefonoCtrl = TextEditingController(text: '984123456');
  String _correoAdmin = 'leao.chura@masterdrilling.com';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final correo = await _storage.read(key: 'correo_admin');
    if (correo != null && correo.isNotEmpty) {
      setState(() {
        _correoAdmin = correo;
      });
    }
  }

  Future<void> _actualizarPerfil() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _dioClient.dio.put(
          '/auth/perfil',
          queryParameters: {'correo': _correoAdmin},
          data: {
            'nombre': _nombreCtrl.text.trim(),
            'telefono': _telefonoCtrl.text.trim(),
          },
        );
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil de jefatura actualizado exitosamente [RF07]'), backgroundColor: AppColors.primaryBlue),
        );
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e'), backgroundColor: AppColors.errorRed),
        );
      }
    }
  }

  Future<void> _cerrarSesion() async {
    await _storage.deleteAll();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: const Text('Mi Perfil de Administrador [RF07]', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Cerrar Sesion [RF03]',
            onPressed: _cerrarSesion,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 550),
            child: Card(
              color: AppColors.pureWhite,
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 42,
                        backgroundColor: AppColors.primaryBlue,
                        child: Icon(Icons.manage_accounts_rounded, size: 48, color: Colors.white),
                      ),
                      const SizedBox(height: 14),
                      Text(_correoAdmin, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const Text('Jefatura / Administrador de Taller Mina', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      const Divider(height: 30),
                      TextFormField(
                        controller: _nombreCtrl,
                        decoration: const InputDecoration(labelText: 'Nombre del Responsable', border: OutlineInputBorder()),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _telefonoCtrl,
                        keyboardType: TextInputType.phone,
                        maxLength: 9,
                        decoration: const InputDecoration(labelText: 'Telefono Movil Corporativo (9 digitos)', border: OutlineInputBorder(), counterText: ''),
                        validator: (v) => (v == null || v.trim().length != 9) ? 'Debe contener 9 digitos' : null,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
                          onPressed: _isLoading ? null : _actualizarPerfil,
                          icon: _isLoading ? const SizedBox.shrink() : const Icon(Icons.save_rounded, color: Colors.white),
                          label: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Guardar Informacion [RF07]', style: TextStyle(color: Colors.white, fontSize: 15)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(foregroundColor: AppColors.errorRed, side: const BorderSide(color: AppColors.errorRed)),
                          onPressed: _cerrarSesion,
                          icon: const Icon(Icons.exit_to_app_rounded),
                          label: const Text('Cerrar Sesion Institucional [RF03]'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}