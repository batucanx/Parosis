import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parosis_sulama/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:parosis_sulama/features/auth/domain/entities/auth_user.dart';
import 'package:parosis_sulama/features/auth/presentation/controllers/auth_controller.dart';
import 'package:parosis_sulama/features/irrigation/data/repositories/mock_irrigation_repository.dart';
import 'package:parosis_sulama/features/irrigation/presentation/controllers/irrigation_controller.dart';
import 'package:parosis_sulama/features/notifications/data/repositories/local_notification_preferences_repository.dart';
import 'package:parosis_sulama/features/notifications/presentation/controllers/notification_preferences_controller.dart';
import 'package:parosis_sulama/features/payment_cards/data/repositories/mock_payment_cards_repository.dart';
import 'package:parosis_sulama/features/payment_cards/presentation/controllers/payment_cards_controller.dart';
import 'package:parosis_sulama/features/profile/data/repositories/mock_profile_repository.dart';
import 'package:parosis_sulama/features/profile/presentation/controllers/profile_controller.dart';
import 'package:parosis_sulama/features/profile/presentation/screens/profile_screen.dart';
import 'package:parosis_sulama/features/well_bookings/data/repositories/mock_well_booking_repository.dart';
import 'package:parosis_sulama/features/well_bookings/presentation/controllers/well_bookings_controller.dart';

const _testAuthUser = AuthUser(
  id: 'SLM-00001',
  fullName: 'Test Kullanıcı',
  email: 'test@parosis.com',
  phone: '05000000000',
);

Widget _buildProfileScreen() {
  final controller = ProfileController(
    repository: MockProfileRepository(currentAuthUser: () => _testAuthUser),
  );
  final paymentCardsController = PaymentCardsController(
    repository: MockPaymentCardsRepository(
      currentUserId: () => _testAuthUser.id,
    ),
  );
  final wellBookingsController = WellBookingsController(
    repository: MockWellBookingRepository(
      currentUserId: () => _testAuthUser.id,
    ),
  );
  final irrigationController = IrrigationController(
    repository: MockIrrigationRepository(
      currentUserId: () => _testAuthUser.id,
    ),
  );
  final authController = AuthController(repository: MockAuthRepository());
  final notificationPreferencesController = NotificationPreferencesController(
    repository: LocalNotificationPreferencesRepository(
      currentUserId: () => _testAuthUser.id,
    ),
  );

  return Scaffold(
    body: ProfileScreen(
      profileController: controller,
      paymentCardsController: paymentCardsController,
      irrigationController: irrigationController,
      wellBookingsController: wellBookingsController,
      authController: authController,
      notificationPreferencesController: notificationPreferencesController,
      onOpenAddressInfo: () {},
      onLogout: () {},
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Profil başlığında kullanıcı ID gösterilmiyor', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: _buildProfileScreen()),
    );
    await tester.pump();

    expect(find.text(_testAuthUser.id), findsNothing);
    expect(find.text('Pasif Üye'), findsOneWidget);
  });

  testWidgets(
    'Kullanıcı Bilgilerim satırı Ad Soyad/E-posta/Telefon içeren sayfayı açar',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: _buildProfileScreen()),
      );
      await tester.pump();

      expect(find.text('Ad Soyad'), findsNothing);

      // Not pumpAndSettle(): the profile header card carries a perpetual
      // ambient glow/pulse animation, so pumpAndSettle would wait forever
      // for it to finish. A bounded pump covers the slide transition
      // instead (SlideUpPageRoute's forward duration is 320ms).
      await tester.tap(find.text('Kullanıcı Bilgilerim'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Kullanıcı Bilgileri'), findsOneWidget);
      expect(find.text('Ad Soyad'), findsOneWidget);
      expect(find.text('E-posta'), findsOneWidget);
      expect(find.text('Telefon'), findsOneWidget);
      expect(find.text(_testAuthUser.id), findsNothing);
      expect(tester.takeException(), isNull);

      await tester.tap(
        find.bySemanticsLabel('Kullanıcı Bilgileri ekranını kapat'),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Kullanıcı Bilgilerim'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
