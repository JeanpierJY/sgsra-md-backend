import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/api_constants.dart';
import '../constants/app_colors.dart';
import '../errors/exceptions.dart';
import '../network/dio_client.dart';

/// [GEN-01] Miniatura de un repuesto o herramienta.
/// Si no hay foto (o no carga) muestra un ícono; al tocarla se amplía.
class ImagenProducto extends StatelessWidget {
  final String? url;
  final double size;
  final IconData iconoVacio;
  final Color? color;
  final bool ampliable;
  final double radio;

  const ImagenProducto({
    super.key,
    required this.url,
    this.size = 52,
    this.iconoVacio = Icons.build_circle_outlined,
    this.color,
    this.ampliable = true,
    this.radio = 10,
  });

  @override
  Widget build(BuildContext context) {
    final u = ApiService.urlRecurso(url);
    final c = color ?? AppColors.primaryBlue;
    final vacio = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: c.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(radio)),
      child: Icon(iconoVacio, color: c, size: size * 0.5),
    );

    String? localAsset;
    final cleanUrl = (url ?? '').trim();
    if (cleanUrl.isNotEmpty) {
      final fileName = cleanUrl.split('/').last;
      final code = fileName.split('.').first.split('_').first.trim().toUpperCase();
      if (code.startsWith('P-')) {
        localAsset = 'assets/images/repuestos/$code.png';
      } else if (code.startsWith('HER-')) {
        localAsset = 'assets/images/herramientas/$code.png';
      } else {
        final matchP = RegExp(r'P-[A-Z0-9]+-[0-9]+', caseSensitive: false).firstMatch(cleanUrl);
        final matchHer = RegExp(r'HER-[A-Z0-9]+-[0-9]+', caseSensitive: false).firstMatch(cleanUrl);
        if (matchP != null) {
          localAsset = 'assets/images/repuestos/${matchP.group(0)!.toUpperCase()}.png';
        } else if (matchHer != null) {
          localAsset = 'assets/images/herramientas/${matchHer.group(0)!.toUpperCase()}.png';
        }
      }
    }

    Widget fallbackWidget = localAsset != null
        ? Image.asset(
            localAsset,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => vacio,
          )
        : vacio;

    if (u.isEmpty) {
      if (localAsset != null) {
        final imgLocal = ClipRRect(borderRadius: BorderRadius.circular(radio), child: fallbackWidget);
        return ampliable ? GestureDetector(onTap: () => ampliarImagen(context, localAsset!), child: imgLocal) : imgLocal;
      }
      return vacio;
    }

    final img = ClipRRect(
      borderRadius: BorderRadius.circular(radio),
      child: Image.network(
        u,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallbackWidget,
        loadingBuilder: (_, child, p) => p == null
            ? child
            : SizedBox(
                width: size,
                height: size,
                child: const Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))),
              ),
      ),
    );
    if (!ampliable) return img;
    return GestureDetector(onTap: () => ampliarImagen(context, u), child: img);
  }
}

/// Muestra la imagen a pantalla completa con zoom
void ampliarImagen(BuildContext context, String url) {
  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.all(12),
      child: Stack(
        children: [
          InteractiveViewer(
            child: Center(child: Image.network(url, fit: BoxFit.contain)),
          ),
          Positioned(
            right: 4,
            top: 4,
            child: IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(ctx),
            ),
          ),
        ],
      ),
    ),
  );
}

/// [GEN-01, ADM-08] Pide cámara o galería y sube la imagen al endpoint indicado
/// (parte multipart "imagen"). Devuelve la respuesta del backend o null si se canceló.
Future<Map<String, dynamic>?> seleccionarYSubirImagen(BuildContext context, String endpoint) async {
  final origen = await showModalBottomSheet<ImageSource>(
    context: context,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(14),
            child: Text('Cambiar imagen', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined, color: AppColors.primaryBlue),
            title: const Text('Tomar foto'),
            onTap: () => Navigator.pop(ctx, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined, color: AppColors.primaryBlue),
            title: const Text('Elegir de la galería'),
            onTap: () => Navigator.pop(ctx, ImageSource.gallery),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
  if (origen == null) return null;
  final foto = await ImagePicker().pickImage(source: origen, maxWidth: 1280, imageQuality: 80);
  if (foto == null) return null;
  if (!context.mounted) return null;
  final messenger = ScaffoldMessenger.of(context);
  messenger.showSnackBar(const SnackBar(content: Text('Subiendo imagen...'), duration: Duration(seconds: 1)));
  try {
    final bytes = await foto.readAsBytes();
    final res = await DioClient().dio.post(
      endpoint,
      data: FormData.fromMap({
        'imagen': MultipartFile.fromBytes(bytes, filename: 'foto.jpg', contentType: DioMediaType('image', 'jpeg')),
      }),
    );
    messenger.showSnackBar(SnackBar(content: const Text('Imagen actualizada'), backgroundColor: Colors.green[700]));
    return res.data is Map ? Map<String, dynamic>.from(res.data) : {};
  } catch (e) {
    messenger.showSnackBar(
        SnackBar(content: Text('No se pudo subir la imagen: ${mensajeDeError(e)}'), backgroundColor: AppColors.errorRed));
    return null;
  }
}
