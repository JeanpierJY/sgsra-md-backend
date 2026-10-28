import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/usuario_model.dart';
import '../../bloc/usuarios/usuarios_bloc.dart';
import '../../bloc/usuarios/usuarios_event.dart';
import '../../bloc/usuarios/usuarios_state.dart';

class GestionUsuariosContent extends StatefulWidget {
  const GestionUsuariosContent({super.key});

  @override
  State<GestionUsuariosContent> createState() => _GestionUsuariosContentState();
}

class _GestionUsuariosContentState extends State<GestionUsuariosContent> {
  final _formKey = GlobalKey<FormState>();
  final _dniController = TextEditingController();
  final _nombreController = TextEditingController();
  final _correoController = TextEditingController();
  String _rolSeleccionado = 'MECANICO';

  @override
  void initState() {
    super.initState();
    context.read<UsuariosBloc>().add(FetchUsuariosRequested());
  }

  void _desplegarFormularioAlta() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text("Alta de Operario", style: TextStyle(color: Color(0xFFFFB300))),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _dniController,
                    decoration: const InputDecoration(labelText: "DNI (8 dígitos)"),
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || v.length != 8) ? 'Largo inválido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(labelText: "Nombre Completo"),
                    validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _correoController,
                    decoration: const InputDecoration(labelText: "Correo Corporativo"),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => (v == null || !v.contains('@masterdrilling.com')) ? 'Formato inválido' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _rolSeleccionado,
                    decoration: const InputDecoration(labelText: "Rol"),
                    items: ['MECANICO', 'ALMACENISTA', 'ADMINISTRADOR']
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                    onChanged: (v) => setState(() => _rolSeleccionado = v!),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCELAR")),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final nuevoUsuario = UsuarioModel(
                    dni: _dniController.text.trim(),
                    nombre: _nombreController.text.trim(),
                    correoCorporativo: _correoController.text.trim().toLowerCase(),
                    rol: _rolSeleccionado,
                    estadoCuenta: 'ACTIVO',
                    intentosFallidos: 0,
                  );
                  context.read<UsuariosBloc>().add(CreateUsuarioRequested(nuevoUsuario));
                  Navigator.pop(context);
                }
              },
              child: const Text("GUARDAR"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gestión de Personal")),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFFB300),
        onPressed: _desplegarFormularioAlta,
        child: const Icon(Icons.person_add, color: Colors.black),
      ),
      body: BlocConsumer<UsuariosBloc, UsuariosState>(
        listener: (context, state) {
          if (state is UsuariosActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.msg), backgroundColor: Colors.green));
          } else if (state is UsuariosFailure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error), backgroundColor: Colors.red));
          }
        },
        builder: (context, state) {
          if (state is UsuariosLoading) return const Center(child: CircularProgressIndicator(color: Color(0xFFFFB300)));
          if (state is UsuariosLoaded) {
            return ListView.builder(
              itemCount: state.usuarios.length,
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final user = state.usuarios[index];
                final bool esActivo = user.estadoCuenta == 'ACTIVO';
                return Card(
                  color: const Color(0xFF1E1E1E),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(user.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Rol: ${user.rol} | DNI: ${user.dni}\n${user.correoCorporativo}"),
                    trailing: Switch(
                      value: esActivo,
                      activeColor: const Color(0xFFFFB300),
                      onChanged: (value) {
                        if (user.idUsuario != null) {
                          context.read<UsuariosBloc>().add(ToggleEstadoUsuarioRequested(
                            user.idUsuario!,
                            value ? 'ACTIVO' : 'INACTIVO',
                          ));
                        }
                      },
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: Text("Sin registros"));
        },
      ),
    );
  }
}