import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/validators.dart';
import '../../../notificaciones/presentation/widgets/notificacion_bell.dart';
import 'solicitudes_recuperacion_screen.dart';
import '../../../../core/widgets/perfil_boton.dart';

/// [RF07, RF08, ADM-01, AUT-02] Gestión de personal.
/// - La edición guarda en el servidor y vuelve a leer la lista para confirmar el cambio.
/// - Muestra un aviso con las solicitudes de recuperación de contraseña pendientes.
/// - Validación estricta de nombres (solo letras) y teléfonos (9 dígitos iniciando en 9).
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

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  @override
  void dispose() {
    _buscarCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarUsuarios() async {
    setState(() => _isLoading = true);
    try {
      final res = await _dioClient.dio.get('/auth/usuarios');
      final recRes = await _dioClient.dio.get('/auth/recuperaciones', queryParameters: {'estado': 'PENDIENTE'});
      final recList = recRes.data is List ? (recRes.data as List) : [];
      List<dynamic> usuariosList = [];
      if (res.data is List) {
        usuariosList = res.data as List;
      } else if (res.data is Map && res.data['content'] is List) {
        usuariosList = res.data['content'] as List;
      }
      setState(() {
        _usuarios = usuariosList;
        _recuperacionesPendientes = recList.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _mostrarMensaje('Error al cargar personal: ${mensajeDeError(e)}', esError: true);
    }
  }

  void _mostrarMensaje(String texto, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: esError ? AppColors.errorRed : AppColors.primaryBlue),
    );
  }

  Future<void> _cambiarEstado(String dni, bool activo) async {
    try {
      await _dioClient.dio.put('/auth/usuarios/dni/$dni/estado', queryParameters: {
        'nuevoEstado': activo ? 'ACTIVO' : 'INACTIVO',
      });
      _mostrarMensaje('Estado actualizado');
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
          title: const Text('Editar trabajador', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]'))],
                  decoration: const InputDecoration(labelText: 'Nombre completo (solo letras)', prefixIcon: Icon(Icons.badge_outlined)),
                  validator: AppValidators.validarNombre,
                ),
                if (tieneTelefono)
                  TextFormField(
                    controller: telCtrl,
                    keyboardType: TextInputType.phone,
                    maxLength: 9,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(9),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Teléfono móvil (9 dígitos, inicia en 9)',
                      prefixIcon: Icon(Icons.phone_android_rounded),
                      helperText: 'Debe iniciar con 9 y tener 9 dígitos',
                      counterText: '',
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? null : AppValidators.validarTelefono(v),
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
    bool verPass = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
        title: const Text('Añadir Usuario', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: dniCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 8,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(8),
                  ],
                  decoration: const InputDecoration(labelText: 'DNI (8 dígitos)', counterText: ''),
                  validator: AppValidators.validarDni,
                ),
                TextFormField(
                  controller: nomCtrl,
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]'))],
                  decoration: const InputDecoration(labelText: 'Nombre Completo (solo letras)'),
                  validator: AppValidators.validarNombre,
                ),
                TextFormField(
                  controller: corCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Correo (@masterdrilling.com)'),
                  validator: AppValidators.validarCorreo,
                ),
                TextFormField(
                  controller: passCtrl,
                  // [H-GEN-09] Botón para mostrar/ocultar la contraseña
                  obscureText: !verPass,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    suffixIcon: IconButton(
                      icon: Icon(verPass ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                      tooltip: verPass ? 'Ocultar contraseña' : 'Ver contraseña',
                      onPressed: () => setDlg(() => verPass = !verPass),
                    ),
                  ),
                  validator: (v) => (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
                ),
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
                  _mostrarMensaje('No se pudo registrar el usuario: ${mensajeDeError(e)}', esError: true);
                }
              }
            },
            child: const Text('Registrar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
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
        title: const Text('Gestión de Personal', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryBlue,
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), tooltip: 'Actualizar', onPressed: _cargarUsuarios),
          const NotificacionBell(),
          const PerfilBoton(),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Badge(
            isLabelVisible: _recuperacionesPendientes > 0,
            label: Text('$_recuperacionesPendientes'),
            child: FloatingActionButton.extended(
              heroTag: 'fab-recuperacion',
              backgroundColor: AppColors.pureWhite,
              foregroundColor: Colors.amber[900],
              elevation: 3,
              onPressed: _abrirRecuperaciones,
              icon: Icon(Icons.lock_reset_rounded, color: Colors.amber[900], size: 20),
              label: Text('Recuperar contraseña',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.amber[900])),
            ),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: 'fab-anadir-usuario',
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            elevation: 4,
            onPressed: _abrirModalRegistrar,
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: const Text('Añadir usuario', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
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
                  children: [
                    _filtroChip('TODOS', 'Todos (${_usuarios.length})'),
                    _filtroChip('MECANICO', 'Mecánicos'),
                    _filtroChip('ALMACENISTA', 'Almacén'),
                    _filtroChip('ADMINISTRADOR', 'Administradores'),
                  ],
                ),
              ),
            ]),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
                : lista.isEmpty
                    ? const Center(child: Text('No se encontraron trabajadores.'))
                    : RefreshIndicator(
                        onRefresh: _cargarUsuarios,
                        child: ListView.builder(
                          // [H-ADM-04] Espacio inferior para que los dos FAB apilados no tapen
                          // el switch de activar/desactivar de las últimas tarjetas
                          padding: const EdgeInsets.fromLTRB(14, 14, 14, 170),
                          itemCount: lista.length,
                          itemBuilder: (context, index) => _tarjeta(lista[index]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _filtroChip(String rol, String label) {
    final sel = _rolFiltro == rol;
    return Padding(
      padding: const EdgeInsets.only(right: 6, top: 6, bottom: 6),
      child: FilterChip(
        selected: sel,
        label: Text(label),
        selectedColor: AppColors.primaryBlue.withValues(alpha: 0.15),
        labelStyle: TextStyle(
          color: sel ? AppColors.primaryBlue : Colors.black87,
          fontWeight: sel ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        onSelected: (_) => setState(() => _rolFiltro = rol),
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
