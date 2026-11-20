import 'dart:io';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

/// Guarda el archivo en la carpeta de Descargas (o documentos de la app si no existe)
/// y lo abre con la aplicación instalada (Excel, WPS, Sheets...). Devuelve la ruta.
Future<String> guardarYAbrirArchivo(List<int> bytes, String nombreArchivo) async {
  Directory? destino;
  try {
    destino = await getDownloadsDirectory();
  } catch (_) {
    destino = null;
  }
  destino ??= await getApplicationDocumentsDirectory();

  final archivo = File('${destino.path}${Platform.pathSeparator}$nombreArchivo');
  await archivo.writeAsBytes(bytes, flush: true);
  await OpenFilex.open(archivo.path);
  return archivo.path;
}
