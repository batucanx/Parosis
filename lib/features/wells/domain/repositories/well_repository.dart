import 'package:parosis_sulama/core/result/result.dart';
import 'package:parosis_sulama/features/wells/domain/entities/well.dart';

abstract interface class WellRepository {
  Future<Result<List<Well>>> getWells();
  Future<Result<Well?>> getWellById(String id);
}
