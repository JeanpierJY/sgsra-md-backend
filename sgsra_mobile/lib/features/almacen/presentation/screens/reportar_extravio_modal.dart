import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/imagen_producto.dart';
import '../../../../core/widgets/selector_buscable.dart';
import '../../data/datasources/almacen_remote_datasource.dart';
import '../../domain/entities/almacen_entities.dart';
import '../widgets/herramienta_ui.dart';
import '../../../../core/network/dio_client.dart';

/// [RF41, RF42, ALM-05] Modal de herramientas extraviadas y reporte de extravíos.
/// Incluye buscador predictivo enfocado en herramientas extraviadas y selección asistida.
void mostrarModalReportarExtravio(BuildContext context, VoidCallback onReportado, {String? codigo}) {
  final dataSource = AlmacenRemoteDataSource(DioClient());

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.pureWhite,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _ModalExtravioHerramientas(
      dataSource: dataSource,
      codigoInicial: codigo,
      onReportado: () {
        Navigator.pop(ctx);
        onReportado();
      },
    ),
  );
}

class _ModalExtravioHerramientas extends StatefulWidget {
  final AlmacenRemoteDataSource dataSource;
  final String? codigoInicial;
  final VoidCallback onReportado;

  const _ModalExtravioHerramientas({
    required this.dataSource,
    this.codigoInicial,
    required this.onReportado,
  });

  @override
  State<_ModalExtravioHerramientas> createState() => _ModalExtravioHerramientasState();
}

class _ModalExtravioHerramientasState extends State<_ModalExtravioHerramientas> {
  final TextEditingController _buscarExtraviadasCtrl = TextEditingController();
  final TextEditingController _codCtrl = TextEditingController();
  final TextEditingController _motivoCtrl = TextEditingController(text: 'Herramienta extraviada en labor subterránea de mina');

  bool _cargando = true;
  bool _enviando = false;
  List<HerramientaEntity> _todasHerramientas = [];
  HerramientaEntity? _herramientaSeleccionada;

  @override
  void initState() {
    super.initState();
    _codCtrl.text = widget.codigoInicial ?? '';
    _cargarHerramientas();
  }

