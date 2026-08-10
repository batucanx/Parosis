import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:parosis_sulama/core/result/result.dart';
import 'package:parosis_sulama/features/payment_cards/domain/entities/saved_card.dart';
import 'package:parosis_sulama/features/payment_cards/domain/repositories/payment_cards_repository.dart';

/// Persists only the fields already shown in the UI (label, last 4 digits,
/// expiry, holder name, scheme, primary flag) to on-device storage — never
/// the full card number or CVV/CVC, matching the app's card-storage notice.
/// A real backend + payment-provider tokenization replaces this store later
/// without changing [PaymentCardsRepository]'s contract.
final class MockPaymentCardsRepository implements PaymentCardsRepository {
  static const _prefsKey = 'payment_cards_v1';

  List<SavedCard>? _cache;
  int _nextId = 1000;

  List<SavedCard> _seedCards() => const [
    SavedCard(
      id: 'c1',
      label: 'Garanti Banka Kartım',
      last4: '4242',
      expiry: '08/27',
      holderName: 'BATUHAN CANARACI',
      scheme: CardScheme.visa,
      isPrimary: true,
    ),
    SavedCard(
      id: 'c2',
      label: 'Akbank Kredi Kartım',
      last4: '5500',
      expiry: '03/26',
      holderName: 'BATUHAN CANARACI',
      scheme: CardScheme.mastercard,
      isPrimary: false,
    ),
  ];

  Map<String, dynamic> _toJson(SavedCard card) => {
    'id': card.id,
    'label': card.label,
    'last4': card.last4,
    'expiry': card.expiry,
    'holderName': card.holderName,
    'scheme': card.scheme.name,
    'isPrimary': card.isPrimary,
  };

  SavedCard _fromJson(Map<String, dynamic> json) => SavedCard(
    id: json['id'] as String,
    label: json['label'] as String,
    last4: json['last4'] as String,
    expiry: json['expiry'] as String,
    holderName: json['holderName'] as String,
    scheme: CardScheme.values.byName(json['scheme'] as String),
    isPrimary: json['isPrimary'] as bool,
  );

  Future<List<SavedCard>> _ensureLoaded() async {
    final cached = _cache;
    if (cached != null) return cached;

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    final cards = raw == null
        ? _seedCards()
        : (jsonDecode(raw) as List)
              .map((e) => _fromJson(e as Map<String, dynamic>))
              .toList();

    _cache = cards;
    if (raw == null) await _persist();
    return cards;
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(_cache!.map(_toJson).toList()));
  }

  @override
  Future<Result<List<SavedCard>>> getCards() async =>
      Result.ok(List.unmodifiable(await _ensureLoaded()));

  @override
  Future<Result<SavedCard>> addCard({
    required String label,
    required String last4,
    required String expiry,
    required String holderName,
    required CardScheme scheme,
    required bool makePrimary,
  }) async {
    final cards = await _ensureLoaded();
    final shouldBePrimary = cards.isEmpty || makePrimary;
    final card = SavedCard(
      id: 'c${_nextId++}',
      label: label,
      last4: last4,
      expiry: expiry,
      holderName: holderName,
      scheme: scheme,
      isPrimary: shouldBePrimary,
    );

    _cache = [
      if (shouldBePrimary)
        ...cards.map((c) => c.copyWith(isPrimary: false))
      else
        ...cards,
      card,
    ];
    await _persist();
    return Result.ok(card);
  }

  @override
  Future<Result<SavedCard>> updateCard({
    required String id,
    required String label,
    required String expiry,
    required bool makePrimary,
  }) async {
    final cards = await _ensureLoaded();
    final index = cards.indexWhere((c) => c.id == id);
    if (index == -1) {
      return Result.error(Exception('Kart bulunamadı: $id'));
    }

    final target = cards[index].copyWith(
      label: label,
      expiry: expiry,
      isPrimary: makePrimary ? true : cards[index].isPrimary,
    );

    _cache = [
      for (var i = 0; i < cards.length; i++)
        if (i == index)
          target
        else if (makePrimary)
          cards[i].copyWith(isPrimary: false)
        else
          cards[i],
    ];
    await _persist();
    return Result.ok(target);
  }

  @override
  Future<Result<bool>> deleteCard(String id) async {
    final cards = await _ensureLoaded();
    final wasPrimary = cards.any((c) => c.id == id && c.isPrimary);
    final remaining = cards.where((c) => c.id != id).toList();

    _cache = wasPrimary && remaining.isNotEmpty
        ? [
            remaining.first.copyWith(isPrimary: true),
            ...remaining.skip(1).map((c) => c.copyWith(isPrimary: false)),
          ]
        : remaining;
    await _persist();
    return const Result.ok(true);
  }
}
