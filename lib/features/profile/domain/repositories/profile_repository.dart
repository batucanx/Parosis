import 'package:parosis_sulama/core/result/result.dart';
import 'package:parosis_sulama/features/profile/domain/entities/user.dart';

abstract interface class ProfileRepository {
  Future<Result<User>> getCurrentUser();
}
