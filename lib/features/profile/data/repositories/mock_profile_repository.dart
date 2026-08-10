import 'package:parosis_sulama/core/result/result.dart';
import 'package:parosis_sulama/features/profile/domain/entities/user.dart';
import 'package:parosis_sulama/features/profile/domain/repositories/profile_repository.dart';

/// No login flow exists yet — the app runs as a single signed-in mock user
/// until a real auth API is defined. Swapping this for a `RemoteProfileRepository`
/// backed by an authenticated session is the only change needed later.
final class MockProfileRepository implements ProfileRepository {
  final User _user = const User(
    id: 'SLM-48210',
    fullName: 'Batuhan Canaracı',
    email: 'batuhancanaraci85@gmail.com',
    phone: '0532 118 04 76',
    statusLabel: 'Aktif Üye',
  );

  @override
  Future<Result<User>> getCurrentUser() async => Result.ok(_user);
}
