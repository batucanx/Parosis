import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:parosis_sulama/core/result/result.dart';
import 'package:parosis_sulama/features/well_bookings/domain/entities/well_booking_request.dart';
import 'package:parosis_sulama/features/well_bookings/domain/entities/well_schedule_entry.dart';
import 'package:parosis_sulama/features/well_bookings/domain/repositories/well_booking_repository.dart';

const _ownerNamePool = [
  'Ali Yurtseven',
  'Mehmet Polat',
  'Fatma Yılmaz',
  'Hasan Demir',
  'Ayşe Kara',
];

String _ownerNameFor(String wellId) =>
    _ownerNamePool[wellId.hashCode.abs() % _ownerNamePool.length];

/// Randevu taleplerini oturum açan hesaba göre ayrı `shared_preferences`
/// anahtarında tutar. Sadece sabit demo hesap örnek talep verisiyle başlar.
///
/// Kuyu sahipliği (multi-owner havuz) henüz kurulmadığı için "Günün
/// doluluğu" şeridindeki başka kullanıcıların dolulukları gerçek bir
/// backend'den gelmiyor — [_syntheticOthers] ile kuyu id'sine göre
/// deterministik (her açılışta aynı) sahte veri üretiliyor. Kuyu sahipliği +
/// gerçek çoklu kullanıcı verisi ayrı bir işte ele alınacak.
final class MockWellBookingRepository implements WellBookingRepository {
  MockWellBookingRepository({required String? Function() currentUserId})
    : _currentUserId = currentUserId;

  final String? Function() _currentUserId;

  static const _demoUserId = 'SLM-10001';
  static const _prefsKeyPrefix = 'well_bookings_v2_';

  List<WellBookingRequest>? _cache;
  String? _cacheUserId;

  List<WellBookingRequest> _seedRequests() => [
    WellBookingRequest(
      id: 'wb1',
      wellId: 'ext-1',
      wellName: 'Ankara Polatlı Kuyusu',
      counterpartName: 'Mehmet Polat',
      start: DateTime(2026, 7, 28, 0, 0),
      end: DateTime(2026, 7, 28, 1, 0),
      direction: WellBookingDirection.outgoing,
      status: WellBookingStatus.pending,
    ),
    WellBookingRequest(
      id: 'wb2',
      wellId: 'k1',
      wellName: 'Ali Yurtseven Taşlı Tarla',
      counterpartName: 'Fatma Yılmaz',
      start: DateTime(2026, 8, 12, 14, 0),
      end: DateTime(2026, 8, 12, 14, 30),
      direction: WellBookingDirection.incoming,
      status: WellBookingStatus.pending,
    ),
    WellBookingRequest(
      id: 'wb3',
      wellId: 'ext-2',
      wellName: 'Salihli Bağ Kuyusu',
      counterpartName: 'Hasan Demir',
      start: DateTime(2026, 7, 20, 9, 0),
      end: DateTime(2026, 7, 20, 9, 45),
      direction: WellBookingDirection.outgoing,
      status: WellBookingStatus.approved,
    ),
  ];

  Map<String, dynamic> _toJson(WellBookingRequest r) => {
    'id': r.id,
    'wellId': r.wellId,
    'wellName': r.wellName,
    'counterpartName': r.counterpartName,
    'start': r.start.toIso8601String(),
    'end': r.end.toIso8601String(),
    'direction': r.direction.name,
    'status': r.status.name,
  };

  WellBookingRequest _fromJson(Map<String, dynamic> json) => WellBookingRequest(
    id: json['id'] as String,
    wellId: json['wellId'] as String,
    wellName: json['wellName'] as String,
    counterpartName: json['counterpartName'] as String,
    start: DateTime.parse(json['start'] as String),
    end: DateTime.parse(json['end'] as String),
    direction: WellBookingDirection.values.byName(json['direction'] as String),
    status: WellBookingStatus.values.byName(json['status'] as String),
  );

  String _prefsKeyFor(String userId) => '$_prefsKeyPrefix$userId';

  Future<List<WellBookingRequest>> _ensureLoaded() async {
    final userId = _currentUserId();
    if (userId == null) return const [];
    if (_cache != null && _cacheUserId == userId) return _cache!;

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKeyFor(userId));
    final requests = raw == null
        ? (userId == _demoUserId
              ? _seedRequests()
              : const <WellBookingRequest>[])
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
  Future<Result<List<WellBookingRequest>>> getRequests() async =>
      Result.ok(List.unmodifiable(await _ensureLoaded()));

