import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/dio_client.dart';

class GestionPersonalScreen extends StatefulWidget {
  const GestionPersonalScreen({Key? key}) : super(key: key);

  @override
  State<GestionPersonalScreen> createState() => _GestionPersonalScreenState();
}

class _GestionPersonalScreenState extends State<GestionPersonalScreen> {
  final DioClient _dioClient = DioClient();
  bool _isLoading = true;
  List<dynamic> _usuarios = [];

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    setState(() => _isLoading = true);
    try {
      final res = await _dioClient.dio.get('/auth/usuarios', queryParameters: {'size': 50});
      setState(() {
        if (res.data is Map && res.data['content'] != null) {
          _usuarios = res.data['content'];
        } else if (res.data is List) {
          _usuarios = res.data;
        } else {
          _usuarios = [];
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _mostrarMensaje('Error al sincronizar personal: $e', esError: true);
    }
  }

  void _mostrarMensaje(String texto, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: esError ? AppColors.errorRed : AppColors.primaryBlue),
    );
  }

  Future<void> _cambiarEstado(String dni, bool habilitar) async {
    try {
      final nuevoEstado = habilitar ? 'ACTIVO' : 'INACTIVO';
      await _dioClient.dio.put('/auth/usuarios/dni/$dni/estado', queryParameters: {'nuevoEstado': nuevoEstado});
      _mostrarMensaje('Estado de usuario $dni actualizado a $nuevoEstado');
      _cargarUsuarios();
    } catch (e) {
      _mostrarMensaje('Error al cambiar estado: $e', esError: true);
    }
  }

  void _abrirModalEditar(dynamic user) {
    final formKey = GlobalKey<FormState>();
    final nomCtrl = TextEditingController(text: user['nombre']);
    final telCtrl = TextEditingController(text: '987654321');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Editar Trabajador (DNI: ${user['dni']}) [RF07]'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(controller: nomCtrl, decoration: const InputDecoration(labelText: 'Nombre Completo')),
              TextFormField(controller: telCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Teléfono Móvil (9 dígitos)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _dioClient.dio.put('/auth/usuarios/dni/${user['dni']}', data: {
                  'nombre': nomCtrl.text.trim(),
                  'telefono': telCtrl.text.trim(),
                });
                _mostrarMensaje('Datos de operario actualizados');
                _cargarUsuarios();
              } catch (e) {
                _mostrarMensaje('Error al actualizar datos: $e', esError: true);
              }
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _abrirModalRegistrar() {
    final formKey = GlobalKey<FormState>();
    final dniCtrl = TextEditingController();
    final nomCtrl = TextEditingController();
    final corCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    String rolSel = 'MECANICO';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Registrar Nuevo Personal [RF08]'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(controller: dniCtrl, decoration: const InputDecoration(labelText: 'DNI (8 dígitos)'), validator: (v) => (v == null || v.length != 8) ? 'Requerido' : null),
                TextFormField(controller: nomCtrl, decoration: const InputDecoration(labelText: 'Nombre Completo'), validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null),
                TextFormField(controller: corCtrl, decoration: const InputDecoration(labelText: 'Correo (@masterdrilling.com)'), validator: (v) => (v == null || !v.endsWith('@masterdrilling.com')) ? 'Inválido' : null),
                TextFormField(controller: passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Contraseña'), validator: (v) => (v == null || v.length < 6) ? 'Mín. 6 caracteres' : null),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: rolSel,
                  decoration: const InputDecoration(labelText: 'Rol Asignado'),
                  items: const [
                    DropdownMenuItem(value: 'MECANICO', child: Text('Mecánico')),
                    DropdownMenuItem(value: 'ALMACENISTA', child: Text('Almacenista')),
                    DropdownMenuItem(value: 'ADMINISTRADOR', child: Text('Administrador')),
                  ],
                  onChanged: (val) => rolSel = val ?? 'MECANICO',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx);
                try {
                  await _dioClient.dio.post('/auth/usuarios', data: {
                    'dni': dniCtrl.text.trim(),
                    'nombre': nomCtrl.text.trim(),
                    'correoCorporativo': corCtrl.text.trim(),
                    'contrasena': passCtrl.text.trim(),
                    'rol': rolSel,
                    'especialidad': 'Mantenimiento Pesado',
                    'cargo': 'Técnico Operativo',
                    'sedeAsignada': 'Sede Lurin',
                  });
                  _mostrarMensaje('Usuario registrado exitosamente');
                  _cargarUsuarios();
                } catch (e) {
                  _mostrarMensaje('Error al registrar usuario: $e', esError: true);
                }
              }
            },
            child: const Text('Registrar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: const Text('Gestión de Personal [RF07, RF08]', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryBlue,
        actions: [
          IconButton(icon: const Icon(Icons.person_add_alt_1_rounded), tooltip: 'Nuevo Usuario', onPressed: _abrirModalRegistrar),
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _cargarUsuarios),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
          : _usuarios.isEmpty
              ? const Center(child: Text('No hay cuentas de operarios en la base de datos.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: _usuarios.length,
                  itemBuilder: (context, index) {
                    final user = _usuarios[index];
                    final estado = user['estadoCuenta'] ?? 'ACTIVO';
                    final estaActivo = estado == 'ACTIVO';

                    return Card(
                      color: AppColors.pureWhite,
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: estaActivo ? AppColors.primaryBlue : Colors.grey,
                          child: Text(user['rol']?[0] ?? 'U', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        title: Text('${user['nombre']} (DNI: ${user['dni']})', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Correo: ${user['correoCorporativo']}\nRol: ${user['rol']} | Estado: $estado'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.edit, color: AppColors.primaryBlue), onPressed: () => _abrirModalEditar(user)),
                            Switch(
                              value: estaActivo,
                              activeColor: AppColors.primaryBlue,
                              onChanged: (val) => _cambiarEstado(user['dni'], val),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
    );
  }
}