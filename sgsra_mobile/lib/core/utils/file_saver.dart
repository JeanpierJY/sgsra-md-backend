// [RF30] Guardado de archivos exportados (Excel / CSV) independiente de la plataforma.
//
// Android/iOS usan `file_saver_io.dart` (path_provider + open_filex) y la versión Web
// usa `file_saver_web.dart`. Gracias a la importación condicional el APK nunca
// compila código de navegador (`dart:html`).
export 'file_saver_io.dart' if (dart.library.html) 'file_saver_web.dart';