  @override
  void dispose() {
    _buscarExtraviadasCtrl.dispose();
    _codCtrl.dispose();
    _motivoCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarHerramientas() async {
    setState(() => _cargando = true);
    try {
      final list = await widget.dataSource.listarHerramientas();
      if (!mounted) return;
      setState(() {
        _todasHerramientas = list;
        if (widget.codigoInicial != null && widget.codigoInicial!.isNotEmpty) {
          _herramientaSeleccionada = list.firstWhere(
            (h) => h.codHerramienta.toUpperCase() == widget.codigoInicial!.toUpperCase(),
            orElse: () => list.first,
          );
        }
        _cargando = false;
      });
    } catch (_) {
      if (mounted) setState(() => _cargando = false);
    }
  }

  List<HerramientaEntity> get _herramientasExtraviadas {
    final q = _buscarExtraviadasCtrl.text.trim().toLowerCase();
    return _todasHerramientas.where((h) {
      final esExtraviada = claveEstadoHerramienta(h.estadoActual) == 'EXTRAVIADA';
      if (!esExtraviada) return false;
      if (q.isEmpty) return true;
      return '${h.codHerramienta} ${h.nombre} ${h.marca} ${h.categoria}'.toLowerCase().contains(q);
    }).toList();
  }

  void _abrirSelectorParaReportar() async {
    // Para reportar se pueden seleccionar herramientas activas/prestadas/en mora
    final elegida = await mostrarSelectorBuscable<HerramientaEntity>(
      context: context,
      titulo: 'Seleccionar herramienta a reportar',
      hint: 'Buscar por código, nombre o marca...',
      items: _todasHerramientas,
      textoBusqueda: (h) => '${h.codHerramienta} ${h.nombre} ${h.marca}',
      construir: (ctx, h) => ListTile(
        leading: ImagenProducto(url: h.imagenUrl, size: 40, color: colorEstadoHerramienta(h.estadoActual)),
        title: Text(h.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text('${h.codHerramienta} · Estado: ${h.estadoActual}'),
        trailing: EstadoHerramientaPill(h.estadoActual),
      ),
    );

    if (elegida != null && mounted) {
      setState(() {
        _herramientaSeleccionada = elegida;
        _codCtrl.text = elegida.codHerramienta;
      });
    }
  }

  Future<void> _confirmarReporte() async {
    final cod = _codCtrl.text.trim();
    final motivo = _motivoCtrl.text.trim();
    if (cod.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione o ingrese el código de la herramienta'), backgroundColor: AppColors.errorRed),
      );
      return;
    }
    if (motivo.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe fundamentar con al menos 10 caracteres'), backgroundColor: AppColors.errorRed),
      );
      return;
    }

    setState(() => _enviando = true);
    try {
      final custodio = await widget.dataSource.reportarExtravio(cod, motivo);
      if (!mounted) return;
      widget.onReportado();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Extravío asentado. Responsabilidad imputada a: $custodio [RF42]'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _enviando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.errorRed),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final extraviadas = _herramientasExtraviadas;

    return Padding(
      padding: EdgeInsets.only(
        left: 18,
        right: 18,
        top: 18,
        bottom: MediaQuery.of(context).viewInsets.bottom + 18,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.errorRed, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Herramientas Extraviadas [RF41, RF42]',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.errorRed),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Text(
              'Buscador predictivo exclusivo de herramientas extraviadas e imputación de responsabilidad.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            // Buscador predictivo exclusivo de herramientas extraviadas
            TextField(
              controller: _buscarExtraviadasCtrl,
              decoration: InputDecoration(
                hintText: 'Buscar en herramientas extraviadas...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.errorRed),
                suffixIcon: _buscarExtraviadasCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () => setState(_buscarExtraviadasCtrl.clear),
                      )
                    : null,
                isDense: true,
                filled: true,
                fillColor: AppColors.backgroundGray,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 10),
            // Listado predictivo de herramientas extraviadas
            Flexible(
              child: _cargando
                  ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                  : extraviadas.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: AppColors.backgroundGray, borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_outline_rounded, color: Colors.green),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _buscarExtraviadasCtrl.text.isEmpty
                                      ? 'No se registran herramientas en estado extraviado.'
                                      : 'No hay extraviadas que coincidan con la búsqueda.',
                                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: extraviadas.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 6),
                          itemBuilder: (ctx, i) {
                            final h = extraviadas[i];
                            return Card(
                              elevation: 0,
                              color: AppColors.errorRed.withValues(alpha: 0.06),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: AppColors.errorRed.withValues(alpha: 0.2)),
                              ),
                              child: ListTile(
                                dense: true,
                                leading: ImagenProducto(url: h.imagenUrl, size: 38, color: AppColors.errorRed),
                                title: Text('${h.nombre} (${h.codHerramienta})',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                                subtitle: Text('Marca: ${h.marca} · Categoría: ${h.categoria}',
                                    style: const TextStyle(fontSize: 11.5)),
                                trailing: const EstadoHerramientaPill('EXTRAVIADA'),
                              ),
                            );
                          },
                        ),
            ),
            const Divider(height: 24),
            // Sección para asentar nuevo extravío
            const Text(
              'Reportar Nuevo Extravío de Herramienta:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppColors.primaryBlue),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _abrirSelectorParaReportar,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.backgroundGray,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.handyman_outlined, size: 20, color: AppColors.primaryBlue),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _herramientaSeleccionada != null
                            ? '${_herramientaSeleccionada!.nombre} (${_herramientaSeleccionada!.codHerramienta})'
                            : (_codCtrl.text.isNotEmpty ? _codCtrl.text : 'Toque para seleccionar herramienta con buscador...'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: _codCtrl.text.isNotEmpty ? FontWeight.bold : FontWeight.normal,
                          color: _codCtrl.text.isNotEmpty ? Colors.black87 : Colors.grey,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: AppColors.primaryBlue),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _motivoCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Circunstancias del Extravío (Mín. 10 car.)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.errorRed,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: _enviando ? null : _confirmarReporte,
                icon: _enviando
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.report_gmailerrorred_rounded, color: Colors.white),
                label: Text(
                  _enviando ? 'Asentando...' : 'Confirmar Extravío e Imputar Responsabilidad [RF42]',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
