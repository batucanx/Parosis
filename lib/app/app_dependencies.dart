import 'package:parosis_sulama/features/irrigation/data/repositories/mock_irrigation_repository.dart';
import 'package:parosis_sulama/features/irrigation/presentation/controllers/irrigation_controller.dart';
import 'package:parosis_sulama/features/payment_cards/data/repositories/mock_payment_cards_repository.dart';
import 'package:parosis_sulama/features/payment_cards/presentation/controllers/payment_cards_controller.dart';
import 'package:parosis_sulama/features/profile/data/repositories/mock_profile_repository.dart';
import 'package:parosis_sulama/features/profile/presentation/controllers/profile_controller.dart';
import 'package:parosis_sulama/features/wallet/data/repositories/mock_wallet_repository.dart';
import 'package:parosis_sulama/features/wallet/presentation/controllers/wallet_controller.dart';
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
    required this.wellsController,
    required this.irrigationController,
    required this.walletController,
    required this.profileController,
    required this.paymentCardsController,
  });

  factory AppDependencies.mock() => AppDependencies(
    wellsController: WellsController(repository: MockWellRepository()),
    irrigationController: IrrigationController(
      repository: MockIrrigationRepository(),
    ),
    walletController: WalletController(repository: MockWalletRepository()),
    profileController: ProfileController(repository: MockProfileRepository()),
    paymentCardsController: PaymentCardsController(
      repository: MockPaymentCardsRepository(),
    ),
  );

  final WellsController wellsController;
  final IrrigationController irrigationController;
  final WalletController walletController;
  final ProfileController profileController;
  final PaymentCardsController paymentCardsController;

  void dispose() {
    wellsController.dispose();
    irrigationController.dispose();
    walletController.dispose();
    profileController.dispose();
    paymentCardsController.dispose();
  }
}
