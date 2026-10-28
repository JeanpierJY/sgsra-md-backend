import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/catalogo/catalogo_bloc.dart';
import '../../bloc/catalogo/catalogo_event.dart';
import '../../bloc/catalogo/catalogo_state.dart';
import 'solicitud_form_screen.dart';

class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CatalogoBloc>().add(FetchCatalogoRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Catálogo de Repuestos")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Buscar repuesto (ej: Bomba, Manguera)...",
                prefixIcon: const Icon(Icons.search, color: Color(0xFFFFB300)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<CatalogoBloc>().add(FetchCatalogoRequested());
                  },
                ),
              ),
              onChanged: (val) {
                context.read<CatalogoBloc>().add(SearchRepuestosRequested(val));
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<CatalogoBloc, CatalogoState>(
              builder: (context, state) {
                if (state is CatalogoLoading) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFFFB300)));
                } else if (state is CatalogoLoaded) {
                  if (state.repuestos.isEmpty) {
                    return const Center(child: Text("No se encontraron repuestos."));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: state.repuestos.length,
                    itemBuilder: (context, index) {
                      final item = state.repuestos[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(item.nombreRepuesto, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("Código: ${item.codParte}\nStock actual: ${item.stockActual} unidades"),
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(80, 36),
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            child: const Text("SOLICITAR"),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SolicitudFormScreen(repuestoInicial: item),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                } else if (state is CatalogoFailure) {
                  return Center(child: Text(state.error));
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}