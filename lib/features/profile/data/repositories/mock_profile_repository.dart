import 'package:parosis_sulama/core/result/result.dart';
import 'package:parosis_sulama/features/auth/domain/entities/auth_user.dart';
import 'package:parosis_sulama/features/profile/domain/entities/user.dart';
import 'package:parosis_sulama/features/profile/domain/repositories/profile_repository.dart';

/// Oturum açan hesabın profil kaydını döner. Bir gerçek API'de "mevcut
/// kullanıcı" oturum token'ından çözülür; bu mock'ta aynı bilgiyi
/// composition root'un sağladığı [currentAuthUser] üzerinden okur —
/// `RemoteProfileRepository`'ye geçişte bu bağımlılık tamamen kalkar.
final class MockProfileRepository implements ProfileRepository {
  MockProfileRepository({required AuthUser? Function() currentAuthUser})
    : _currentAuthUser = currentAuthUser;

  final AuthUser? Function() _currentAuthUser;

  @override
  Future<Result<User>> getCurrentUser() async {
    final authUser = _currentAuthUser();
    if (authUser == null) {
      return Result.error(Exception('Oturum açılmamış.'));
    }
    return Result.ok(
      User(
        id: authUser.id,
        fullName: authUser.fullName,
        email: authUser.email,
        phone: authUser.phone,
        statusLabel: 'Aktif Üye',
      ),
    );
  }
}
