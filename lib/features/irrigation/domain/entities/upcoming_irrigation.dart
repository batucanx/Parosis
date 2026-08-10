class UpcomingIrrigation {
  final String id;
  final String wellId;
  final DateTime scheduledAt;
  final Duration duration;

  const UpcomingIrrigation({
    required this.id,
    required this.wellId,
    required this.scheduledAt,
    required this.duration,
  });
}
