import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../bloc/inventario/inventario_bloc.dart';
import '../../bloc/inventario/inventario_event.dart';

class EscanerQRScreen extends StatefulWidget {
  const EscanerQRScreen({super.key});

  @override
  State<EscanerQRScreen> createState() => _EscanerQRScreenState();
}

class _EscanerQRScreenState extends State<EscanerQRScreen> {
  bool _escaneado = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Escaner QR de Herramientas")),
      body: MobileScanner(
        onDetect: (capture) {
          if (_escaneado) return;
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            final String? codigo = barcode.rawValue;
            if (codigo != null && codigo.isNotEmpty) {
              setState(() => _escaneado = true);
              context.read<InventarioBloc>().add(EscanearCodigoQRRequested(codigo));
              Navigator.pop(context, codigo);
              break;
            }
          }
        },
      ),
    );
  }
}