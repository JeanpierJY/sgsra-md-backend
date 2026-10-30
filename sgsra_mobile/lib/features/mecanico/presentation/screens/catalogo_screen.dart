import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/repuesto_entity.dart';
import '../../data/datasources/repuesto_remote_datasource.dart';
import '../../../../core/network/dio_client.dart';
import 'detalle_repuesto_modal.dart';
import 'carrito_pedido_screen.dart';

class CatalogoScreen extends StatefulWidget {
  final Map<RepuestoEntity, int> carritoGlobal;
  final VoidCallback onCarritoActualizado;

  const CatalogoScreen({
    Key? key,
    required this.carritoGlobal,
    required this.onCarritoActualizado,
  }) : super(key: key);

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  final RepuestoRemoteDataSource _dataSource = RepuestoRemoteDataSource(DioClient());
  final TextEditingController _buscarCtrl = TextEditingController();

  bool _isLoading = true;
  List<RepuestoEntity> _repuestos = [];
  String _filtroTipo = 'TODOS';

  @override
  void initState() {
    super.initState();
    _cargarCatalogo();
  }

  Future<void> _cargarCatalogo() async {
    setState(() => _isLoading = true);
    try {
      final query = _buscarCtrl.text.trim();
      List<RepuestoEntity> lista;
      if (query.isNotEmpty) {
        lista = await _dataSource.buscarPredictivo(query);
      } else if (_filtroTipo != 'TODOS') {
        lista = await _dataSource.buscarPredictivo(_filtroTipo);
      } else {
        lista = await _dataSource.listarCatalogo();
      }

      setState(() {
        _repuestos = lista;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al conectar con catalogo: $e'), backgroundColor: AppColors.errorRed),
      );
    }
  }

  void _agregarAlCarrito(RepuestoEntity item, int cantidad) {
    setState(() {
      widget.carritoGlobal[item] = (widget.carritoGlobal[item] ?? 0) + cantidad;
    });
    widget.onCarritoActualizado();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Se anadieron $cantidad unid(s) de ${item.nombre} al carrito')),
    );
  }

  void _mostrarDetalleRepuesto(RepuestoEntity item) {
    int cantidad = 1;
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.nombre, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('Código: ${item.codParte}'),
              Text('Stock disponible: ${item.stockDisponible}'),
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton(
                    onPressed: cantidad > 1 ? () => setModalState(() => cantidad--) : null,
                    icon: const Icon(Icons.remove),
                  ),
                  Text('$cantidad'),
                  IconButton(
                    onPressed: cantidad < item.stockDisponible
                        ? () => setModalState(() => cantidad++)
                        : null,
                    icon: const Icon(Icons.add),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: item.stockDisponible > 0
                        ? () {
                            Navigator.pop(context);
                            _agregarAlCarrito(item, cantidad);
                          }
                        : null,
                    child: const Text('Agregar al carrito'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalItemsCarrito = widget.carritoGlobal.values.fold(0, (acc, c) => acc + c);

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: const Text('Catalogo de Repuestos [RF09]', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryBlue,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CarritoPedidoScreen(
                        carrito: widget.carritoGlobal,
                        onCarritoActualizado: () {
                          setState(() {});
                          widget.onCarritoActualizado();
                        },
                      ),
                    ),
                  );
                },
              ),
              if (totalItemsCarrito > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: AppColors.errorRed, shape: BoxShape.circle),
                    child: Text('$totalItemsCarrito', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _cargarCatalogo),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.pureWhite,
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: _buscarCtrl,
                  decoration: InputDecoration(
                    hintText: 'Buscador predictivo (ej. Bomba, Filtro, Valvula) [RF10]',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _buscarCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _buscarCtrl.clear();
                              _cargarCatalogo();
                            },
                          )
                        : null,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (val) {
                    if (val.length >= 2 || val.isEmpty) {
                      _cargarCatalogo();
                    }
                  },
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['TODOS', 'HIDRAULICO', 'FILTRO', 'MOTOR', 'VALVULA'].map((cat) {
                      final sel = _filtroTipo == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: FilterChip(
                          selected: sel,
                          label: Text(cat),
                          selectedColor: AppColors.primaryBlue.withOpacity(0.2),
                          checkmarkColor: AppColors.primaryBlue,
                          onSelected: (_) {
                            setState(() {
                              _filtroTipo = cat;
                              _buscarCtrl.clear();
                            });
                            _cargarCatalogo();
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
                : _repuestos.isEmpty
                    ? const Center(child: Text('No hay repuestos registrados en el catalogo.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(14),
                        itemCount: _repuestos.length,
                        itemBuilder: (context, index) {
                          final item = _repuestos[index];
                          final tieneStock = item.stockDisponible > 0;

                          return Card(
                            color: AppColors.pureWhite,
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(14),
                              leading: CircleAvatar(
                                backgroundColor: tieneStock ? AppColors.primaryBlue : Colors.grey,
                                child: const Icon(Icons.build_circle_outlined, color: Colors.white),
                              ),
                              title: Text('${item.nombre} (${item.codParte})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Text('Stock Actual: ${item.stockDisponible} | Min: ${item.stockMinimo}\n${item.descripcion}'),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.add_shopping_cart, color: AppColors.primaryBlue),
                                onPressed: () => _mostrarDetalleRepuesto(item),
                              ),
                              onTap: () => _mostrarDetalleRepuesto(item),
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