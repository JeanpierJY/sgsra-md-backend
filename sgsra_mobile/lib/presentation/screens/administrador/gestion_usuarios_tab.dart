import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/usuarios/usuarios_bloc.dart';
import '../../bloc/usuarios/usuarios_event.dart';
import '../../bloc/usuarios/usuarios_state.dart';

class GestionUsuariosTab extends StatefulWidget {
  const GestionUsuariosTab({super.key});

  @override
  State<GestionUsuariosTab> createState() => _GestionUsuariosTabState();
}

class _GestionUsuariosTabState extends State<GestionUsuariosTab> {
  @override
  void initState() {
    super.initState();
    context.read<UsuariosBloc>().add(FetchUsuariosRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<UsuariosBloc, UsuariosState>(
        builder: (context, state) {
          if (state is UsuariosLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF0D47A1)));
          }
          if (state is UsuariosLoaded && state.usuarios.isNotEmpty) {
            return ListView.builder(
              itemCount: state.usuarios.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final user = state.usuarios[index];
                return Card(
                  child: ListTile(
                    title: Text(user.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${user.rol} • DNI: ${user.dni}\n${user.correoCorporativo}"),
                    trailing: Switch(
                      value: user.estadoCuenta == 'ACTIVO',
                      onChanged: (v) {
                        if (user.idUsuario != null) {
                          context.read<UsuariosBloc>().add(ToggleEstadoUsuarioRequested(user.idUsuario!, v ? 'ACTIVO' : 'INACTIVO'));
                        }
                      },
                    ),
                  ),
                );
              },
            );
          }
          // Estado Inicial Vacío desde cero
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.supervised_user_circle_outlined, size: 48, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    "No se registran operarios en la nómina local.\nUtilice el botón flotante para conceder altas.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
