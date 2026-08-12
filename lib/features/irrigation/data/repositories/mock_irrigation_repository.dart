import 'dart:math';

import 'package:parosis_sulama/core/result/result.dart';
import 'package:parosis_sulama/features/irrigation/domain/entities/active_irrigation.dart';
import 'package:parosis_sulama/features/irrigation/domain/entities/past_irrigation.dart';
import 'package:parosis_sulama/features/irrigation/domain/entities/upcoming_irrigation.dart';
import 'package:parosis_sulama/features/irrigation/domain/repositories/irrigation_repository.dart';

const _historyNamePool = [
  'Ali Yurtseven',
  'Mehmet Polat',
  'Fatma Yılmaz',
  'Hasan Demir',
  'Ayşe Kara',
];

/// [wellId]'ye göre deterministik (her açılışta aynı), birden çok gün ve
/// kişiye yayılan geçmiş sulama kayıtları üretir — "Geçmiş Sulamalar"
/// ekranındaki günlük grafik/kişi bazlı dökümün gerçekçi görünmesi için.
/// Gerçek çoklu kullanıcı verisi olmadığından (bkz. memory
/// `project_well_ownership_deferred`) tamamen sahte, ama sabit.
List<PastIrrigation> _generatePastIrrigations(String wellId) {
  final rng = Random(wellId.hashCode);
  final today = DateTime.now();
  final dayCount = 5 + rng.nextInt(4);
  final entries = <PastIrrigation>[];
  var nextId = 0;

  for (var dayOffset = dayCount; dayOffset >= 1; dayOffset--) {
    if (rng.nextDouble() < 0.15) continue;
    final day = DateTime(today.year, today.month, today.day - dayOffset);
    final sessionCount = 1 + rng.nextInt(4);
    for (var s = 0; s < sessionCount; s++) {
      final hour = rng.nextInt(20);
      final minute = rng.nextBool() ? 0 : 30;
      final isLongSession = rng.nextDouble() < 0.3;
      final durationMinutes = isLongSession
          ? 60 + rng.nextInt(1140)
          : 1 + rng.nextInt(60);
      entries.add(
        PastIrrigation(
          id: 'gen-$wellId-${nextId++}',
          wellId: wellId,
          personName: _historyNamePool[rng.nextInt(_historyNamePool.length)],
          occurredAt: DateTime(day.year, day.month, day.day, hour, minute),
          duration: Duration(minutes: durationMinutes),
          waterLiters: durationMinutes * 27.5,
        ),
      );
    }
  }

  return entries;
}

const _allWellIds = ['k1', 'k2', 'k3', 'k4', 'k5', 'k6', 'k7'];

/// In-memory stand-in for the irrigation API.
///
/// Kuyular paylaşımlı bir havuz olduğu için [PastIrrigation] geçmişi de
/// **herkese açık** — bir kuyuyu kimlerin ne zaman kullandığı, o kuyuya
/// bakan herkes için aynı (bkz. `wells`/`mock_well_repository.dart`).
/// Buna karşılık "aktif sulamam"/"gelecek sulamam" gerçekten kişisel
/// olduğu için `payment_cards`/`well_bookings` ile aynı desende kullanıcıya
/// özel kalıyor: sadece sabit demo hesap (`SLM-10001`) örnek veriyle
/// başlar (bir oturum zaten çalışır durumda gelir, "aktif sulama" UI'ının
/// ilk açılışta karşı tepki verecek gerçek bir şeyi olsun diye) — her yeni
/// gerçek kullanıcının kendi aktif/gelecek sulaması henüz yoktur.
final class MockIrrigationRepository implements IrrigationRepository {
  MockIrrigationRepository({required String? Function() currentUserId})
    : _currentUserId = currentUserId;

  final String? Function() _currentUserId;
  static const _demoUserId = 'SLM-10001';

  List<ActiveIrrigation>? _active;
  List<UpcomingIrrigation>? _upcoming;
  List<PastIrrigation>? _past;
  String? _cacheUserId;
  int _nextActiveId = 2;

  void _ensureLoaded() {
    _past ??= [
      for (final wellId in _allWellIds) ..._generatePastIrrigations(wellId),
    ];

    final userId = _currentUserId();
    if (_cacheUserId == userId && _active != null) return;
    _cacheUserId = userId;

    if (userId != _demoUserId) {
      _active = [];
      _upcoming = [];
      return;
    }

    _active = [
      ActiveIrrigation(
        id: 'a1',
        wellId: 'k1',
        startedAt: DateTime.now().subtract(
          const Duration(hours: 2, minutes: 34, seconds: 11),
        ),
      ),
    ];
    _upcoming = [
      UpcomingIrrigation(
        id: 'p1',
        wellId: 'k1',
        scheduledAt: DateTime(2026, 8, 4, 5, 0),
        duration: const Duration(minutes: 60),
      ),
      UpcomingIrrigation(
        id: 'p2',
        wellId: 'k4',
        scheduledAt: DateTime(2026, 8, 5, 6, 30),
        duration: const Duration(minutes: 45),
      ),
      UpcomingIrrigation(
        id: 'p3',
        wellId: 'k3',
        scheduledAt: DateTime(2026, 8, 6, 5, 30),
        duration: const Duration(minutes: 90),
      ),
    ];
  }

  @override
  Future<Result<List<ActiveIrrigation>>> getActiveIrrigations() async {
    _ensureLoaded();
    return Result.ok(List.unmodifiable(_active!));
  }

  @override
  Future<Result<List<UpcomingIrrigation>>> getUpcomingIrrigations() async {
    _ensureLoaded();
    return Result.ok(List.unmodifiable(_upcoming!));
  }

  @override
  Future<Result<List<PastIrrigation>>> getPastIrrigations() async {
    _ensureLoaded();
    return Result.ok(List.unmodifiable(_past!));
  }

  @override
  Future<Result<ActiveIrrigation>> startIrrigation(String wellId) async {
    _ensureLoaded();
    final existing = _active!.where((i) => i.wellId == wellId).firstOrNull;
    if (existing != null) return Result.ok(existing);

    final session = ActiveIrrigation(
      id: 'a${_nextActiveId++}',
      wellId: wellId,
      startedAt: DateTime.now(),
    );
    _active!.add(session);
    return Result.ok(session);
  }

  @override
  Future<Result<bool>> stopIrrigation(String wellId) async {
    _ensureLoaded();
    // Gerçek bir backend çağrısını simüle eder — kullanıcı arayüzündeki
    // "durduruluyor" geçiş durumunun (gri renk, pasif buton) fark edilir
    // olması için kısa bir gecikme.
    await Future.delayed(const Duration(milliseconds: 700));
    _active!.removeWhere((i) => i.wellId == wellId);
    return const Result.ok(true);
  }
}
