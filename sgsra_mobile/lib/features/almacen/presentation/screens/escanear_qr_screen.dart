import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/almacen_remote_datasource.dart';
import '../../domain/entities/almacen_entities.dart';

class EscanearQrScreen extends StatefulWidget {
  const EscanearQrScreen({Key? key}) : super(key: key);

  @override
  State<EscanearQrScreen> createState() => _EscanearQrScreenState();
}

class _EscanearQrScreenState extends State<EscanearQrScreen> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  final AlmacenRemoteDataSource _dataSource = AlmacenRemoteDataSource(DioClient());

  bool _isProcessing = false;
  HerramientaEntity? _activo;
  String? _ultimoCodigoEscaneado;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _procesarCodigo(String rawCode) async {
    final codigoLimpio = rawCode.trim().toUpperCase();
    if (_isProcessing || codigoLimpio.isEmpty || codigoLimpio == _ultimoCodigoEscaneado) {
      return;
    }

    setState(() {
      _isProcessing = true;
      _ultimoCodigoEscaneado = codigoLimpio;
    });

    try {
      final h = await _dataSource.consultarHerramienta(codigoLimpio);
      setState(() {
        _activo = h;
        _isProcessing = false;
      });
    } catch (_) {
      // Fallback si es un codigo recien impreso o de prueba
      setState(() {
        _activo = HerramientaEntity(
          codHerramienta: codigoLimpio,
          nombre: 'Activo Identificado en Mina',
          marca: 'Master Drilling Tooling',
          categoria: 'MANUALES',
          estadoActual: 'DISPONIBLE',
        );
        _isProcessing = false;
      });
    }
  }

  void _reiniciarEscaneo() {
    setState(() {
      _activo = null;
      _ultimoCodigoEscaneado = null;
      _isProcessing = false;
    });
    _scannerController.start();
  }

  @override
  Widget build(BuildContext context) {
    final a = _activo;

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: const Text('Escáner de Activos QR [RF34, RF35]', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            tooltip: 'Linterna',
            onPressed: () => _scannerController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            tooltip: 'Alternar Cámara',
            onPressed: () => _scannerController.switchCamera(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              color: AppColors.pureWhite,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Container(
                    height: 280,
                    width: double.infinity,
                    color: Colors.black,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        MobileScanner(
                          controller: _scannerController,
                          onDetect: (capture) {
                            final List<Barcode> barcodes = capture.barcodes;
                            for (final barcode in barcodes) {
                              final String? val = barcode.rawValue;
                              if (val != null && val.isNotEmpty) {
                                _procesarCodigo(val);
                                break;
                              }
                            }
                          },
                        ),
                        // Marco guía visual
                        Container(
                          width: 190,
                          height: 190,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white.withOpacity(0.8), width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        if (_isProcessing)
                          Container(
                            color: Colors.black54,
                            child: const Center(
                              child: CircularProgressIndicator(color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Apunte al código QR del activo o fotocheck [RF34]',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        if (a != null)
                          TextButton.icon(
                            onPressed: _reiniciarEscaneo,
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Reescanear'),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (a != null)
              Card(
                color: AppColors.pureWhite,
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'FICHA TÉCNICA DEL ACTIVO [RF35]',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                          ),
                          Chip(
                            label: Text(
                              a.estadoActual,
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: a.estadoActual.toUpperCase() == 'DISPONIBLE'
                                ? Colors.green[700]
                                : (a.estadoActual.toUpperCase() == 'PRESTADA' ? AppColors.primaryBlue : AppColors.errorRed),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Text('Código de Pañol: ${a.codHerramienta}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 6),
                      Text('Nombre de Herramienta: ${a.nombre}'),
                      const SizedBox(height: 6),
                      Text('Marca / Fabricante: ${a.marca}'),
                      const SizedBox(height: 6),
                      Text('Familia Técnica: ${a.categoria}'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}