  @override
  Future<Result<WellBookingRequest>> respond({
    required String id,
    required bool approve,
  }) async {
    final requests = await _ensureLoaded();
    final index = requests.indexWhere((r) => r.id == id);
    if (index == -1) {
      return Result.error(Exception('Talep bulunamadı: $id'));
    }
    if (requests[index].direction != WellBookingDirection.incoming) {
      return Result.error(Exception('Bu talep yanıtlanamaz.'));
    }

    final updated = requests[index].copyWith(
      status: approve ? WellBookingStatus.approved : WellBookingStatus.rejected,
    );
    _cache = [
      for (var i = 0; i < requests.length; i++)
        if (i == index) updated else requests[i],
    ];
    await _persist();
    return Result.ok(updated);
  }

  @override
  Future<Result<WellBookingRequest>> cancel(String id) async {
    final requests = await _ensureLoaded();
    final index = requests.indexWhere((r) => r.id == id);
    if (index == -1) {
      return Result.error(Exception('Talep bulunamadı: $id'));
    }
    if (requests[index].direction != WellBookingDirection.outgoing) {
      return Result.error(Exception('Bu talep iptal edilemez.'));
    }

    final updated = requests[index].copyWith(
      status: WellBookingStatus.cancelled,
    );
    _cache = [
      for (var i = 0; i < requests.length; i++)
        if (i == index) updated else requests[i],
    ];
    await _persist();
    return Result.ok(updated);
  }

  /// Kuyu id'sine ve güne göre deterministik (sahte, gerçek backend'e kadar
  /// sabit) "başkalarının dolulukları" üretir — aynı gün için her çağrıda
  /// aynı sonucu verir.
  List<WellScheduleEntry> _syntheticOthers({
    required String wellId,
    required DateTime day,
  }) {
    final seed =
        wellId.hashCode ^ (day.year * 10000 + day.month * 100 + day.day);
    final rng = Random(seed);
    final entries = <WellScheduleEntry>[];

    final blockCount = rng.nextInt(3);
    for (var i = 0; i < blockCount; i++) {
      final startHour = rng.nextInt(21);
      final startMinute = rng.nextBool() ? 0 : 30;
      final durationMinutes = 30 + rng.nextInt(4) * 15;
      final start = DateTime(
        day.year,
        day.month,
        day.day,
        startHour,
        startMinute,
      );
      final end = start.add(Duration(minutes: durationMinutes));
      if (end.day != start.day) continue;
      entries.add(
        WellScheduleEntry(
          id: 'synthetic-$wellId-$i-${day.day}',
          start: start,
          end: end,
          personName: _ownerNamePool[rng.nextInt(_ownerNamePool.length)],
          kind: rng.nextDouble() < 0.3
              ? WellScheduleEntryKind.pendingApproval
              : WellScheduleEntryKind.occupied,
        ),
      );
    }

    final now = DateTime.now();
    final isToday =
        day.year == now.year && day.month == now.month && day.day == now.day;
    if (isToday && rng.nextDouble() < 0.5) {
      final activeStart = now.subtract(Duration(minutes: 20 + rng.nextInt(90)));
      entries.add(
        WellScheduleEntry(
          id: 'synthetic-active-$wellId',
          start: activeStart,
          personName: _ownerNameFor(wellId),
          kind: WellScheduleEntryKind.occupied,
        ),
      );
    }

    return entries;
  }

  @override
  Future<Result<List<WellScheduleEntry>>> getDaySchedule({
    required String wellId,
    required DateTime date,
  }) async {
    final requests = await _ensureLoaded();
    final day = DateTime(date.year, date.month, date.day);
    final nextDay = day.add(const Duration(days: 1));

    final mine = requests
        .where(
          (r) =>
              r.wellId == wellId &&
              r.direction == WellBookingDirection.outgoing &&
              r.status != WellBookingStatus.rejected &&
              r.status != WellBookingStatus.cancelled &&
              r.start.isBefore(nextDay) &&
              r.end.isAfter(day),
        )
        .map(
          (r) => WellScheduleEntry(
            id: r.id,
            start: r.start,
            end: r.end,
            personName: 'Siz',
            kind: WellScheduleEntryKind.mine,
          ),
        );

    return Result.ok([...mine, ..._syntheticOthers(wellId: wellId, day: day)]);
  }

  @override
  Future<Result<WellBookingRequest>> requestSlot({
    required String wellId,
    required String wellName,
    required DateTime start,
    required DateTime end,
  }) async {
    final requests = await _ensureLoaded();
    final request = WellBookingRequest(
      id: 'wb-${DateTime.now().microsecondsSinceEpoch}',
      wellId: wellId,
      wellName: wellName,
      counterpartName: _ownerNameFor(wellId),
      start: start,
      end: end,
      direction: WellBookingDirection.outgoing,
      status: WellBookingStatus.pending,
    );
    _cache = [...requests, request];
    await _persist();
    return Result.ok(request);
  }
}
