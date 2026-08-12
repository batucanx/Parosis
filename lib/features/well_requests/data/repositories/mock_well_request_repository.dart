import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:parosis_sulama/core/result/result.dart';
import 'package:parosis_sulama/features/well_requests/domain/entities/well_request.dart';
import 'package:parosis_sulama/features/well_requests/domain/repositories/well_request_repository.dart';

/// Talep listesini oturum açan hesaba göre ayrı `shared_preferences`
/// anahtarında tutar (bkz. `MockPaymentCardsRepository`'deki aynı desen).
/// Sadece sabit demo hesap örnek bir bekleyen talep ile başlar; her gerçek
/// kullanıcı boş listeyle başlar. Gerçek API geldiğinde onay, yetkili
/// tarafından ayrı bir panelden verilir — bu mock, o onayı simüle etmez.
final class MockWellRequestRepository implements WellRequestRepository {
  MockWellRequestRepository({required String? Function() currentUserId})
    : _currentUserId = currentUserId;

  final String? Function() _currentUserId;

  static const _demoUserId = 'SLM-10001';
  static const _prefsKeyPrefix = 'well_requests_v1_';

  List<WellRequest>? _cache;
  String? _cacheUserId;
  int _nextId = 100;

  List<WellRequest> _seedRequests() => [
    WellRequest(
      id: 'wr1',
      name: 'kuyu talebi 1',
      country: 'Türkiye',
      province: 'Adana',
      district: 'Aladağ',
      neighborhood: '',
      postalCode: '',
      address: '',
      latitude: null,
      longitude: null,
      status: WellRequestStatus.pending,
      createdAt: DateTime(2026, 8, 1, 9, 45),
    ),
  ];

  Map<String, dynamic> _toJson(WellRequest r) => {
    'id': r.id,
    'name': r.name,
    'country': r.country,
    'province': r.province,
    'district': r.district,
    'neighborhood': r.neighborhood,
    'postalCode': r.postalCode,
    'address': r.address,
    'latitude': r.latitude,
    'longitude': r.longitude,
    'status': r.status.name,
    'createdAt': r.createdAt.toIso8601String(),
  };

  WellRequest _fromJson(Map<String, dynamic> json) => WellRequest(
    id: json['id'] as String,
    name: json['name'] as String,
    country: json['country'] as String,
    province: json['province'] as String,
    district: json['district'] as String,
    neighborhood: json['neighborhood'] as String,
    postalCode: json['postalCode'] as String,
    address: json['address'] as String,
    latitude: json['latitude'] as double?,
    longitude: json['longitude'] as double?,
    status: WellRequestStatus.values.byName(json['status'] as String),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  String _prefsKeyFor(String userId) => '$_prefsKeyPrefix$userId';

  Future<List<WellRequest>> _ensureLoaded() async {
    final userId = _currentUserId();
    if (userId == null) return const [];
    if (_cache != null && _cacheUserId == userId) return _cache!;

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKeyFor(userId));
    final requests = raw == null
        ? (userId == _demoUserId ? _seedRequests() : const <WellRequest>[])
        : (jsonDecode(raw) as List)
              .map((e) => _fromJson(e as Map<String, dynamic>))
              .toList();

    _cache = requests;
    _cacheUserId = userId;
    if (raw == null && requests.isNotEmpty) await _persist();
    return requests;
  }

  Future<void> _persist() async {
    final userId = _currentUserId();
    if (userId == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKeyFor(userId),
      jsonEncode(_cache!.map(_toJson).toList()),
    );
  }

  @override
  Future<Result<List<WellRequest>>> getMyRequests() async =>
      Result.ok(List.unmodifiable(await _ensureLoaded()));

  @override
  Future<Result<WellRequest>> createRequest({
    required String name,
    required String country,
    required String province,
    required String district,
    required String neighborhood,
    required String postalCode,
    required String address,
    double? latitude,
    double? longitude,
  }) async {
    final requests = await _ensureLoaded();
    final request = WellRequest(
      id: 'wr${_nextId++}',
      name: name,
      country: country,
      province: province,
      district: district,
      neighborhood: neighborhood,
      postalCode: postalCode,
      address: address,
      latitude: latitude,
      longitude: longitude,
      status: WellRequestStatus.pending,
      createdAt: DateTime.now(),
    );

    _cache = [...requests, request];
    await _persist();
    return Result.ok(request);
  }

  @override
  Future<Result<WellRequest>> updateRequest({
    required String id,
    required String name,
    required String country,
    required String province,
    required String district,
    required String neighborhood,
    required String postalCode,
    required String address,
    double? latitude,
    double? longitude,
  }) async {
    final requests = await _ensureLoaded();
    final index = requests.indexWhere((r) => r.id == id);
    if (index == -1) {
      return Result.error(Exception('Talep bulunamadı: $id'));
    }
    if (requests[index].status != WellRequestStatus.pending) {
      return Result.error(
        Exception('Onaylanmış/reddedilmiş bir talep düzenlenemez.'),
      );
    }

    final updated = requests[index].copyWith(
      name: name,
      country: country,
      province: province,
      district: district,
      neighborhood: neighborhood,
      postalCode: postalCode,
      address: address,
      latitude: latitude,
      longitude: longitude,
    );

    _cache = [
      for (var i = 0; i < requests.length; i++)
        if (i == index) updated else requests[i],
    ];
    await _persist();
    return Result.ok(updated);
  }

  @override
  Future<Result<bool>> deleteRequest(String id) async {
    final requests = await _ensureLoaded();
    _cache = requests.where((r) => r.id != id).toList();
    await _persist();
    return const Result.ok(true);
  }
}
