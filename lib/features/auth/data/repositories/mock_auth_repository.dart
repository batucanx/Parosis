import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:parosis_sulama/core/result/result.dart';
import 'package:parosis_sulama/features/auth/domain/entities/auth_user.dart';
import 'package:parosis_sulama/features/auth/domain/repositories/auth_repository.dart';

class _Account {
  const _Account({
    required this.id,
    required this.fullName,
    required this.email,
    required this.tcKimlik,
    required this.phone,
    required this.password,
  });

  final String id;
  final String fullName;
  final String email;
  final String tcKimlik;
  final String phone;
  final String password;

  AuthUser toAuthUser() =>
      AuthUser(id: id, fullName: fullName, email: email, phone: phone);

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'email': email,
    'tcKimlik': tcKimlik,
    'phone': phone,
    'password': password,
  };

  static _Account fromJson(Map<String, dynamic> json) => _Account(
    id: json['id'] as String,
    fullName: json['fullName'] as String,
    email: json['email'] as String,
    tcKimlik: json['tcKimlik'] as String,
    phone: json['phone'] as String,
    password: json['password'] as String,
  );
}

/// Henüz bir API sözleşmesi yokken login/kayıt akışını uçtan uca test
/// edilebilir kılan yerel sahte "backend". Hesap listesi ve aktif oturum
/// cihazda `shared_preferences` ile saklanır; gerçek API geldiğinde bu
/// sınıfın yerini `RemoteAuthRepository` alır, [AuthRepository] sözleşmesi
/// değişmez.
final class MockAuthRepository implements AuthRepository {
  static const _accountsKey = 'auth_accounts_v1';
  static const _activeAccountIdKey = 'auth_active_account_id_v1';

  List<_Account>? _cache;
  int _nextSeq = 1;

  List<_Account> _seedAccounts() => const [
    _Account(
      id: 'SLM-10001',
      fullName: 'Demo Kullanıcı',
      email: 'demo@parosis.com',
      tcKimlik: '11111111110',
      phone: '05321180476',
      password: 'Parosis123!',
    ),
  ];

  Future<List<_Account>> _loadAccounts() async {
    if (_cache != null) return _cache!;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_accountsKey);
    if (raw == null) {
      _cache = _seedAccounts();
    } else {
      final decoded = jsonDecode(raw) as List<dynamic>;
      _cache = decoded
          .map((e) => _Account.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    _nextSeq = _cache!.length + 1;
    return _cache!;
  }

  Future<void> _persistAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _accountsKey,
      jsonEncode(_cache!.map((a) => a.toJson()).toList()),
    );
  }

  Future<void> _setActiveAccountId(String? id) async {
    final prefs = await SharedPreferences.getInstance();
    if (id == null) {
      await prefs.remove(_activeAccountIdKey);
    } else {
      await prefs.setString(_activeAccountIdKey, id);
    }
  }

  _Account? _findByEmail(List<_Account> accounts, String email) {
    final normalized = email.trim().toLowerCase();
    for (final account in accounts) {
      if (account.email.toLowerCase() == normalized) return account;
    }
    return null;
  }

  @override
  Future<AuthUser?> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final activeId = prefs.getString(_activeAccountIdKey);
    if (activeId == null) return null;

    final accounts = await _loadAccounts();
    for (final account in accounts) {
      if (account.id == activeId) return account.toAuthUser();
    }
    return null;
  }

  @override
  Future<Result<AuthUser>> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final accounts = await _loadAccounts();
    final account = _findByEmail(accounts, email);
    if (account == null || account.password != password) {
      return Result.error(Exception('E-posta veya şifre hatalı.'));
    }
    await _setActiveAccountId(account.id);
    return Result.ok(account.toAuthUser());
  }

  @override
  Future<Result<AuthUser>> register({
    required String fullName,
    required String email,
    required String tcKimlik,
    required String phone,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final accounts = await _loadAccounts();
    if (_findByEmail(accounts, email) != null) {
      return Result.error(Exception('Bu e-posta adresi zaten kayıtlı.'));
    }

    final account = _Account(
      id: 'SLM-${10000 + _nextSeq}',
      fullName: fullName.trim(),
      email: email.trim(),
      tcKimlik: tcKimlik.trim(),
      phone: phone.trim(),
      password: password,
    );
    _nextSeq += 1;
    accounts.add(account);
    await _persistAccounts();
    await _setActiveAccountId(account.id);
    return Result.ok(account.toAuthUser());
  }

  @override
  Future<Result<bool>> sendPasswordResetLink({required String email}) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final accounts = await _loadAccounts();
    if (_findByEmail(accounts, email) == null) {
      return Result.error(
        Exception('Bu e-posta ile kayıtlı bir hesap bulunamadı.'),
      );
    }
    return const Result.ok(true);
  }

  @override
  Future<void> logout() => _setActiveAccountId(null);
}
