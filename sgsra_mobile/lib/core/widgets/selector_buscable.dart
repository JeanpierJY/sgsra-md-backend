import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// [ALM-02, ALM-03] Lista seleccionable con buscador, en una hoja inferior.
/// Filtra mientras se escribe con [textoBusqueda] y dibuja cada fila con [construir].
/// Devuelve el elemento elegido o null si se cerró.
Future<T?> mostrarSelectorBuscable<T>({
  required BuildContext context,
  required String titulo,
  required List<T> items,
  required String Function(T) textoBusqueda,
  required Widget Function(BuildContext, T) construir,
  String hint = 'Buscar...',
  String vacio = 'No hay coincidencias',
  bool Function(T)? habilitado,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.backgroundGray,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      builder: (ctx, scroll) => _Selector<T>(
        titulo: titulo,
        items: items,
        textoBusqueda: textoBusqueda,
        construir: construir,
        hint: hint,
        vacio: vacio,
        habilitado: habilitado,
        scroll: scroll,
      ),
    ),
  );
}

class _Selector<T> extends StatefulWidget {
  final String titulo;
  final List<T> items;
  final String Function(T) textoBusqueda;
  final Widget Function(BuildContext, T) construir;
  final String hint;
  final String vacio;
  final bool Function(T)? habilitado;
  final ScrollController scroll;

  const _Selector({
    required this.titulo,
    required this.items,
    required this.textoBusqueda,
    required this.construir,
    required this.hint,
    required this.vacio,
    required this.habilitado,
    required this.scroll,
  });

  @override
  State<_Selector<T>> createState() => _SelectorState<T>();
}

class _SelectorState<T> extends State<_Selector<T>> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final q = _q.trim().toLowerCase();
    final lista = q.isEmpty
        ? widget.items
        : widget.items.where((e) => widget.textoBusqueda(e).toLowerCase().contains(q)).toList();
    return Column(
      children: [
        Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.only(top: 10, bottom: 10),
          decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(4)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            Expanded(
              child: Text(widget.titulo,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
            ),
            Text('${lista.length}', style: const TextStyle(color: Colors.black54)),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
          child: TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: widget.hint,
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: AppColors.pureWhite,
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            onChanged: (v) => setState(() => _q = v),
          ),
        ),
        Expanded(
          child: lista.isEmpty
              ? ListView(controller: widget.scroll, children: [
                  const SizedBox(height: 50),
                  Icon(Icons.search_off_rounded, size: 52, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Center(child: Text(widget.vacio, style: const TextStyle(color: Colors.grey))),
                ])
              : ListView.builder(
                  controller: widget.scroll,
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                  itemCount: lista.length,
                  itemBuilder: (ctx, i) {
                    final e = lista[i];
                    final ok = widget.habilitado?.call(e) ?? true;
                    return Opacity(
                      opacity: ok ? 1 : 0.45,
                      child: Card(
                        color: AppColors.pureWhite,
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: ok ? () => Navigator.pop(context, e) : null,
                          child: Padding(padding: const EdgeInsets.all(10), child: widget.construir(ctx, e)),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// Campo de formulario que abre un selector buscable (en lugar de un desplegable)
class CampoSelector extends StatelessWidget {
  final String etiqueta;
  final IconData icono;
  final Widget? valor;
  final String placeholder;
  final VoidCallback? onTap;

  const CampoSelector({
    super.key,
    required this.etiqueta,
    required this.icono,
    required this.valor,
    required this.placeholder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: etiqueta,
          prefixIcon: Icon(icono),
          suffixIcon: const Icon(Icons.search_rounded),
          border: const OutlineInputBorder(),
        ),
        child: valor ?? Text(placeholder, style: const TextStyle(color: Colors.black45)),
      ),
    );
  }
}
