import 'package:flutter/material.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../notificaciones/presentation/widgets/notificacion_bell.dart';
import 'solicitudes_recuperacion_screen.dart';

/// [RF07, RF08, ADM-01, AUT-02] Gestión de personal.
/// - La edición guarda en el servidor y vuelve a leer la lista para confirmar el cambio.
/// - Muestra un aviso con las solicitudes de recuperación de contraseña pendientes.
class GestionPersonalScreen extends StatefulWidget {
  const GestionPersonalScreen({super.key});

  @override
  State<GestionPersonalScreen> createState() => _GestionPersonalScreenState();
}

class _GestionPersonalScreenState extends State<GestionPersonalScreen> {
  final DioClient _dioClient = DioClient();
  final TextEditingController _buscarCtrl = TextEditingController();
  bool _isLoading = true;
  List<dynamic> _usuarios = [];
  int _recuperacionesPendientes = 0;
  String _rolFiltro = 'TODOS';

  static const _roles = {'TODOS': 'Todos', 'MECANICO': 'Mecánicos', 'ALMACENISTA': 'Almacenistas', 'ADMINISTRADOR': 'Administradores'};

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    setState(() => _isLoading = true);
    try {
      final res = await _dioClient.dio.get('/auth/usuarios', queryParameters: {'size': 200, 'sort': 'nombre,asc'});
      List<dynamic> lista;
      if (res.data is Map && res.data['content'] != null) {
        lista = res.data['content'];
      } else if (res.data is List) {
        lista = res.data;
      } else {
        lista = [];
      }
      int pendientes = 0;
      try {
        final r = await _dioClient.dio.get('/auth/recuperaciones', queryParameters: {'estado': 'PENDIENTE'});
        if (r.data is List) pendientes = (r.data as List).length;
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _usuarios = lista;
        _recuperacionesPendientes = pendientes;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _mostrarMensaje('Error al sincronizar personal: ${mensajeDeError(e)}', esError: true);
    }
  }

