import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/services/api_service.dart';

class GestionPersonalTab extends StatefulWidget {
  const GestionPersonalTab({super.key});

  @override
  State<GestionPersonalTab> createState() => _GestionPersonalTabState();
}

class _GestionPersonalTabState extends State<GestionPersonalTab> {
  final ApiService _apiService = ApiService();
  List<dynamic> _usuarios = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    setState(() => _cargando = true);
    try {
      final res = await _apiService.listarUsuarios();
      if (mounted) {
        List<dynamic> lista = [];
        if (res.data is List) {
          lista = res.data;
        } else if (res.data is Map && res.data['content'] != null) {
          lista = res.data['content'] as List;
        }
        setState(() {
          _usuarios = lista;
          _cargando = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _modalFormularioUsuario({Map<String, dynamic>? usuario}) {
    final bool esEdicion = usuario != null;
    final formKey = GlobalKey<FormState>();
    final dniCtrl = TextEditingController(text: esEdicion ? (usuario['dni'] ?? '') : '');
    final nombreCtrl = TextEditingController(text: esEdicion ? (usuario['nombre'] ?? '') : '');
    final correoCtrl = TextEditingController(text: esEdicion ? (usuario['correoCorporativo'] ?? '') : '');
    final passCtrl = TextEditingController(text: "Mecanico123*");
    String rolSeleccionado = esEdicion ? (usuario['rol'] ?? 'MECANICO') : "MECANICO";

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (contextDialog, setModalState) => AlertDialog(
          title: Text(esEdicion ? "Editar Personal" : "Registrar Nuevo Personal",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: dniCtrl,
                    enabled: !esEdicion,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(8),
                    ],
                    decoration: const InputDecoration(
                      labelText: "DNI (8 digitos exactos)",
                      prefixIcon: Icon(Icons.badge),
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) => val == null || val.trim().length != 8 ? "DNI debe tener 8 digitos" : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: nombreCtrl,
                    decoration: const InputDecoration(
                      labelText: "Nombre Completo",
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? "Ingrese nombre completo" : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: correoCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "Correo Corporativo",
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) {
                      if (val == null || !val.contains('@masterdrilling.com')) {
                        return "Use el dominio @masterdrilling.com";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: rolSeleccionado,
                    decoration: const InputDecoration(
                      labelText: "Rol Asignado",
                      prefixIcon: Icon(Icons.security),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: "MECANICO", child: Text("Mecanico de Planta")),
                      DropdownMenuItem(value: "ALMACENISTA", child: Text("Almacenista de Panol")),
                      DropdownMenuItem(value: "ADMINISTRADOR", child: Text("Jefe de Taller / Administrador")),
                    ],
                    onChanged: (val) => setModalState(() => rolSeleccionado = val!),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1)),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final messenger = ScaffoldMessenger.of(context);
                  Navigator.pop(ctx);
                  setState(() => _cargando = true);
                  try {
                    if (esEdicion) {
                      await _apiService.actualizarUsuario(usuario['idUsuario'], {
                        'nombre': nombreCtrl.text.trim(),
                        'correoCorporativo': correoCtrl.text.trim(),
                        'rol': rolSeleccionado,
                      });
                      messenger.showSnackBar(const SnackBar(content: Text("Usuario actualizado con exito")));
                    } else {
                      await _apiService.crearUsuario({
                        'dni': dniCtrl.text.trim(),
                        'nombre': nombreCtrl.text.trim(),
                        'correoCorporativo': correoCtrl.text.trim(),
                        'contrasena': passCtrl.text.trim(),
                        'rol': rolSeleccionado,
                      });
                      messenger.showSnackBar(const SnackBar(content: Text("Usuario registrado exitosamente")));
                    }
                    _cargarUsuarios();
                  } catch (_) {
                    if (mounted) setState(() => _cargando = false);
                    messenger.showSnackBar(const SnackBar(content: Text("Error al procesar usuario")));
                  }
                }
              },
              child: const Text("Guardar"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestion de Personal Operativo"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _cargarUsuarios),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF0D47A1),
        onPressed: () => _modalFormularioUsuario(),
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text("Nuevo Personal", style: TextStyle(color: Colors.white)),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _usuarios.isEmpty
              ? const Center(child: Text("No se registran usuarios."))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _usuarios.length,
                  itemBuilder: (context, idx) {
                    final u = _usuarios[idx];
                    final estado = u['estadoCuenta'] ?? 'ACTIVO';
                    final bool activo = estado == 'ACTIVO';

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: activo ? Colors.blue.shade100 : Colors.red.shade100,
                          child: Icon(
                            u['rol'] == 'ADMINISTRADOR'
                                ? Icons.manage_accounts
                                : (u['rol'] == 'ALMACENISTA' ? Icons.store : Icons.build),
                            color: activo ? const Color(0xFF0D47A1) : Colors.red,
                          ),
                        ),
                        title: Text("${u['nombre']} (DNI: ${u['dni']})", style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${u['correoCorporativo']}\nRol: ${u['rol']} · Estado: $estado"),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blueGrey),
                              onPressed: () => _modalFormularioUsuario(usuario: u),
                              tooltip: "Editar personal",
                            ),
                            Switch(
                              value: activo,
                              activeThumbColor: const Color(0xFF2E7D32),
                              onChanged: (val) async {
                                final nuevoEstado = val ? "ACTIVO" : "INACTIVO";
                                await _apiService.cambiarEstadoUsuario(u['idUsuario'], nuevoEstado);
                                _cargarUsuarios();
                              },
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