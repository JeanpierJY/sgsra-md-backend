import 'package:flutter/material.dart';
import '../../../data/services/api_service.dart';

class GestionCatalogoTab extends StatefulWidget {
  const GestionCatalogoTab({super.key});

  @override
  State<GestionCatalogoTab> createState() => _GestionCatalogoTabState();
}

class _GestionCatalogoTabState extends State<GestionCatalogoTab> {
  final ApiService _apiService = ApiService();
  List<dynamic> _repuestos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarCatalogo();
  }

  Future<void> _cargarCatalogo() async {
    setState(() => _cargando = true);
    try {
      final res = await _apiService.obtenerCatalogo();
      if (mounted) {
        List<dynamic> lista = [];
        if (res.data is List) {
          lista = res.data;
        } else if (res.data is Map && res.data['content'] != null) {
          lista = res.data['content'] as List;
        }
        setState(() {
          _repuestos = lista;
          _cargando = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _modalCrearRepuesto() {
    final formKey = GlobalKey<FormState>();
    final codCtrl = TextEditingController();
    final nomCtrl = TextEditingController();
    final stockCtrl = TextEditingController(text: "10");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Registrar Componente en Catalogo"),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: codCtrl,
                decoration: const InputDecoration(labelText: "Codigo de Parte (ej: P-HEX-001)", border: OutlineInputBorder()),
                validator: (v) => v == null || v.trim().isEmpty ? "Codigo requerido" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: nomCtrl,
                decoration: const InputDecoration(labelText: "Nombre Tecnico", border: OutlineInputBorder()),
                validator: (v) => v == null || v.trim().isEmpty ? "Nombre requerido" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: stockCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Stock Inicial", border: OutlineInputBorder()),
                validator: (v) => v == null || int.tryParse(v) == null ? "Stock invalido" : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx);
                setState(() => _cargando = true);
                try {
                  await _apiService.crearRepuestoCatalogo({
                    'codParte': codCtrl.text.trim(),
                    'nombreRepuesto': nomCtrl.text.trim(),
                    'stockActual': int.parse(stockCtrl.text.trim()),
                    'stockMinimo': 2,
                    'descripcion': 'Repuesto homologado',
                    'activo': true,
                  });
                  _cargarCatalogo();
                } catch (_) {
                  setState(() => _cargando = false);
                }
              }
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Administracion de Catalogo"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _cargarCatalogo),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0D47A1),
        onPressed: _modalCrearRepuesto,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _repuestos.length,
              itemBuilder: (context, idx) {
                final r = _repuestos[idx];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.build_circle, color: Color(0xFF0D47A1)),
                    title: Text(r['nombreRepuesto'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Codigo: ${r['codParte']} · Stock Actual: ${r['stockActual']}"),
                  ),
                );
              },
            ),
    );
  }
}