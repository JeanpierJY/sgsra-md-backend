import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/catalogo_bloc.dart';

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
                labelText: "Buscar por nombre o código de parte...",
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
                } else if (state is CatalogoLoaded) {
                  final lista = _searchController.text.isNotEmpty ? state.sugerencias : state.items;
                  if (lista.isEmpty) return const Center(child: Text("No hay coincidencias."));
                  
                  return ListView.builder(
                    itemCount: lista.length,
                    itemBuilder: (context, index) {
                      final item = lista[index];
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          title: Text(item.nombreRepuesto),
                          subtitle: Text("Código Parte: ${item.codParte}", style: const TextStyle(color: Color(0xFF29B6F6))),
                          trailing: Text("Stock: ${item.stockActual}"),
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
