import 'package:parosis_sulama/core/result/result.dart';
import 'package:parosis_sulama/features/auth/domain/entities/auth_user.dart';

abstract interface class AuthRepository {
  /// Uygulama açılışında daha önce açılmış bir oturum var mı diye bakar.
  Future<AuthUser?> restoreSession();

  Future<Result<AuthUser>> login({
    required String email,
    required String password,
  });

  Future<Result<AuthUser>> register({
    required String fullName,
    required String email,
    required String tcKimlik,
    required String phone,
    required String password,
  });

  /// Gerçek bir e-posta servisi bağlanana kadar yalnızca hesabın var
  /// olduğunu doğrulayıp "gönderildi" sonucunu simüle eder.
  Future<Result<bool>> sendPasswordResetLink({required String email});

  Future<void> logout();
}
