import 'package:flutter/material.dart';
import '../../../data/services/api_service.dart';

class AuditoriaAdminTab extends StatefulWidget {
  const AuditoriaAdminTab({super.key});

  @override
  State<AuditoriaAdminTab> createState() => _AuditoriaAdminTabState();
}

class _AuditoriaAdminTabState extends State<AuditoriaAdminTab> {
  final ApiService _apiService = ApiService();
  List<dynamic> _logs = [];
  bool _cargando = true;
  bool _descargando = false;

  @override
  void initState() {
    super.initState();
    _cargarAuditoria();
  }

  Future<void> _cargarAuditoria() async {
    setState(() => _cargando = true);
    try {
      final res = await _apiService.obtenerAuditoria();
      if (mounted) {
        List<dynamic> lista = [];
        if (res.data is List) {
          lista = res.data;
        } else if (res.data is Map && res.data['content'] != null) {
          lista = res.data['content'] as List;
        }
        setState(() {
          _logs = lista;
          _cargando = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _exportarAuditoriaExcel() async {
    setState(() => _descargando = true);
    try {
      await _apiService.descargarArchivoNativo('/reportes/exportar/excel', 'Auditoria_SGSRA_MD.xlsx');
      if (!mounted) return;
      setState(() => _descargando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Auditoria exportada exitosamente en Excel")),
      );
    } catch (_) {
      if (mounted) setState(() => _descargando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al descargar el archivo de auditoria")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bitacora de Auditoria"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _cargarAuditoria),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.blue.shade50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Registro inmutable de operaciones (Append-Only)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
                        icon: _descargando
                            ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.download, size: 16, color: Colors.white),
                        label: const Text("EXCEL", style: TextStyle(color: Colors.white, fontSize: 11)),
                        onPressed: _descargando ? null : _exportarAuditoriaExcel,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _logs.isEmpty
                      ? const Center(child: Text("No hay registros de auditoria."))
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _logs.length,
                          itemBuilder: (ctx, i) {
                            final l = _logs[i];
                            return Card(
                              child: ListTile(
                                leading: const Icon(Icons.security, color: Color(0xFF0D47A1)),
                                title: Text("${l['operacion'] ?? 'ACCION'} · ${l['moduloAfectado'] ?? ''}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text("${l['usuarioResponsable'] ?? 'SISTEMA'}\n${l['fechaHora'] ?? ''}"),
                                isThreeLine: true,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}