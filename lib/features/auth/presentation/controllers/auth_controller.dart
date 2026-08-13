import 'package:flutter/foundation.dart';

import 'package:parosis_sulama/core/result/result.dart';
import 'package:parosis_sulama/features/auth/domain/entities/auth_user.dart';
import 'package:parosis_sulama/features/auth/domain/repositories/auth_repository.dart';

String _readableMessage(Object error) =>
    error.toString().replaceFirst('Exception: ', '');

/// Login/kayıt/şifremi-unuttum akışlarının tek doğruluk kaynağı. Uygulama
/// açılışında önceki oturumu geri yükler; [isAuthenticated] `AppGate`'in
/// hangi kök widget'ı göstereceğine karar vermesini sağlar.
final class AuthController extends ChangeNotifier {
  AuthController({required AuthRepository repository})
    : _repository = repository {
    _restoreSession();
  }

  final AuthRepository _repository;

  AuthUser? _user;
  bool _isRestoring = true;
  bool _isSubmitting = false;
  String? _error;

  AuthUser? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isRestoring => _isRestoring;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;

  Future<void> _restoreSession() async {
    _user = await _repository.restoreSession();
    _isRestoring = false;
    notifyListeners();
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) =>
      _submit(() => _repository.login(email: email, password: password));

  Future<bool> register({
    required String fullName,
    required String email,
    required String tcKimlik,
    required String phone,
    required String password,
  }) => _submit(
    () => _repository.register(
      fullName: fullName,
      email: email,
      tcKimlik: tcKimlik,
      phone: phone,
      password: password,
    ),
  );

  Future<bool> loginWithGoogle() =>
      _submit(() => _repository.loginWithGoogle());

  Future<bool> _submit(Future<Result<AuthUser>> Function() action) async {
    if (_isSubmitting) return false;
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    var success = false;
    switch (await action()) {
      case Ok<AuthUser>(:final value):
        _user = value;
        success = true;
      case Error<AuthUser>(:final error):
        _error = _readableMessage(error);
    }

    _isSubmitting = false;
    notifyListeners();
    return success;
  }

  Future<bool> sendPasswordResetLink({required String email}) async {
    if (_isSubmitting) return false;
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    var success = false;
    switch (await _repository.sendPasswordResetLink(email: email)) {
      case Ok<bool>():
        success = true;
      case Error<bool>(:final error):
        _error = _readableMessage(error);
    }

    _isSubmitting = false;
    notifyListeners();
    return success;
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_isSubmitting) return false;
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    var success = false;
    switch (await _repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    )) {
      case Ok<bool>():
        success = true;
      case Error<bool>(:final error):
        _error = _readableMessage(error);
    }

    _isSubmitting = false;
    notifyListeners();
    return success;
  }

  Future<void> logout() async {
    await _repository.logout();
    _user = null;
    notifyListeners();
  }
}
