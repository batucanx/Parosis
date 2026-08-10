import 'package:parosis_sulama/core/result/result.dart';
import 'package:parosis_sulama/features/payment_cards/domain/entities/saved_card.dart';

abstract interface class PaymentCardsRepository {
  Future<Result<List<SavedCard>>> getCards();

  /// The first saved card, or one explicitly requested via [makePrimary],
  /// becomes the primary card; the repository owns that invariant.
  Future<Result<SavedCard>> addCard({
    required String label,
    required String last4,
    required String expiry,
    required String holderName,
    required CardScheme scheme,
    required bool makePrimary,
  });

  Future<Result<SavedCard>> updateCard({
    required String id,
    required String label,
    required String expiry,
    required bool makePrimary,
  });

  /// If the deleted card was primary, the next remaining card (if any)
  /// becomes primary.
  Future<Result<bool>> deleteCard(String id);
}
