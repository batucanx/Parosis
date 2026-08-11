/// Oturum açmış kullanıcının kimliği. `profile` feature'ının kendi [User]
/// modelinden ayrı tutulur — bu yalnızca auth oturumunu temsil eder.
final class AuthUser {
  const AuthUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
  });

  final String id;
  final String fullName;
  final String email;
  final String phone;
}
