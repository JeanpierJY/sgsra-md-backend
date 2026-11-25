import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/session/session_manager.dart';
import '../../../../core/utils/navegacion_solicitud.dart';
import '../../../../core/widgets/detalle_solicitud_sheet.dart';
import '../../../administrador/presentation/screens/solicitudes_recuperacion_screen.dart';
import '../../../almacen/presentation/screens/despacho_repuestos_tab.dart';
import '../../data/datasources/notificacion_remote_datasource.dart';
import '../../domain/entities/notificacion_entity.dart';
import '../bloc/notificacion_bloc.dart';

/// [RF50] Centro de Notificaciones universal con pestañas No leídas / Leídas
class CentroNotificacionesScreen extends StatelessWidget {
  final String dni;
  const CentroNotificacionesScreen({super.key, required this.dni});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificacionBloc(datasource: NotificacionRemoteDataSource(), dni: dni)..add(CargarNotificaciones()),
      child: const _CentroNotificacionesView(),
    );
  }
}

class _CentroNotificacionesView extends StatelessWidget {
  const _CentroNotificacionesView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificacionBloc, NotificacionState>(
      builder: (context, state) {
        final bloc = context.read<NotificacionBloc>();
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: AppColors.backgroundGray,
            appBar: AppBar(
              title: const Text('Notificaciones', style: TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  tooltip: 'Actualizar',
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: () => bloc.add(CargarNotificaciones()),
                ),
              ],
              bottom: TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
                tabs: [
                  Tab(text: 'No leídas (${state.noLeidas.length})'),
                  Tab(text: 'Leídas (${state.leidas.length})'),
                ],
              ),
            ),
            floatingActionButton: state.noLeidas.isEmpty
                ? null
                : FloatingActionButton.extended(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    onPressed: () => bloc.add(MarcarTodasLeidas()),
                    icon: const Icon(Icons.done_all_rounded),
                    label: const Text('Marcar todas como leídas'),
                  ),
            body: state.cargando && state.items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.error != null && state.items.isEmpty
                    ? _EstadoVacio(
                        icono: Icons.wifi_off_rounded,
                        titulo: 'No se pudieron cargar las notificaciones',
                        detalle: state.error!,
                        onReintentar: () => bloc.add(CargarNotificaciones()),
                      )
                    : TabBarView(
                        children: [
                          _ListaNotificaciones(
                            items: state.noLeidas,
                            vacio: const _EstadoVacio(
                              icono: Icons.notifications_off_outlined,
                              titulo: 'Está al día',
                              detalle: 'No tiene notificaciones pendientes de leer.',
                            ),
                          ),
                          _ListaNotificaciones(
                            items: state.leidas,
                            vacio: const _EstadoVacio(
                              icono: Icons.inbox_outlined,
                              titulo: 'Sin historial',
                              detalle: 'Aquí aparecerán las notificaciones que ya leyó.',
                            ),
                          ),
                        ],
                      ),
          ),
        );
      },
    );
  }
}

class _ListaNotificaciones extends StatelessWidget {
  final List<NotificacionEntity> items;
  final Widget vacio;
  const _ListaNotificaciones({required this.items, required this.vacio});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<NotificacionBloc>();
    return RefreshIndicator(
      onRefresh: () async => bloc.add(CargarNotificaciones()),
      child: items.isEmpty
          ? ListView(children: [const SizedBox(height: 80), vacio])
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) => _TarjetaNotificacion(n: items[i]),
            ),
    );
  }
}

class _TarjetaNotificacion extends StatelessWidget {
  final NotificacionEntity n;
  const _TarjetaNotificacion({required this.n});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.pureWhite,
      elevation: n.leida ? 0.5 : 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: n.leida ? BorderSide.none : BorderSide(color: n.color.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _abrir(context),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: n.color.withValues(alpha: 0.12),
                child: Icon(n.icono, color: n.color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            n.titulo,
                            style: TextStyle(fontWeight: n.leida ? FontWeight.w500 : FontWeight.bold, fontSize: 14.5),
                          ),
                        ),
                        if (!n.leida)
                          Container(
                            width: 9,
                            height: 9,
                            decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(n.mensaje, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 13, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(_tiempoRelativo(n.fechaCreacion), style: const TextStyle(fontSize: 11.5, color: Colors.grey)),
                        const Spacer(),
                        if (_destino != null)
                          Row(mainAxisSize: MainAxisSize.min, children: [
                            Text(_destino!,
                                style: const TextStyle(fontSize: 11.5, color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
                            const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.primaryBlue),
                          ])
                        else if (!n.leida)
                          const Text('Toque para marcar como leída',
                              style: TextStyle(fontSize: 11, color: AppColors.primaryBlue)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _esRecuperacion => n.titulo.toLowerCase().contains('recuperacion') && n.titulo.toLowerCase().startsWith('solicitud');

  /// [ADM-04] Texto del enlace si la notificación lleva a una pantalla concreta
  String? get _destino {
    if (extraerCodigoSolicitud('${n.titulo} ${n.mensaje}') != null) return 'Ver solicitud';
    if (_esRecuperacion) return 'Revisar solicitud';
    return null;
  }

  Future<void> _abrir(BuildContext context) async {
    final bloc = context.read<NotificacionBloc>();
    if (!n.leida) bloc.add(MarcarNotificacionLeida(n.id));
    final codigo = extraerCodigoSolicitud('${n.titulo} ${n.mensaje}');
    final rol = await SessionManager.rol();
    if (!context.mounted) return;
    if (codigo != null && (rol ?? '').toUpperCase().contains('ALMACENISTA')) {
      // [ALM-01] El almacenista va directo a la hoja de despacho de esa solicitud
      await mostrarDespachoSolicitud(context, codigo);
    } else if (codigo != null && (rol ?? '').toUpperCase() == 'ADMINISTRADOR') {
      // [H-ADM-05] El administrador vuelve a su panel, pasa a la Bandeja y se abre la solicitud
      Navigator.of(context).popUntil((r) => r.isFirst);
      NavegacionSolicitud.abrirEnBandeja(codigo);
    } else if (codigo != null) {
      await mostrarDetalleSolicitud(context, codigo);
    } else if (_esRecuperacion && rol == 'ADMINISTRADOR') {
      await Navigator.push(context, MaterialPageRoute(builder: (_) => const SolicitudesRecuperacionScreen()));
    }
  }

  static String _tiempoRelativo(DateTime? fecha) {
    if (fecha == null) return '';
    final d = DateTime.now().difference(fecha);
    if (d.inMinutes < 1) return 'Hace un momento';
    if (d.inMinutes < 60) return 'Hace ${d.inMinutes} min';
    if (d.inHours < 24) return 'Hace ${d.inHours} h';
    if (d.inDays < 7) return 'Hace ${d.inDays} día${d.inDays == 1 ? '' : 's'}';
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }
}

class _EstadoVacio extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String detalle;
  final VoidCallback? onReintentar;

  const _EstadoVacio({required this.icono, required this.titulo, required this.detalle, this.onReintentar});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(detalle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
          if (onReintentar != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(onPressed: onReintentar, icon: const Icon(Icons.refresh_rounded), label: const Text('Reintentar')),
          ],
        ],
      ),
    );
  }
}
