class PastIrrigation {
  final String id;
  final String wellId;

  /// Bu oturumu başlatan kişi. Kuyu sahipliği/paylaşımlı havuz henüz
  /// modellenmediği için (bkz. memory `project_well_ownership_deferred`)
  /// gerçek bir kullanıcı kimliğine bağlı değil, sadece görüntüleme ismi.
  final String personName;
  final DateTime occurredAt;
  final Duration duration;
  final double waterLiters;

  const PastIrrigation({
    required this.id,
    required this.wellId,
    required this.personName,
    required this.occurredAt,
    required this.duration,
    required this.waterLiters,
  });
}
