import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/session/session_manager.dart';

/// [AUT-02] Bandeja de recuperación de contraseña para el Administrador.
/// Compara la selfie enviada con la foto de perfil registrada y permite
/// aprobar (asignando una clave temporal) o rechazar con motivo.
class SolicitudesRecuperacionScreen extends StatefulWidget {
  const SolicitudesRecuperacionScreen({super.key});

  @override
  State<SolicitudesRecuperacionScreen> createState() => _SolicitudesRecuperacionScreenState();
}

class _SolicitudesRecuperacionScreenState extends State<SolicitudesRecuperacionScreen> {
  final DioClient _dio = DioClient();
  bool _cargando = true;
  String? _error;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final res = await _dio.dio.get('/auth/recuperaciones');
      final lista = (res.data as List).map((e) => Map<String, dynamic>.from(e)).toList()
        ..sort((a, b) => '${b['fechaSolicitud']}'.compareTo('${a['fechaSolicitud']}'));
      if (!mounted) return;
      setState(() {
        _items = lista;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _error = mensajeDeError(e);
      });
    }
  }

  static String generarClaveTemporal() {
    const letras = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz';
    final r = Random.secure();
    final l = List.generate(3, (_) => letras[r.nextInt(letras.length)]).join();
    final n = List.generate(5, (_) => r.nextInt(10)).join();
    return 'Md$l$n';
  }

  Future<void> _aprobar(Map<String, dynamic> s) async {
    final ctrl = TextEditingController(text: generarClaveTemporal());
    final formKey = GlobalKey<FormState>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.lock_reset_rounded, color: Colors.green[700], size: 40),
        title: const Text('Asignar clave temporal'),
        // [H-GEN-07] Desplazable para que el teclado no corte el contenido en pantallas pequeñas
        content: SingleChildScrollView(
         child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Para ${s['nombreSolicitante']} (DNI ${s['dniSolicitante']}).',
                  textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 14),
              TextFormField(
                controller: ctrl,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                decoration: InputDecoration(
                  labelText: 'Clave temporal',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    tooltip: 'Generar otra',
                    icon: const Icon(Icons.casino_outlined),
                    onPressed: () => ctrl.text = generarClaveTemporal(),
                  ),
                ),
                validator: (v) => (v == null || v.trim().length < 8) ? 'Mínimo 8 caracteres' : null,
              ),
              const SizedBox(height: 8),
              const Text('El trabajador deberá cambiarla desde "Mi Perfil" al ingresar.',
                  style: TextStyle(fontSize: 12, color: Colors.black54), textAlign: TextAlign.center),
            ],
          ),
         ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], foregroundColor: Colors.white),
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(ctx, true);
            },
            icon: const Icon(Icons.check_rounded),
            label: const Text('Aprobar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final clave = ctrl.text.trim();
    try {
      final correo = await SessionManager.correo();
      await _dio.dio.put('/auth/recuperaciones/${s['idRecuperacion']}/aprobar',
          queryParameters: {'nuevaClave': clave, 'correoAdmin': correo});
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: Icon(Icons.check_circle_rounded, color: Colors.green[700], size: 48),
          title: const Text('Solicitud aprobada'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Comunique esta clave a ${s['nombreSolicitante']}:', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(color: AppColors.backgroundGray, borderRadius: BorderRadius.circular(10)),
                child: SelectableText(clave,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: clave));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Clave copiada')));
              },
              icon: const Icon(Icons.copy_rounded),
              label: const Text('Copiar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Listo'),
            ),
          ],
        ),
      );
      _cargar();
    } catch (e) {
      _snack(mensajeDeError(e), error: true);
    }
  }

  Future<void> _rechazar(Map<String, dynamic> s) async {
    final ctrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rechazar solicitud'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: ctrl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Motivo del rechazo',
              hintText: 'Ej.: La selfie no coincide con la foto registrada',
              border: OutlineInputBorder(),
            ),
            validator: (v) => (v == null || v.trim().length < 10) ? 'Mínimo 10 caracteres' : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed, foregroundColor: Colors.white),
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(ctx, true);
            },
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      final correo = await SessionManager.correo();
      await _dio.dio.put('/auth/recuperaciones/${s['idRecuperacion']}/rechazar',
          queryParameters: {'motivo': ctrl.text.trim(), 'correoAdmin': correo});
      _snack('Solicitud rechazada. Se notificó al trabajador.');
      _cargar();
    } catch (e) {
      _snack(mensajeDeError(e), error: true);
    }
  }

  void _snack(String t, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(t), backgroundColor: error ? AppColors.errorRed : Colors.green[700]));
  }

  @override
  Widget build(BuildContext context) {
    final pendientes = _items.where((s) => s['estado'] == 'PENDIENTE').toList();
    final resueltas = _items.where((s) => s['estado'] != 'PENDIENTE').toList();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.backgroundGray,
        appBar: AppBar(
          title: const Text('Recuperación de contraseñas', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          actions: [IconButton(icon: const Icon(Icons.refresh_rounded), tooltip: 'Actualizar', onPressed: _cargar)],
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [Tab(text: 'Pendientes (${pendientes.length})'), Tab(text: 'Historial (${resueltas.length})')],
          ),
        ),
        body: _cargando
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
            : _error != null
                ? Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.cloud_off_rounded, size: 56, color: Colors.grey),
                      Padding(padding: const EdgeInsets.all(12), child: Text(_error!, textAlign: TextAlign.center)),
                      OutlinedButton.icon(onPressed: _cargar, icon: const Icon(Icons.refresh), label: const Text('Reintentar')),
                    ]),
                  )
                : TabBarView(children: [
                    _lista(pendientes, 'No hay solicitudes pendientes.', Icons.verified_user_outlined),
                    _lista(resueltas, 'Aún no se resolvió ninguna solicitud.', Icons.history_rounded),
                  ]),
      ),
    );
  }

  Widget _lista(List<Map<String, dynamic>> items, String vacio, IconData icono) {
    return RefreshIndicator(
      onRefresh: _cargar,
      child: items.isEmpty
          ? ListView(children: [
              const SizedBox(height: 90),
              Icon(icono, size: 60, color: Colors.grey),
              const SizedBox(height: 8),
              Center(child: Text(vacio, style: const TextStyle(color: Colors.grey))),
            ])
          : ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: items.length,
              itemBuilder: (_, i) => _tarjeta(items[i]),
            ),
    );
  }

  Widget _tarjeta(Map<String, dynamic> s) {
    final estado = s['estado']?.toString() ?? 'PENDIENTE';
    final pendiente = estado == 'PENDIENTE';
    final color = pendiente ? Colors.amber[800]! : (estado == 'APROBADA' ? Colors.green[700]! : AppColors.errorRed);
    final fecha = (s['fechaSolicitud'] ?? '').toString().replaceFirst('T', '  ').split('.').first;
    return Card(
      color: AppColors.pureWhite,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: color.withValues(alpha: 0.4))),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: Text('${s['nombreSolicitante'] ?? ''}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryBlue)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
                child: Text(estado[0] + estado.substring(1).toLowerCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ]),
            const SizedBox(height: 4),
            Text('DNI ${s['dniSolicitante']}  ·  ${s['rolSolicitante'] ?? ''}  ·  #${s['idRecuperacion']}',
                style: const TextStyle(color: Colors.black54, fontSize: 12.5)),
            Text('Solicitado: $fecha', style: const TextStyle(color: Colors.black54, fontSize: 12.5)),
            const SizedBox(height: 12),
            // Comparación de identidad
            Row(children: [
              Expanded(child: _Foto(titulo: 'Foto de perfil', url: s['fotoPerfilUrl'])),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Icon(Icons.compare_arrows_rounded, color: Colors.grey),
              ),
              Expanded(child: _Foto(titulo: 'Selfie enviada', url: s['fotoSelfieUrl'])),
            ]),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.backgroundGray, borderRadius: BorderRadius.circular(8)),
              child: Text('Motivo: ${s['motivo'] ?? '-'}'),
            ),
            if (!pendiente && (s['observacionAdmin'] ?? '').toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Resolución: ${s['observacionAdmin']}', style: TextStyle(color: color, fontWeight: FontWeight.w600)),
            ],
            if (pendiente) ...[
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.errorRed,
                      side: const BorderSide(color: AppColors.errorRed),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => _rechazar(s),
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Rechazar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => _aprobar(s),
                    icon: const Icon(Icons.key_rounded),
                    label: const Text('Aprobar'),
                  ),
                ),
              ]),
            ],
          ],
        ),
      ),
    );
  }
}

class _Foto extends StatelessWidget {
  final String titulo;
  final dynamic url;
  const _Foto({required this.titulo, required this.url});

  @override
  Widget build(BuildContext context) {
    final u = ApiService.urlRecurso(url?.toString());
    final vacio = Container(
      color: AppColors.backgroundGray,
      child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.no_photography_outlined, color: Colors.grey, size: 32),
        SizedBox(height: 4),
        Text('Sin foto', style: TextStyle(color: Colors.grey, fontSize: 12)),
      ]),
    );
    return Column(children: [
      Text(titulo, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54)),
      const SizedBox(height: 4),
      GestureDetector(
        onTap: u.isEmpty
            ? null
            : () => showDialog(
                  context: context,
                  builder: (_) => Dialog(child: InteractiveViewer(child: Image.network(u))),
                ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: AspectRatio(
            aspectRatio: 1,
            child: u.isEmpty
                ? vacio
                : Image.network(u, fit: BoxFit.cover, errorBuilder: (_, __, ___) => vacio),
          ),
        ),
      ),
    ]);
  }
}
