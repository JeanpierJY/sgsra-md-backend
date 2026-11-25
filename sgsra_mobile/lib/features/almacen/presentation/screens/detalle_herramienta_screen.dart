import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/widgets/detalle_prestamo_sheet.dart';
import '../../../../core/widgets/imagen_producto.dart';
import '../../data/datasources/almacen_remote_datasource.dart';
import '../../domain/entities/almacen_entities.dart';
import '../widgets/herramienta_ui.dart';
import '../widgets/qr_herramienta.dart';
import 'reportar_extravio_modal.dart';

/// [RF35, ALM-04] Ficha de una herramienta: foto (editable), datos, estado e historial de préstamos.
class DetalleHerramientaScreen extends StatefulWidget {
  final HerramientaEntity herramienta;
  const DetalleHerramientaScreen({super.key, required this.herramienta});

  @override
  State<DetalleHerramientaScreen> createState() => _DetalleHerramientaScreenState();
}

class _DetalleHerramientaScreenState extends State<DetalleHerramientaScreen> {
  final AlmacenRemoteDataSource _ds = AlmacenRemoteDataSource(DioClient());
  late HerramientaEntity _h = widget.herramienta;
  List<PrestamoEntity> _historial = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final r = await Future.wait([
        _ds.consultarHerramienta(_h.codHerramienta),
        _ds.listarPrestamos(),
      ]);
      final prestamos = (r[1] as List<PrestamoEntity>)
          .where((p) => p.herramientas.contains(_h.codHerramienta))
          .toList()
        ..sort((a, b) => '${b.fechaPrestamo} ${b.horaSalida}'.compareTo('${a.fechaPrestamo} ${a.horaSalida}'));
      if (!mounted) return;
      setState(() {
        _h = r[0] as HerramientaEntity;
        _historial = prestamos;
        _cargando = false;
      });
    } catch (_) {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _cambiarFoto() async {
    final r = await seleccionarYSubirImagen(context, '/inventario/herramientas/${_h.codHerramienta}/imagen');
    if (r != null) _cargar();
  }

  @override
  Widget build(BuildContext context) {
    final url = ApiService.urlRecurso(_h.imagenUrl);
    final color = colorEstadoHerramienta(_h.estadoActual);
    final clave = claveEstadoHerramienta(_h.estadoActual);
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(title: Text(_h.codHerramienta)),
      body: RefreshIndicator(
        onRefresh: _cargar,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: AppColors.pureWhite,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(children: [
                Stack(children: [
                  GestureDetector(
                    onTap: url.isEmpty ? _cambiarFoto : () => ampliarImagen(context, url),
                    child: Container(
                      height: 210,
                      width: double.infinity,
                      color: color.withValues(alpha: 0.08),
                      child: url.isEmpty
                          ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Icon(Icons.handyman_outlined, size: 64, color: color),
                              const SizedBox(height: 6),
                              const Text('Sin foto · toque para agregar', style: TextStyle(color: Colors.black54)),
                            ])
                          : Image.network(url, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(Icons.broken_image_outlined, size: 56, color: color)),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.black54,
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: _cambiarFoto,
                      icon: const Icon(Icons.photo_camera_outlined, size: 18),
                      label: Text(url.isEmpty ? 'Agregar foto' : 'Cambiar foto'),
                    ),
                  ),
                ]),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(
                        child: Text(_h.nombre,
                            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                      ),
                      EstadoHerramientaPill(_h.estadoActual),
                    ]),
                    const Divider(height: 22),
                    _dato(Icons.qr_code_2_rounded, 'Código', _h.codHerramienta),
                    _dato(Icons.factory_outlined, 'Marca', _h.marca),
                    _dato(Icons.category_outlined, 'Categoría', _h.categoria),
                  ]),
                ),
              ]),
            ),
            // [H-ALM-10] QR de la herramienta para imprimir o mostrar en el escáner de Retorno
            const SizedBox(height: 10),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
                side: const BorderSide(color: AppColors.primaryBlue),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () => mostrarQrHerramienta(context, _h.codHerramienta, _h.nombre),
              icon: const Icon(Icons.qr_code_2_rounded),
              label: const Text('Ver código QR'),
            ),
            if (clave != 'EXTRAVIADA' && clave != 'BAJA_TECNICA') ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.errorRed,
                  side: const BorderSide(color: AppColors.errorRed),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => mostrarModalReportarExtravio(context, _cargar, codigo: _h.codHerramienta),
                icon: const Icon(Icons.report_gmailerrorred_rounded),
                label: const Text('Reportar extravío'),
              ),
            ],
            const SizedBox(height: 18),
            Text('Historial de préstamos (${_historial.length})',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryBlue)),
            const SizedBox(height: 8),
            if (_cargando)
              const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()))
            else if (_historial.isEmpty)
              const Card(
                color: AppColors.pureWhite,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Esta herramienta aún no ha sido prestada.', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ..._historial.map((p) => Card(
                    color: AppColors.pureWhite,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      onTap: () => mostrarDetallePrestamo(context, p.raw),
                      leading: CircleAvatar(
                        backgroundColor: colorEstadoPrestamo(p.estadoPrestamo),
                        child: const Icon(Icons.swap_horiz_rounded, color: Colors.white),
                      ),
                      title: Text('${p.prestamoNum} · ${p.nombreMecanico}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('Salida: ${p.fechaPrestamo}  ·  Toque para ver el detalle'),
                      trailing: Text(etiquetaEstadoPrestamo(p.estadoPrestamo),
                          style: TextStyle(color: colorEstadoPrestamo(p.estadoPrestamo), fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _dato(IconData i, String e, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          Icon(i, size: 18, color: AppColors.primaryBlue),
          const SizedBox(width: 10),
          SizedBox(width: 90, child: Text(e, style: const TextStyle(color: Colors.black54))),
          Expanded(child: Text(v, style: const TextStyle(fontWeight: FontWeight.w600))),
        ]),
      );
}
