import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/presentation/screens/login_screen.dart';

class PerfilMecanicoScreen extends StatefulWidget {
  const PerfilMecanicoScreen({Key? key}) : super(key: key);

  @override
  State<PerfilMecanicoScreen> createState() => _PerfilMecanicoScreenState();
}

class _PerfilMecanicoScreenState extends State<PerfilMecanicoScreen> {
  final DioClient _dioClient = DioClient();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController(text: 'Carlos Baro');
  final _telefonoCtrl = TextEditingController(text: '987112233');
  String _correo = 'carlos.baro@masterdrilling.com';
  String _dni = '70000001';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final c = await _storage.read(key: 'correo_usuario');
    final d = await _storage.read(key: 'dni_usuario');
    if (c != null && c.isNotEmpty) _correo = c;
    if (d != null && d.isNotEmpty) _dni = d;
    setState(() {});
  }

  Future<void> _actualizarPerfil() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _dioClient.dio.put(
          '/auth/perfil',
          queryParameters: {'correo': _correo},
          data: {
            'nombre': _nombreCtrl.text.trim(),
            'telefono': _telefonoCtrl.text.trim(),
          },
        );
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil de operario actualizado exitosamente [RF07]'), backgroundColor: AppColors.primaryBlue),
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
        title: const Text('Mi Perfil [RF07]', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryBlue,
        actions: [
          IconButton(icon: const Icon(Icons.logout_rounded), onPressed: _cerrarSesion),
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
                        child: Icon(Icons.person, size: 48, color: Colors.white),
                      ),
                      const SizedBox(height: 14),
                      Text('DNI: $_dni', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(_correo, style: const TextStyle(color: Colors.grey)),
                      const Text('Especialidad: Mantenimiento Mina', style: TextStyle(color: Colors.black54, fontSize: 13)),
                      const Divider(height: 30),
                      TextFormField(
                        controller: _nombreCtrl,
                        decoration: const InputDecoration(labelText: 'Nombre Completo', border: OutlineInputBorder()),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _telefonoCtrl,
                        keyboardType: TextInputType.phone,
                        maxLength: 9,
                        decoration: const InputDecoration(labelText: 'Telefono Movil (9 digitos)', border: OutlineInputBorder(), counterText: ''),
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
                              : const Text('Actualizar Informacion [RF07]', style: TextStyle(color: Colors.white)),
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