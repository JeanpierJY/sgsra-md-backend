import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../bloc/inventario/inventario_bloc.dart';
import '../../bloc/inventario/inventario_event.dart';
import '../../bloc/inventario/inventario_state.dart';

class EscanerQrScreen extends StatefulWidget {
  const EscanerQrScreen({super.key});

  @override
  State<EscanerQrScreen> createState() => _EscanerQrScreenState();
}

class _EscanerQrScreenState extends State<EscanerQrScreen> {
  final MobileScannerController _cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  
  bool _procesandoCaptura = false;
  final _dniMecanicoController = TextEditingController();

  void _evaluarDeteccion(String codigoQR) {
    if (_procesandoCaptura) return;
    _procesandoCaptura = true;
    context.read<InventarioBloc>().add(EscanearCodigoQRRequested(codigoQR));
  }

  void _desplegarModalTransaccion(BuildContext context, HerramientaEscaneadaLoaded state) {
    final h = state.herramienta;
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: const Color(0xFF1E1E1E),
      builder: (modalContext) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("Ficha Activo: ${h.nombreHerramienta}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text("Código QR grabado: ${h.codHerramienta}", style: const TextStyle(color: Color(0xFF29B6F6))),
              Text("Estado en Almacén: ${h.estadoActual.toUpperCase()}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: _dniMecanicoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "DNI Mecánico Responsable (RF36)"),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_dniMecanicoController.text.length == 8) {
                    context.read<InventarioBloc>().add(ConfirmarPrestamoRequested(
                      dniMecanico: _dniMecanicoController.text.trim(),
                      codigosHerramientas: [h.codHerramienta],
                      firmaBase64: "FIRMA_AUTENTICADA_TOUCH_DIGITAL",
                    ));
                    Navigator.pop(modalContext);
                    Navigator.pop(context);
                  }
                },
                child: const Text("PROCESAR DESPACHO Y MUTAR ESTADO"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(modalContext);
                  setState(() => _procesandoCaptura = false);
                },
                child: const Text("CANCELAR", style: TextStyle(color: Colors.grey)),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _dniMecanicoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lente del Pañol QR")),
      body: BlocListener<InventarioBloc, InventarioState>(
        listener: (context, state) {
          if (state is HerramientaEscaneadaLoaded) {
            _desplegarModalTransaccion(context, state);
          } else if (state is TransaccionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.msg), backgroundColor: Colors.green));
          } else if (state is InventarioFailure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error), backgroundColor: Colors.red));
            setState(() => _procesandoCaptura = false);
          }
        },
        child: Stack(
          children: [
            MobileScanner(
              controller: _cameraController,
              onDetect: (capture) {
                final barcodes = capture.barcodes;
                if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                  _evaluarDeteccion(barcodes.first.rawValue!);
                }
              },
            ),
            Center(
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFFFB300), width: 3),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
