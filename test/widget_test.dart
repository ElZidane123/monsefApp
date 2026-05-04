import 'package:flutter_test/flutter_test.dart';
import 'package:monsef/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FintechApp());
    expect(find.byType(FintechApp), findsOneWidget);
  });
}
