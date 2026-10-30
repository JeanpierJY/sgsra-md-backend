import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/datasources/repuesto_remote_datasource.dart';
import '../../../../core/network/dio_client.dart';

class HerramientasPrestadasScreen extends StatefulWidget {
  const HerramientasPrestadasScreen({Key? key}) : super(key: key);

  @override
  State<HerramientasPrestadasScreen> createState() => _HerramientasPrestadasScreenState();
}

class _HerramientasPrestadasScreenState extends State<HerramientasPrestadasScreen> {
  final RepuestoRemoteDataSource _dataSource = RepuestoRemoteDataSource(DioClient());
  bool _isLoading = true;
  List<dynamic> _prestamos = [];

  @override
  void initState() {
    super.initState();
    _cargarHerramientas();
  }

  Future<void> _cargarHerramientas() async {
    setState(() => _isLoading = true);
    try {
      final list = await _dataSource.listarHerramientasCustodia();
      setState(() {
        _prestamos = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: const Text('Herramientas en Custodia [RF36]', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryBlue,
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _cargarHerramientas),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
          : _prestamos.isEmpty
              ? const Center(child: Text('Usted no registra herramientas prestadas actualmente.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: _prestamos.length,
                  itemBuilder: (context, index) {
                    final p = _prestamos[index];
                    return Card(
                      color: AppColors.pureWhite,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: const CircleAvatar(backgroundColor: AppColors.primaryBlue, child: Icon(Icons.build, color: Colors.white)),
                        title: Text('Prestamo: ${p['prestamoNum'] ?? 'PRES-00'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Estado: ${p['estadoPrestamo']}\nFecha Salida: ${p['fechaPrestamo']}'),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
    );
  }
}