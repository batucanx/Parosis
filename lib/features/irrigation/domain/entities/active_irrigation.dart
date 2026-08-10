/// A currently running irrigation session on a well.
///
/// Elapsed time is derived by presentation from [startedAt] against the wall
/// clock rather than stored as a pre-formatted string, so a live counter can
/// tick without any repository/controller polling.
class ActiveIrrigation {
  final String id;
  final String wellId;
  final DateTime startedAt;

  /// Null means unlimited ("sınırsız") — irrigation runs until stopped.
  final Duration? plannedDuration;

  const ActiveIrrigation({
    required this.id,
    required this.wellId,
    required this.startedAt,
    this.plannedDuration,
  });
}
