import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class AlmacenScanScreen extends StatefulWidget {
  const AlmacenScanScreen({super.key});

  @override
  State<AlmacenScanScreen> createState() => _AlmacenScanScreenState();
}

class _AlmacenScanScreenState extends State<AlmacenScanScreen> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back, // Fuerza el uso exclusivo de la cámara trasera
  );
  
  bool _isScanCompleted = false;

  void _procesarCodigoEscaneado(String codigoLeido) {
    if (_isScanCompleted) return;
    
    setState(() {
      _isScanCompleted = true;
    });

    // RF35: Simulación reactiva de consulta atómica de la ficha técnica del activo en base de datos
    // En la Fase 5 se conectará directamente con los endpoints correspondientes
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          color: const Color(0xFF1E1E1E),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                children: [
                  Icon(Icons.build_circle, color: Color(0xFFFFB300), size: 32),
                  SizedBox(width: 12),
                  Text("Herramienta Reconocida (RF35)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const Divider(color: Colors.grey, height: 24),
              Text("Código de Activo: $codigoLeido", style: const TextStyle(color: Color(0xFF29B6F6), fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("Denominación: Llave de Impacto Neumática 3/4''"),
              const Text("Marca / Categoría: Ingersoll Rand / Hidráulica-Neumática"),
              const Text("Estado Actual: DISPONIBLE EN ESTANTE", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              
              // Botón operativo de transacción (RF36) adaptado para guantes (RNF02)
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Cierra modal
                  _registrarPrestamoExitoso(codigoLeido);
                },
                child: const Text("REGISTRAR PRÉSTAMO A MECÁNICO"),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _isScanCompleted = false; // Reactiva la lente de la cámara
                  });
                },
                child: const Text("CANCELAR ESCANEO", style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _registrarPrestamoExitoso(String codigo) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("✓ Préstamo asentado. Estado actualizado a 'Prestada' (RF37)."),
      backgroundColor: Colors.green,
    ));
    setState(() {
      _isScanCompleted = false; // Libera el escáner para la siguiente herramienta
    });
  }

  @override
  void dispose() {
    _scannerController.dispose(); // Destruye el controlador para liberar memoria de la GPU
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Escáner de Almacén (Pañol)"),
        backgroundColor: const Color(0xFF1E1E1E),
        actions: [
          // Conmutador de Linterna auxiliar para zonas oscuras o socavones subterráneos
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _scannerController.torchState,
              builder: (context, state, child) {
                return Icon(
                  state == TorchState.on ? Icons.flash_on : Icons.flash_off,
                  color: const Color(0xFFFFB300),
                );
              },
            ),
            onPressed: () => _scannerController.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Visor en tiempo real de la cámara trasera (RF34)
          MobileScanner(
            controller: _scannerController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                _procesarCodigoEscaneado(barcodes.first.rawValue!);
              }
            },
          ),
          // Máscara/Guía visual cuadrada para encuadrar los códigos físicos (RF34)
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFFFB300), width: 4),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const Positioned(
            bottom: 48,
            left: 24,
            right: 24,
            child: Text(
              "Encuadre el código QR o código de barras de la herramienta dentro del marco amarillo.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, backgroundColor: Colors.black45, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
