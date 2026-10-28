import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sgsra_mobile/presentation/catalogo/catalogo_bloc.dart';
import 'package:sgsra_mobile/presentation/catalogo/catalogo_event.dart';
import 'package:sgsra_mobile/presentation/catalogo/catalogo_state.dart';
import 'package:sgsra_mobile/presentation/screens/mecanico/solicitud_form_screen.dart';

class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CatalogoBloc>().add(CargarCatalogoRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Catalogo de Repuestos")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Buscar por nombre o codigo de parte...",
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (termino) {
                context.read<CatalogoBloc>().add(BuscarRepuestoPredictivoRequested(termino));
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<CatalogoBloc, CatalogoState>(
              builder: (context, state) {
                if (state is CatalogoLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CatalogoLoaded) {
                  return ListView.builder(
                    itemCount: state.repuestos.length,
                    itemBuilder: (context, index) {
                      final item = state.repuestos[index];
                      return ListTile(
                        title: Text(item.nombreRepuesto, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Codigo: ${item.codParte} | Stock: ${item.stockActual}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.add_shopping_cart, color: Color(0xFFFFB300)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SolicitudFormScreen(repuestoInicial: item),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                }
                return const Center(child: Text("No se encontraron repuestos"));
              },
            ),
          ),
        ],
      ),
    );
  }
}