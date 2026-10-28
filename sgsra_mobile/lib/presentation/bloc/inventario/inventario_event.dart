abstract class InventarioEvent {}

class CargarDashboardRequested extends InventarioEvent {}

class EscanearCodigoQRRequested extends InventarioEvent {
  final String codigo;
  EscanearCodigoQRRequested(this.codigo);
}

class RegistrarPrestamoRequested extends InventarioEvent {
  final String dniMecanico;
  final List<String> codigosHerramienta;
  final String firmaMecanico;

  RegistrarPrestamoRequested({
    required this.dniMecanico,
    required this.codigosHerramienta,
    required this.firmaMecanico,
  });
}