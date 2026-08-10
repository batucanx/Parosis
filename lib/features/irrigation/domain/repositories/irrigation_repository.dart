import 'package:parosis_sulama/core/result/result.dart';
import 'package:parosis_sulama/features/irrigation/domain/entities/active_irrigation.dart';
import 'package:parosis_sulama/features/irrigation/domain/entities/past_irrigation.dart';
import 'package:parosis_sulama/features/irrigation/domain/entities/upcoming_irrigation.dart';

abstract interface class IrrigationRepository {
  Future<Result<List<ActiveIrrigation>>> getActiveIrrigations();
  Future<Result<List<UpcomingIrrigation>>> getUpcomingIrrigations();
  Future<Result<List<PastIrrigation>>> getPastIrrigations();

  /// Idempotent: returns the existing session if [wellId] is already active.
  Future<Result<ActiveIrrigation>> startIrrigation(String wellId);

  /// No-op (still succeeds) if [wellId] has no active session.
  Future<Result<bool>> stopIrrigation(String wellId);
}
