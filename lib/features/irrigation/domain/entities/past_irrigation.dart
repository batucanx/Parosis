class PastIrrigation {
  final String id;
  final String wellId;
  final DateTime occurredAt;
  final Duration duration;
  final double waterLiters;

  const PastIrrigation({
    required this.id,
    required this.wellId,
    required this.occurredAt,
    required this.duration,
    required this.waterLiters,
  });
}
