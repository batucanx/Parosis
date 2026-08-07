import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parosis_sulama/screens/profile_screen.dart';

void main() {
  testWidgets('profil satırları tip güvenli bölüm seçimi bildirir', (
    tester,
  ) async {
    ProfileInfoSection? selectedSection;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileScreen(
            onOpenCards: () {},
            onOpenSheet: (section) => selectedSection = section,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Kullanıcı Bilgileri'));
    expect(selectedSection, ProfileInfoSection.user);

    await tester.tap(find.text('İletişim Bilgileri'));
    expect(selectedSection, ProfileInfoSection.contact);
  });

  for (final (section, title, detail) in [
    (ProfileInfoSection.user, 'Kullanıcı Bilgileri', 'Kullanıcı ID'),
    (ProfileInfoSection.contact, 'İletişim Bilgileri', 'Telefon'),
  ]) {
    testWidgets('$title paneli doğru içeriği gösterir', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileInfoSheet(section: section, onClose: () {}),
          ),
        ),
      );

      expect(find.text(title), findsOneWidget);
      expect(find.text(detail), findsOneWidget);
    });
  }
}
