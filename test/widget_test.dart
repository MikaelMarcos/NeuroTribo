import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_tribo/main.dart'; // Importa seu app correto

void main() {
  testWidgets('Teste de inicialização do app', (WidgetTester tester) async {
    // Constrói o app e dispara um frame.
    // CORREÇÃO: Mudamos de MyApp() para NeuroTriboApp()
    await tester.pumpWidget(const NeuroTriboApp());

    // Como usamos Firebase, testes profundos exigiriam configurações extras (Mocks).
    // Por enquanto, este teste apenas garante que a classe principal do app existe e compila.
  });
}