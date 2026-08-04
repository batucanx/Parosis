import 'package:flutter_test/flutter_test.dart';

import 'package:sulama_mobile/main.dart';

void main() {
  testWidgets('App açılır ve ana ekran görünür', (WidgetTester tester) async {
    await tester.pumpWidget(const SulamaApp());
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Ana Sayfa'), findsOneWidget);
  });
}
