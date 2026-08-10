import 'package:parosis_sulama/core/result/result.dart';
import 'package:parosis_sulama/features/irrigation/domain/entities/active_irrigation.dart';
import 'package:parosis_sulama/features/irrigation/domain/entities/past_irrigation.dart';
import 'package:parosis_sulama/features/irrigation/domain/entities/upcoming_irrigation.dart';
import 'package:parosis_sulama/features/irrigation/domain/repositories/irrigation_repository.dart';

/// In-memory stand-in for the irrigation API. One session starts already
/// running so the "active irrigation" UI has something real to tick against
/// on first launch, matching the original prototype's demo state.
final class MockIrrigationRepository implements IrrigationRepository {
  MockIrrigationRepository()
    : _active = [
        ActiveIrrigation(
          id: 'a1',
          wellId: 'k1',
          startedAt: DateTime.now().subtract(
            const Duration(hours: 2, minutes: 34, seconds: 11),
          ),
        ),
      ];

  final List<ActiveIrrigation> _active;
  int _nextActiveId = 2;

  final List<UpcomingIrrigation> _upcoming = [
    UpcomingIrrigation(
      id: 'p1',
      wellId: 'k1',
      scheduledAt: DateTime(2026, 8, 4, 5, 0),
      duration: const Duration(minutes: 60),
    ),
    UpcomingIrrigation(
      id: 'p2',
      wellId: 'k4',
      scheduledAt: DateTime(2026, 8, 5, 6, 30),
      duration: const Duration(minutes: 45),
    ),
    UpcomingIrrigation(
      id: 'p3',
      wellId: 'k3',
      scheduledAt: DateTime(2026, 8, 6, 5, 30),
      duration: const Duration(minutes: 90),
    ),
  ];

  final List<PastIrrigation> _past = [
    PastIrrigation(
      id: 'g1',
      wellId: 'k1',
      occurredAt: DateTime(2026, 8, 2, 6, 30),
      duration: const Duration(minutes: 45),
      waterLiters: 1250,
    ),
    PastIrrigation(
      id: 'g2',
      wellId: 'k3',
      occurredAt: DateTime(2026, 8, 1, 5, 0),
      duration: const Duration(minutes: 60),
      waterLiters: 1680,
    ),
    PastIrrigation(
      id: 'g3',
      wellId: 'k2',
      occurredAt: DateTime(2026, 7, 31, 6, 0),
      duration: const Duration(minutes: 30),
      waterLiters: 820,
    ),
  ];

  @override
  Future<Result<List<ActiveIrrigation>>> getActiveIrrigations() async =>
      Result.ok(List.unmodifiable(_active));

  @override
  Future<Result<List<UpcomingIrrigation>>> getUpcomingIrrigations() async =>
      Result.ok(List.unmodifiable(_upcoming));

  @override
  Future<Result<List<PastIrrigation>>> getPastIrrigations() async =>
      Result.ok(List.unmodifiable(_past));

  @override
  Future<Result<ActiveIrrigation>> startIrrigation(String wellId) async {
    final existing = _active.where((i) => i.wellId == wellId).firstOrNull;
    if (existing != null) return Result.ok(existing);

    final session = ActiveIrrigation(
      id: 'a${_nextActiveId++}',
      wellId: wellId,
      startedAt: DateTime.now(),
    );
    _active.add(session);
    return Result.ok(session);
  }

  @override
  Future<Result<bool>> stopIrrigation(String wellId) async {
    _active.removeWhere((i) => i.wellId == wellId);
    return const Result.ok(true);
  }
}
