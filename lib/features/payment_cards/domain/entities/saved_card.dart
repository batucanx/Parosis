enum CardScheme { visa, mastercard, troy, other }

class SavedCard {
  final String id;
  final String label;
  final String last4;

  /// "MM/YY". Validated client-side for now; server-side validation replaces
  /// this once a real card/BIN API exists (see [validateCardExpiry]).
  final String expiry;
  final String holderName;
  final CardScheme scheme;
  final bool isPrimary;

  const SavedCard({
    required this.id,
    required this.label,
    required this.last4,
    required this.expiry,
    required this.holderName,
    required this.scheme,
    required this.isPrimary,
  });

  SavedCard copyWith({String? label, String? expiry, bool? isPrimary}) =>
      SavedCard(
        id: id,
        label: label ?? this.label,
        last4: last4,
        expiry: expiry ?? this.expiry,
        holderName: holderName,
        scheme: scheme,
        isPrimary: isPrimary ?? this.isPrimary,
      );
}
