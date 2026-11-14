import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// [PRE-01] Detalle "antes y después" de un préstamo de herramientas.
/// Lo usan el Almacenista (Panel) y el Mecánico (Herramientas). Recibe el JSON de /prestamos.
Future<void> mostrarDetallePrestamo(BuildContext context, Map<String, dynamic> p) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.backgroundGray,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (ctx, scroll) => _DetallePrestamo(p: p, scroll: scroll),
    ),
  );
}

Color colorEstadoPrestamo(String estado) {
  switch (estado.toUpperCase()) {
    case 'CERRADO':
    case 'DEVUELTO':
      return Colors.green[700]!;
    case 'MORA':
    case 'EN_MORA':
      return AppColors.errorRed;
    default:
      return AppColors.primaryBlue;
  }
}

String etiquetaEstadoPrestamo(String estado) {
  switch (estado.toUpperCase()) {
    case 'CERRADO':
    case 'DEVUELTO':
      return 'Devuelto';
    case 'MORA':
    case 'EN_MORA':
      return 'En mora';
    case 'ACTIVO':
      return 'En curso';
    default:
      return estado;
  }
}

class _DetallePrestamo extends StatelessWidget {
  final Map<String, dynamic> p;
  final ScrollController scroll;
  const _DetallePrestamo({required this.p, required this.scroll});

  String _hora(dynamic h) {
    final s = h?.toString() ?? '';
    return s.length >= 5 ? s.substring(0, 5) : s;
  }

  String _fecha(dynamic f) {
    final s = f?.toString() ?? '';
    final partes = s.split('-');
    return partes.length == 3 ? '${partes[2]}/${partes[1]}/${partes[0]}' : s;
  }

  @override
  Widget build(BuildContext context) {
    final estado = p['estadoPrestamo']?.toString() ?? 'ACTIVO';
    final devuelto = p['devolucionNum'] != null;
    final herramientas = (p['herramientas'] as List?)?.cast<Map>() ?? const [];
    final incidencia = p['detalleIncidencia']?.toString();

    return ListView(
      controller: scroll,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(4)),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: Text('Préstamo ${p['prestamoNum'] ?? ''}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
            ),
            _Pill(texto: etiquetaEstadoPrestamo(estado), color: colorEstadoPrestamo(estado)),
          ],
        ),
        const SizedBox(height: 4),
        Text('Mecánico: ${p['nombreMecanico'] ?? '-'}  ·  DNI ${p['dniMecanico'] ?? '-'}',
            style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 16),

        // ---- Antes / Después ----
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _Etapa(
                  titulo: 'ANTES · Entrega',
                  icono: Icons.logout_rounded,
                  color: AppColors.primaryBlue,
                  lineas: [
                    _fecha(p['fechaPrestamo']),
                    'Hora: ${_hora(p['horaSalida'])}',
                    'Entregó: ${p['nombreAlmacenistaEntrega'] ?? '-'}',
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Center(child: Icon(Icons.arrow_forward_rounded, color: Colors.grey)),
              ),
              Expanded(
                child: devuelto
                    ? _Etapa(
                        titulo: 'DESPUÉS · Devolución',
                        icono: Icons.login_rounded,
                        color: Colors.green[700]!,
                        lineas: [
                          _fecha(p['fechaDevolucion']),
                          'Hora: ${_hora(p['horaRetorno'])}',
                          'Recibió: ${p['nombreAlmacenistaRecepcion'] ?? '-'}',
                        ],
                      )
                    : _Etapa(
                        titulo: 'DESPUÉS · Devolución',
                        icono: Icons.hourglass_top_rounded,
                        color: Colors.grey,
                        lineas: const ['Pendiente', 'La herramienta aún', 'no ha sido devuelta'],
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text('Estado de cada herramienta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 8),
        ...herramientas.map((h) {
          final despues = h['estadoAlDevolver']?.toString();
          final conProblema = despues != null && !despues.toLowerCase().contains('operativ') && !despues.toLowerCase().contains('bueno');
          return Card(
            color: AppColors.pureWhite,
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.handyman_rounded, color: AppColors.primaryBlue, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('${h['nombreHerramienta'] ?? ''}',
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                      Text('${h['codHerramienta'] ?? ''}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _Pill(texto: h['estadoAlEntregar']?.toString() ?? 'Operativa', color: AppColors.primaryBlue),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.grey),
                      ),
                      _Pill(
                        texto: despues ?? 'En uso',
                        color: despues == null ? Colors.grey : (conProblema ? Colors.orange[800]! : Colors.green[700]!),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        if (incidencia != null && incidencia.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.report_problem_outlined, color: Colors.orange[800]),
                const SizedBox(width: 10),
                Expanded(child: Text('Observaciones de la inspección:\n$incidencia')),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Etapa extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final Color color;
  final List<String> lineas;
  const _Etapa({required this.titulo, required this.icono, required this.color, required this.lineas});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border(top: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icono, size: 18, color: color),
            const SizedBox(width: 6),
            Expanded(child: Text(titulo, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: color))),
          ]),
          const SizedBox(height: 8),
          ...lineas.map((l) => Text(l, style: const TextStyle(fontSize: 12.5))),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String texto;
  final Color color;
  const _Pill({required this.texto, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(texto, style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.bold)),
    );
  }
}