  void _mostrarMensaje(String texto, {bool esError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: esError ? AppColors.errorRed : Colors.green[700]),
    );
  }

  Future<void> _cambiarEstado(String dni, bool habilitar) async {
    try {
      final nuevoEstado = habilitar ? 'ACTIVO' : 'INACTIVO';
      await _dioClient.dio.put('/auth/usuarios/dni/$dni/estado', queryParameters: {'nuevoEstado': nuevoEstado});
      _mostrarMensaje(habilitar ? 'Cuenta $dni habilitada' : 'Cuenta $dni deshabilitada');
      _cargarUsuarios();
    } catch (e) {
      _mostrarMensaje('Error al cambiar estado: ${mensajeDeError(e)}', esError: true);
    }
  }

  Future<void> _abrirRecuperaciones() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const SolicitudesRecuperacionScreen()));
    _cargarUsuarios();
  }

  void _abrirModalEditar(dynamic user) {
    final formKey = GlobalKey<FormState>();
    final nomCtrl = TextEditingController(text: user['nombre']);
    final telCtrl = TextEditingController(text: user['telefono']?.toString() ?? '');
    final tieneTelefono = user['rol'] != 'ADMINISTRADOR';
    bool guardando = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: const Text('Editar trabajador'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('DNI ${user['dni']}  ·  ${user['correoCorporativo']}',
                    style: const TextStyle(fontSize: 12.5, color: Colors.black54)),
                const SizedBox(height: 12),
                TextFormField(
                  controller: nomCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Nombre completo', prefixIcon: Icon(Icons.badge_outlined)),
                  validator: (v) => (v == null || v.trim().length < 3) ? 'Ingrese el nombre' : null,
                ),
                if (tieneTelefono)
                  TextFormField(
                    controller: telCtrl,
                    keyboardType: TextInputType.phone,
                    maxLength: 9,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono móvil (9 dígitos)',
                      prefixIcon: Icon(Icons.phone_android_rounded),
                      helperText: 'Se usa para validar la recuperación de contraseña',
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty || RegExp(r'^\d{9}$').hasMatch(v)) ? null : 'Debe tener 9 dígitos',
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: guardando ? null : () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white),
              onPressed: guardando
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setD(() => guardando = true);
                      try {
                        await _dioClient.dio.put('/auth/usuarios/dni/${user['dni']}', data: {
                          'nombre': nomCtrl.text.trim(),
                          if (tieneTelefono && telCtrl.text.trim().isNotEmpty) 'telefono': telCtrl.text.trim(),
                        });
                        if (ctx.mounted) Navigator.pop(ctx);
                        _mostrarMensaje('Datos de ${nomCtrl.text.trim()} guardados');
                        _cargarUsuarios();
                      } catch (e) {
                        setD(() => guardando = false);
                        _mostrarMensaje('No se guardaron los cambios: ${mensajeDeError(e)}', esError: true);
                      }
                    },
              child: guardando
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Guardar'),
            ),
          ],
        ),
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
                TextFormField(controller: dniCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'DNI (8 dígitos)'), validator: (v) => (v == null || v.length != 8) ? 'Requerido' : null),
                TextFormField(controller: nomCtrl, decoration: const InputDecoration(labelText: 'Nombre Completo'), validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null),
                TextFormField(controller: corCtrl, decoration: const InputDecoration(labelText: 'Correo (@masterdrilling.com)'), validator: (v) => (v == null || !v.endsWith('@masterdrilling.com')) ? 'Inválido' : null),
                TextFormField(controller: passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Contraseña'), validator: (v) => (v == null || v.length < 6) ? 'Mín. 6 caracteres' : null),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: rolSel,
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
                  _mostrarMensaje('Error al registrar usuario: ${mensajeDeError(e)}', esError: true);
                }
              }
            },
            child: const Text('Registrar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  List<dynamic> get _filtrados {
    final q = _buscarCtrl.text.trim().toLowerCase();
    return _usuarios.where((u) {
      if (_rolFiltro != 'TODOS' && u['rol'] != _rolFiltro) return false;
      if (q.isEmpty) return true;
      return '${u['nombre']} ${u['dni']} ${u['correoCorporativo']}'.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final lista = _filtrados;
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: const Text('Gestión de Personal [RF07, RF08]', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryBlue,
        actions: [
          const NotificacionBell(),
          IconButton(
            tooltip: 'Recuperación de contraseñas',
            onPressed: _abrirRecuperaciones,
            icon: Badge(
              isLabelVisible: _recuperacionesPendientes > 0,
              label: Text('$_recuperacionesPendientes'),
              child: const Icon(Icons.lock_reset_rounded),
            ),
          ),
          IconButton(icon: const Icon(Icons.person_add_alt_1_rounded), tooltip: 'Nuevo Usuario', onPressed: _abrirModalRegistrar),
          IconButton(icon: const Icon(Icons.refresh_rounded), tooltip: 'Actualizar', onPressed: _cargarUsuarios),
        ],
      ),
      body: Column(
        children: [
          if (_recuperacionesPendientes > 0)
            Material(
              color: Colors.amber[50],
              child: InkWell(
                onTap: _abrirRecuperaciones,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(children: [
                    Icon(Icons.lock_reset_rounded, color: Colors.amber[900]),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _recuperacionesPendientes == 1
                            ? '1 trabajador solicitó recuperar su contraseña'
                            : '$_recuperacionesPendientes trabajadores solicitaron recuperar su contraseña',
                        style: TextStyle(color: Colors.amber[900], fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text('Revisar', style: TextStyle(color: Colors.amber[900], fontWeight: FontWeight.bold)),
                    Icon(Icons.chevron_right_rounded, color: Colors.amber[900]),
                  ]),
                ),
              ),
            ),
          Container(
            color: AppColors.pureWhite,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: Column(children: [
              TextField(
                controller: _buscarCtrl,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre, DNI o correo',
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                  border: const OutlineInputBorder(),
                  suffixIcon: _buscarCtrl.text.isEmpty
                      ? null
                      : IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(_buscarCtrl.clear)),
                ),
              ),
              SizedBox(
                height: 46,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  children: _roles.entries.map((r) {
                    final sel = _rolFiltro == r.key;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(r.value),
                        selected: sel,
                        selectedColor: AppColors.primaryBlue,
                        labelStyle: TextStyle(color: sel ? Colors.white : Colors.black87),
                        onSelected: (_) => setState(() => _rolFiltro = r.key),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ]),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
                : RefreshIndicator(
                    onRefresh: _cargarUsuarios,
                    child: lista.isEmpty
                        ? ListView(children: const [
                            SizedBox(height: 80),
                            Center(child: Text('No se encontraron trabajadores.')),
                          ])
                        : ListView.builder(
                            padding: const EdgeInsets.all(14),
                            itemCount: lista.length,
                            itemBuilder: (context, index) => _tarjeta(lista[index]),
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _tarjeta(dynamic user) {
    final estado = user['estadoCuenta'] ?? 'ACTIVO';
    final estaActivo = estado == 'ACTIVO';
    final bloqueado = estado == 'BLOQUEADO';
    final foto = ApiService.urlRecurso(user['fotoPerfilUrl']?.toString());
    final rol = user['rol']?.toString() ?? '';
    final estadoColor = estaActivo ? Colors.green[700]! : (bloqueado ? AppColors.errorRed : Colors.grey);

    return Card(
      color: AppColors.pureWhite,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: estaActivo ? AppColors.primaryBlue : Colors.grey,
              backgroundImage: foto.isEmpty ? null : NetworkImage(foto),
              child: foto.isEmpty
                  ? Text(rol.isNotEmpty ? rol[0] : 'U', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${user['nombre']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text('DNI ${user['dni']}  ·  ${user['correoCorporativo']}',
                      style: const TextStyle(fontSize: 12, color: Colors.black54), overflow: TextOverflow.ellipsis),
                  if ((user['telefono'] ?? '').toString().isNotEmpty)
                    Text('Tel. ${user['telefono']}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  const SizedBox(height: 6),
                  Wrap(spacing: 6, children: [
                    _pill(rol, AppColors.primaryBlue),
                    _pill(estado, estadoColor),
                  ]),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.primaryBlue),
                  tooltip: 'Editar',
                  onPressed: () => _abrirModalEditar(user),
                ),
                Switch(
                  value: estaActivo,
                  activeThumbColor: AppColors.primaryBlue,
                  onChanged: (val) => _cambiarEstado(user['dni'], val),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String t, Color c) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
        child: Text(t, style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.bold)),
      );
}
