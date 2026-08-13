import 'package:parosis_sulama/core/result/result.dart';
import 'package:parosis_sulama/features/auth/domain/entities/auth_user.dart';

abstract interface class AuthRepository {
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

  Future<Result<AuthUser>> loginWithGoogle();

  /// Gerçek bir e-posta servisi bağlanana kadar yalnızca hesabın var
  /// olduğunu doğrulayıp "gönderildi" sonucunu simüle eder.
  Future<Result<bool>> sendPasswordResetLink({required String email});

  /// Oturum açmış hesabın şifresini değiştirir. Hassas bir işlem olduğu
  /// için [currentPassword] ile yeniden kimlik doğrulaması gerektirir.
  Future<Result<bool>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> logout();
}
