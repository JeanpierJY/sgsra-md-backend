import 'package:flutter/material.dart';
import '../../../data/services/api_service.dart';
import 'detalle_repuesto_dialog.dart';
import 'carrito_solicitud_sheet.dart';

class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchCtrl = TextEditingController();
  List<dynamic> _repuestos = [];
  List<dynamic> _repuestosFiltrados = [];
  bool _cargando = true;
  String _filtroTipo = "Todas";
  final Map<String, dynamic> _carrito = {};
  String? _userRol;

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    final datos = await _apiService.obtenerDatosUsuario();
    _userRol = datos['rol'] ?? 'MECANICO';
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
          _repuestosFiltrados = List.from(lista);
          _cargando = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _filtrarBusqueda(String txt) {
    final query = txt.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        if (_filtroTipo == "Todas") {
          _repuestosFiltrados = List.from(_repuestos);
        } else {
          _repuestosFiltrados = _repuestos.where((r) =>
            (r['nombreRepuesto'] ?? '').toString().toLowerCase().contains(_filtroTipo.toLowerCase())
          ).toList();
        }
      } else {
        _repuestosFiltrados = _repuestos.where((r) {
          final cod = (r['codParte'] ?? '').toString().toLowerCase();
          final nom = (r['nombreRepuesto'] ?? '').toString().toLowerCase();
          final coincideTexto = cod.contains(query) || nom.contains(query);
          if (_filtroTipo == "Todas") return coincideTexto;
          return coincideTexto && nom.contains(_filtroTipo.toLowerCase());
        }).toList();
      }
    });
  }

  void _abrirCarrito() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => CarritoSolicitudSheet(
        carrito: _carrito,
        onActualizar: () => setState(() {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int cantidadTotalCarrito = _carrito.values.fold(0, (sum, item) => sum + (item['cantidad'] as int));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Catalogo de Piezas Homologadas"),
        actions: [
          if (_userRol == 'MECANICO')
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_checkout, color: Color(0xFF0D47A1)),
                  onPressed: _abrirCarrito,
                ),
                if (cantidadTotalCarrito > 0)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: Text(
                        "$cantidadTotalCarrito",
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
              ],
            ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _cargarCatalogo),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: _filtrarBusqueda,
                    decoration: InputDecoration(
                      hintText: "Buscar repuesto (ej: Bomba, Filtro)...",
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchCtrl.clear();
                                _filtrarBusqueda("");
                              },
                            )
                          : null,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_list, color: Color(0xFF0D47A1)),
                  onSelected: (val) {
                    setState(() {
                      _filtroTipo = val;
                      _filtrarBusqueda(_searchCtrl.text);
                    });
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: "Todas", child: Text("Todas las categorias")),
                    PopupMenuItem(value: "Bomba", child: Text("Bombas")),
                    PopupMenuItem(value: "Manguera", child: Text("Mangueras")),
                    PopupMenuItem(value: "Filtro", child: Text("Filtros")),
                    PopupMenuItem(value: "Valvula", child: Text("Valvulas")),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : _repuestosFiltrados.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off, size: 64, color: Colors.grey),
                            const SizedBox(height: 12),
                            const Text("No se encontraron piezas en el catalogo."),
                            if (_searchCtrl.text.isNotEmpty)
                              TextButton(
                                onPressed: () {
                                  _searchCtrl.clear();
                                  _filtrarBusqueda("");
                                },
                                child: const Text("Limpiar busqueda"),
                              )
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _repuestosFiltrados.length,
                        itemBuilder: (context, idx) {
                          final r = _repuestosFiltrados[idx];
                          final cod = r['codParte'] ?? '';
                          final int stock = (r['stockActual'] is int) ? r['stockActual'] : int.tryParse('${r['stockActual']}') ?? 0;
                          final bool enCarrito = _carrito.containsKey(cod);
                          final int cantEnCarrito = enCarrito ? (_carrito[cod]['cantidad'] as int) : 0;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.blue.shade50,
                                    child: const Icon(Icons.settings, color: Color(0xFF0D47A1)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(r['nombreRepuesto'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 2),
                                        Text("Codigo: $cod", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                        Text(
                                          "Stock disponible: $stock unidades",
                                          style: TextStyle(
                                            color: stock > 5 ? const Color(0xFF2E7D32) : Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) => DetalleRepuestoDialog(
                                          repuesto: r,
                                          userRol: _userRol ?? 'MECANICO',
                                        ),
                                      );
                                    },
                                    child: const Text("Detalles"),
                                  ),
                                  if (_userRol == 'MECANICO')
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: enCarrito ? Colors.green : const Color(0xFF0D47A1),
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                      ),
                                      onPressed: () {
                                        if (cantEnCarrito >= stock) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text("No puedes solicitar mas del stock disponible ($stock uds.)")),
                                          );
                                          return;
                                        }
                                        setState(() {
                                          if (_carrito.containsKey(cod)) {
                                            _carrito[cod]['cantidad']++;
                                          } else {
                                            _carrito[cod] = {
                                              'codParte': cod,
                                              'nombreRepuesto': r['nombreRepuesto'],
                                              'stockMaximo': stock,
                                              'cantidad': 1,
                                            };
                                          }
                                        });
                                      },
                                      child: Text(enCarrito ? "+$cantEnCarrito" : "Anadir"),
                                    ),
                                ],
                              ),
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