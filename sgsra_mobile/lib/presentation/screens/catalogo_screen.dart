import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/catalogo_bloc.dart';
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
    context.read<CatalogoBloc>().add(CargarCatalogoRequested());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Catálogo Maestro de Repuestos")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (text) => context.read<CatalogoBloc>().add(BuscarRepuestosRequested(text)),
              decoration: const InputDecoration(
                labelText: "Buscar repuesto...", 
                prefixIcon: Icon(Icons.search, color: Color(0xFFFFB300)), 
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<CatalogoBloc, CatalogoState>(
              builder: (context, state) {
                if (state is CatalogoLoading) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFFFB300)));
                }
                if (state is CatalogoLoaded) {
                  final lista = _searchController.text.isNotEmpty ? state.sugerencias : state.items;
                  if (lista.isEmpty) {
                    return const Center(child: Text("No hay coincidencias."));
                  }
                  
                  return ListView.builder(
                    itemCount: lista.length,
                    itemBuilder: (context, index) {
                      final item = lista[index];
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          title: Text(item.nombreRepuesto),
                          subtitle: Text("Código: ${item.codParte}", style: const TextStyle(color: Color(0xFF29B6F6))),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SolicitudFormScreen(repuestoSeleccionado: item),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
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
