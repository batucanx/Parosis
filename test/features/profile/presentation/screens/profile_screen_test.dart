import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parosis_sulama/features/auth/domain/entities/auth_user.dart';
import 'package:parosis_sulama/features/payment_cards/data/repositories/mock_payment_cards_repository.dart';
import 'package:parosis_sulama/features/payment_cards/presentation/controllers/payment_cards_controller.dart';
import 'package:parosis_sulama/features/profile/data/repositories/mock_profile_repository.dart';
import 'package:parosis_sulama/features/profile/presentation/controllers/profile_controller.dart';
import 'package:parosis_sulama/features/profile/presentation/screens/profile_screen.dart';

const _testAuthUser = AuthUser(
  id: 'SLM-00001',
  fullName: 'Test Kullanıcı',
  email: 'test@parosis.com',
  phone: '05000000000',
);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  for (final (rowLabel, title, detail) in [
    ('Kullanıcı Bilgileri', 'Kullanıcı Bilgileri', 'Kullanıcı ID'),
    ('İletişim Bilgileri', 'İletişim Bilgileri', 'Telefon'),
  ]) {
    testWidgets('$rowLabel satırı tam ekran $title sayfasını açar', (
      tester,
    ) async {
      final controller = ProfileController(
        repository: MockProfileRepository(
          currentAuthUser: () => _testAuthUser,
        ),
      );
      addTearDown(controller.dispose);
      final paymentCardsController = PaymentCardsController(
        repository: MockPaymentCardsRepository(
          currentUserId: () => _testAuthUser.id,
        ),
      );
      addTearDown(paymentCardsController.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileScreen(
              profileController: controller,
              paymentCardsController: paymentCardsController,
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
