import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/imagen_producto.dart';
import '../../domain/entities/repuesto_entity.dart';
import '../../data/datasources/repuesto_remote_datasource.dart';
import '../../../../core/network/dio_client.dart';
import 'carrito_pedido_screen.dart';
import '../../../notificaciones/presentation/widgets/notificacion_bell.dart';
import '../../../../core/widgets/perfil_boton.dart';

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
      SnackBar(content: Text('Se agregaron $cantidad unid(s) de ${item.nombre} a su solicitud')),
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
              Row(children: [
                ImagenProducto(url: item.urlFoto, size: 72),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(item.nombre, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Código: ${item.codParte}'),
                  ]),
                ),
              ]),
              const SizedBox(height: 8),
              Text(item.descripcion, style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 8),
              _StockResumen(item: item, enCarrito: widget.carritoGlobal[item] ?? 0),
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton(
                    onPressed: cantidad > 1 ? () => setModalState(() => cantidad--) : null,
                    icon: const Icon(Icons.remove),
                  ),
                  Text('$cantidad'),
                  IconButton(
                    onPressed: cantidad < item.stockLibre - (widget.carritoGlobal[item] ?? 0)
                        ? () => setModalState(() => cantidad++)
                        : null,
                    icon: const Icon(Icons.add),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: item.stockLibre - (widget.carritoGlobal[item] ?? 0) > 0
                        ? () {
                            Navigator.pop(context);
                            _agregarAlCarrito(item, cantidad);
                          }
                        : null,
                    child: const Text('Agregar a la solicitud'),
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
        title: const Text('Catálogo de Repuestos [RF09]', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryBlue,
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), tooltip: 'Actualizar', onPressed: _cargarCatalogo),
          const NotificacionBell(),
          const PerfilBoton(),
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
                          final tieneStock = item.stockLibre > 0;

                          return Card(
                            color: AppColors.pureWhite,
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(14),
                              leading: ImagenProducto(
                                url: item.urlFoto,
                                size: 56,
                                color: tieneStock ? AppColors.primaryBlue : Colors.grey,
                              ),
                              title: Text('${item.nombre} (${item.codParte})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _StockResumen(item: item, enCarrito: widget.carritoGlobal[item] ?? 0),
                                    const SizedBox(height: 4),
                                    Text(item.descripcion, maxLines: 2, overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryBlue),
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

/// [MEC-01] Stock en lenguaje claro: disponible para pedir, reservado y en su carrito.
/// El stock físico se descuenta recién cuando el almacén entrega los repuestos.
class _StockResumen extends StatelessWidget {
  final RepuestoEntity item;
  final int enCarrito;
  const _StockResumen({required this.item, required this.enCarrito});

  @override
  Widget build(BuildContext context) {
    final libre = item.stockLibre;
    final critico = libre <= item.stockMinimo;
    final color = libre == 0 ? AppColors.errorRed : (critico ? Colors.orange[800]! : Colors.green[700]!);
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        _chip(libre == 0 ? 'Sin stock libre' : '$libre disponibles', color, Icons.inventory_2_outlined),
        if (item.stockReservado > 0)
          _chip('${item.stockReservado} reservados', Colors.blueGrey, Icons.schedule_rounded),
        if (enCarrito > 0) _chip('$enCarrito en su solicitud', AppColors.primaryBlue, Icons.shopping_cart_outlined),
        _chip('Físico: ${item.stockDisponible} · Mín: ${item.stockMinimo}', Colors.grey[700]!, Icons.warehouse_outlined),
      ],
    );
  }

  Widget _chip(String t, Color c, IconData i) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: c.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(i, size: 13, color: c),
          const SizedBox(width: 4),
          Text(t, style: TextStyle(fontSize: 11.5, color: c, fontWeight: FontWeight.w600)),
        ]),
      );
}