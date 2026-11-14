// Solo se compila en Web (importación condicional en file_saver.dart).
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

/// Descarga el archivo desde el navegador. Devuelve el nombre descargado.
Future<String> guardarYAbrirArchivo(List<int> bytes, String nombreArchivo) async {
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', nombreArchivo)
    ..click();
  html.Url.revokeObjectUrl(url);
  return nombreArchivo;
}
