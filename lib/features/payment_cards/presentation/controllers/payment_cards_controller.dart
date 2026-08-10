import 'package:flutter/foundation.dart';

import 'package:parosis_sulama/core/result/result.dart';
import 'package:parosis_sulama/features/payment_cards/domain/entities/saved_card.dart';
import 'package:parosis_sulama/features/payment_cards/domain/repositories/payment_cards_repository.dart';

final class PaymentCardsController extends ChangeNotifier {
  PaymentCardsController({required PaymentCardsRepository repository})
    : _repository = repository {
    _load();
  }

  final PaymentCardsRepository _repository;

  List<SavedCard> _cards = const [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  Object? _error;

  List<SavedCard> get cards => _cards;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  Object? get error => _error;

  /// Primary card first, otherwise insertion order.
  List<SavedCard> get displayCards => [
    ..._cards.where((c) => c.isPrimary),
    ..._cards.where((c) => !c.isPrimary),
  ];

  Future<void> _load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      switch (await _repository.getCards()) {
        case Ok<List<SavedCard>>(:final value):
          _cards = value;
        case Error<List<SavedCard>>(:final error):
          _error = error;
      }
    } catch (error) {
      // Beklenmeyen bir hata (ör. platform kanalı henüz hazır değilken
      // çağrılması) kartlar listesini sonsuza dek "yükleniyor" durumunda
      // bırakmasın; her koşulda isLoading kapanır.
      _error = error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _refreshSilently() async {
    try {
      switch (await _repository.getCards()) {
        case Ok<List<SavedCard>>(:final value):
          _cards = value;
        case Error<List<SavedCard>>(:final error):
          _error = error;
      }
    } catch (error) {
      _error = error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> refresh() => _load();

  Future<SavedCard?> addCard({
    required String label,
    required String last4,
    required String expiry,
    required String holderName,
    required CardScheme scheme,
    required bool makePrimary,
  }) async {
    if (_isSubmitting) return null;
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    SavedCard? created;
    try {
      switch (await _repository.addCard(
        label: label,
        last4: last4,
        expiry: expiry,
        holderName: holderName,
        scheme: scheme,
        makePrimary: makePrimary,
      )) {
        case Ok<SavedCard>(:final value):
          created = value;
        case Error<SavedCard>(:final error):
          _error = error;
      }
      await _refreshSilently();
    } catch (error) {
      _error = error;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
    return created;
  }

  Future<SavedCard?> updateCard({
    required String id,
    required String label,
    required String expiry,
    required bool makePrimary,
  }) async {
    if (_isSubmitting) return null;
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    SavedCard? updated;
    try {
      switch (await _repository.updateCard(
        id: id,
        label: label,
        expiry: expiry,
        makePrimary: makePrimary,
      )) {
        case Ok<SavedCard>(:final value):
          updated = value;
        case Error<SavedCard>(:final error):
          _error = error;
      }
      await _refreshSilently();
    } catch (error) {
      _error = error;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
    return updated;
  }

  Future<bool> deleteCard(String id) async {
    if (_isSubmitting) return false;
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    var success = false;
    try {
      switch (await _repository.deleteCard(id)) {
        case Ok<bool>():
          success = true;
        case Error<bool>(:final error):
          _error = error;
      }
      await _refreshSilently();
    } catch (error) {
      _error = error;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
    return success;
  }
}
