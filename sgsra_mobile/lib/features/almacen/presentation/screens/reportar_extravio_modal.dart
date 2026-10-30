import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/datasources/almacen_remote_datasource.dart';
import '../../../../core/network/dio_client.dart';

void mostrarModalReportarExtravio(BuildContext context, VoidCallback onReportado) {
  final formKey = GlobalKey<FormState>();
  final codCtrl = TextEditingController();
  final motivoCtrl = TextEditingController(text: 'Herramienta extraviada en labor subterránea de mina');
  final dataSource = AlmacenRemoteDataSource(DioClient());

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Reportar Herramienta Extraviada [RF41]', style: TextStyle(color: AppColors.errorRed, fontWeight: FontWeight.bold)),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('La responsabilidad se imputará de forma automática al último custodio registrado en la bitácora [RF42].', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            TextFormField(
              controller: codCtrl,
              decoration: const InputDecoration(labelText: 'Código de Herramienta Extraviada', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Indique el código' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: motivoCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Circunstancias del Extravío (Mín. 10 car.)', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().length < 10) ? 'Debe fundamentar con al menos 10 caracteres' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
          onPressed: () async {
            if (formKey.currentState!.validate()) {
              Navigator.pop(ctx);
              try {
                final custodio = await dataSource.reportarExtravio(codCtrl.text.trim(), motivoCtrl.text.trim());
                onReportado();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Extravío asentado. Responsabilidad imputada a: $custodio [RF42]'), backgroundColor: AppColors.errorRed),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Aviso: $e'), backgroundColor: AppColors.errorRed),
                );
              }
            }
          },
          child: const Text('Confirmar Extravío [RF42]', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}