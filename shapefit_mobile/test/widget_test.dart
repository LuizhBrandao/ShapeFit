import 'package:flutter_test/flutter_test.dart';
import 'package:shapefit_mobile/main.dart';

void main() {
  testWidgets('App starts with ShapeFit title', (WidgetTester tester) async {
    await tester.pumpWidget(const ShapeFitApp());
    expect(find.text('INICIAR NOVO TREINO'), findsOneWidget);
  });
}
