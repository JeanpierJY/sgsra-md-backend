import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class EscanerQRScreen extends StatefulWidget {
  const EscanerQRScreen({super.key});

  @override
  State<EscanerQRScreen> createState() => _EscanerQRScreenState();
}

class _EscanerQRScreenState extends State<EscanerQRScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _escaneado = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Escanear Código QR"),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              if (_escaneado) return;
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final String? codigo = barcode.rawValue;
                if (codigo != null && codigo.isNotEmpty) {
                  setState(() => _escaneado = true);
                  Navigator.pop(context, codigo);
                  break;
                }
              }
            },
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFFFB300), width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}