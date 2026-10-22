import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/main.dart';

void main() {
  testWidgets('shows hello world', (tester) async {
    await tester.pumpWidget(const PortfolioApp());
    expect(find.text('Hello, world!'), findsOneWidget);
  });
}