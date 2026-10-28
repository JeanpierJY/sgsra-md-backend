import 'package:flutter_test/flutter_test.dart';
import 'package:sgsra_mobile/main.dart';

void main() {
  testWidgets('Verificar inicio de la aplicacion SGSRA-MD', (WidgetTester tester) async {
    // Si la clase en main.dart se llama MyApp, usamos MyApp:
    await tester.pumpWidget(const SgsraMdFrontendApp());
    await tester.pumpAndSettle();

    expect(find.byType(SgsraMdFrontendApp), findsOneWidget);
  });
}