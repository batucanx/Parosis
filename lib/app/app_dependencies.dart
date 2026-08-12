import 'package:parosis_sulama/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:parosis_sulama/features/auth/presentation/controllers/auth_controller.dart';
import 'package:parosis_sulama/features/irrigation/data/repositories/mock_irrigation_repository.dart';
import 'package:parosis_sulama/features/irrigation/presentation/controllers/irrigation_controller.dart';
import 'package:parosis_sulama/features/payment_cards/data/repositories/mock_payment_cards_repository.dart';
import 'package:parosis_sulama/features/payment_cards/presentation/controllers/payment_cards_controller.dart';
import 'package:parosis_sulama/features/profile/data/repositories/mock_profile_repository.dart';
import 'package:parosis_sulama/features/profile/presentation/controllers/profile_controller.dart';
import 'package:parosis_sulama/features/wallet/data/repositories/mock_wallet_repository.dart';
import 'package:parosis_sulama/features/wallet/presentation/controllers/wallet_controller.dart';
import 'package:parosis_sulama/features/well_bookings/data/repositories/mock_well_booking_repository.dart';
import 'package:parosis_sulama/features/well_bookings/presentation/controllers/well_bookings_controller.dart';
import 'package:parosis_sulama/features/well_requests/data/repositories/mock_well_request_repository.dart';
import 'package:parosis_sulama/features/well_requests/presentation/controllers/well_requests_controller.dart';
import 'package:parosis_sulama/features/wells/data/repositories/mock_well_repository.dart';
import 'package:parosis_sulama/features/wells/presentation/controllers/wells_controller.dart';

/// Application-wide dependency container and composition root.
///
/// [AppDependencies.mock] wires every controller to an in-memory/mock
/// repository. A future `AppDependencies.remote(...)` factory wires the same
/// controllers to HTTP-backed repositories once an API contract exists —
/// screens and controllers never change, only which repository implements
/// each `abstract interface class`.
final class AppDependencies {
  AppDependencies({
    required this.authController,
    required this.wellsController,
    required this.irrigationController,
    required this.walletController,
    required this.profileController,
    required this.paymentCardsController,
    required this.wellRequestsController,
    required this.wellBookingsController,
  });

  factory AppDependencies.mock() {
    final authController = AuthController(repository: MockAuthRepository());
    // Kuyular paylaşımlı bir havuz (herkes aynı listeyi görür, bkz.
    // mock_well_repository.dart) — currentUserId'ye bağlı değil.
    final wellsController = WellsController(
      repository: MockWellRepository(),
    );
    final irrigationController = IrrigationController(
      repository: MockIrrigationRepository(
        currentUserId: () => authController.user?.id,
      ),
    );
    final profileController = ProfileController(
      repository: MockProfileRepository(
        currentAuthUser: () => authController.user,
      ),
    );
    final paymentCardsController = PaymentCardsController(
      repository: MockPaymentCardsRepository(
        currentUserId: () => authController.user?.id,
      ),
    );
    final wellRequestsController = WellRequestsController(
      repository: MockWellRequestRepository(
        currentUserId: () => authController.user?.id,
      ),
    );
    final wellBookingsController = WellBookingsController(
      repository: MockWellBookingRepository(
        currentUserId: () => authController.user?.id,
      ),
    );
    final walletController = WalletController(
      repository: MockWalletRepository(
        currentUserId: () => authController.user?.id,
      ),
    );
    // Login/kayıt/çıkış sonrası bakiye, aktif/geçmiş sulamalar, profil,
    // kayıtlı kartlar ve talepler, oturumdaki kullanıcıyla otomatik
    // güncellenir.
    authController.addListener(walletController.refresh);
    authController.addListener(irrigationController.refresh);
    authController.addListener(profileController.refresh);
    authController.addListener(paymentCardsController.refresh);
    authController.addListener(wellRequestsController.refresh);
    authController.addListener(wellBookingsController.refresh);

    return AppDependencies(
      authController: authController,
      wellsController: wellsController,
      irrigationController: irrigationController,
      walletController: walletController,
      profileController: profileController,
      paymentCardsController: paymentCardsController,
      wellRequestsController: wellRequestsController,
      wellBookingsController: wellBookingsController,
    );
  }

  final AuthController authController;
  final WellsController wellsController;
  final IrrigationController irrigationController;
  final WalletController walletController;
  final ProfileController profileController;
  final PaymentCardsController paymentCardsController;
  final WellRequestsController wellRequestsController;
  final WellBookingsController wellBookingsController;

  void dispose() {
    authController.dispose();
    wellsController.dispose();
    irrigationController.dispose();
    walletController.dispose();
    profileController.dispose();
    paymentCardsController.dispose();
    wellRequestsController.dispose();
    wellBookingsController.dispose();
  }
}
