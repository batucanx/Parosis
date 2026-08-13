import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:parosis_sulama/core/result/result.dart';
import 'package:parosis_sulama/features/auth/domain/entities/auth_user.dart';
import 'package:parosis_sulama/features/profile/domain/entities/user.dart';
import 'package:parosis_sulama/features/profile/domain/repositories/profile_repository.dart';

/// Oturum açan hesabın profil kaydını döner. Bir gerçek API'de "mevcut
/// kullanıcı" oturum token'ından çözülür; bu mock'ta aynı bilgiyi
/// composition root'un sağladığı [currentAuthUser] üzerinden okur —
/// `RemoteProfileRepository`'ye geçişte bu bağımlılık tamamen kalkar.
/// Adres bilgileri (login/kayıtta alınmayan alanlar) kullanıcı bazlı
/// `shared_preferences` anahtarında tutulur (bkz. `MockWellRequestRepository`
/// ile aynı desen).
final class MockProfileRepository implements ProfileRepository {
  MockProfileRepository({required AuthUser? Function() currentAuthUser})
    : _currentAuthUser = currentAuthUser;

  final AuthUser? Function() _currentAuthUser;

  static const _prefsKeyPrefix = 'profile_address_v1_';

  String _prefsKeyFor(String userId) => '$_prefsKeyPrefix$userId';

  Future<Map<String, String>> _loadAddress(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKeyFor(userId));
    if (raw == null) return const {};
    return (jsonDecode(raw) as Map).cast<String, String>();
  }

  Future<void> _persistAddress(String userId, Map<String, String> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKeyFor(userId), jsonEncode(data));
  }

  Future<User> _buildUser(AuthUser authUser) async {
    final address = await _loadAddress(authUser.id);
    return User(
      id: authUser.id,
      fullName: authUser.fullName,
      email: authUser.email,
      phone: authUser.phone,
      country: address['country'] ?? '',
      province: address['province'] ?? '',
      district: address['district'] ?? '',
      postalCode: address['postalCode'] ?? '',
      address: address['address'] ?? '',
    );
  }

  @override
  Future<Result<User>> getCurrentUser() async {
    final authUser = _currentAuthUser();
    if (authUser == null) {
      return Result.error(Exception('Oturum açılmamış.'));
    }
    return Result.ok(await _buildUser(authUser));
  }

  @override
  Future<Result<User>> updateAddress({
    required String country,
    required String province,
    required String district,
    required String postalCode,
    required String address,
  }) async {
    final authUser = _currentAuthUser();
    if (authUser == null) {
      return Result.error(Exception('Oturum açılmamış.'));
    }
    await _persistAddress(authUser.id, {
      'country': country,
      'province': province,
      'district': district,
      'postalCode': postalCode,
      'address': address,
    });
    return Result.ok(await _buildUser(authUser));
  }
}
