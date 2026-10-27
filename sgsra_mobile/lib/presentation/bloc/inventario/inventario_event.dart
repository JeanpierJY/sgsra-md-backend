abstract class InventarioEvent {}
class FetchMetricasDashboardRequested extends InventarioEvent {}
class EscanearCodigoQRRequested extends InventarioEvent { final String codigo; InventarioEvent(this.codigo); }
class ConfirmarPrestamoRequested extends InventarioEvent {
  final String dniMecanico;
  final List<String> codigosHerramientas;
  final String firmaBase64;
  ConfirmarPrestamoRequested({required this.dniMecanico, required this.codigosHerramientas, required this.firmaBase64});
}
