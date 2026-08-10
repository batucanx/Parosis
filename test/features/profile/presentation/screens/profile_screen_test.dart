import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parosis_sulama/features/profile/data/repositories/mock_profile_repository.dart';
import 'package:parosis_sulama/features/profile/presentation/controllers/profile_controller.dart';
import 'package:parosis_sulama/features/profile/presentation/screens/profile_screen.dart';

void main() {
  for (final (rowLabel, title, detail) in [
    ('Kullanıcı Bilgileri', 'Kullanıcı Bilgileri', 'Kullanıcı ID'),
    ('İletişim Bilgileri', 'İletişim Bilgileri', 'Telefon'),
  ]) {
    testWidgets('$rowLabel satırı tam ekran $title sayfasını açar', (
      tester,
    ) async {
      final controller = ProfileController(repository: MockProfileRepository());
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileScreen(
              profileController: controller,
              onOpenCards: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text(rowLabel));
      await tester.pumpAndSettle();

      expect(find.text(title), findsOneWidget);
      expect(find.text(detail), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.bySemanticsLabel('$title ekranını kapat'));
      await tester.pumpAndSettle();

      expect(find.text(rowLabel), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
