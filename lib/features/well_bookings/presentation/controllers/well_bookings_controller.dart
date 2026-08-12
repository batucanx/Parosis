import 'package:flutter/foundation.dart';

import 'package:parosis_sulama/core/result/result.dart';
import 'package:parosis_sulama/features/well_bookings/domain/entities/well_booking_request.dart';
import 'package:parosis_sulama/features/well_bookings/domain/entities/well_schedule_entry.dart';
import 'package:parosis_sulama/features/well_bookings/domain/repositories/well_booking_repository.dart';

final class WellBookingsController extends ChangeNotifier {
  WellBookingsController({required WellBookingRepository repository})
    : _repository = repository {
    _load();
  }

  final WellBookingRepository _repository;

  List<WellBookingRequest> _requests = const [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  Object? _error;

  List<WellBookingRequest> get requests => _requests;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  Object? get error => _error;

  List<WellBookingRequest> get incoming => _requests
      .where((r) => r.direction == WellBookingDirection.incoming)
      .toList();

  List<WellBookingRequest> get outgoing => _requests
      .where((r) => r.direction == WellBookingDirection.outgoing)
      .toList();

  Future<void> _load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    switch (await _repository.getRequests()) {
      case Ok<List<WellBookingRequest>>(:final value):
        _requests = value;
      case Error<List<WellBookingRequest>>(:final error):
        _error = error;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() => _load();

  Future<bool> respond({required String id, required bool approve}) async {
    if (_isSubmitting) return false;
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    var success = false;
    switch (await _repository.respond(id: id, approve: approve)) {
      case Ok<WellBookingRequest>(:final value):
        success = true;
        _requests = [
          for (final r in _requests) if (r.id == id) value else r,
        ];
      case Error<WellBookingRequest>(:final error):
        _error = error;
    }

    _isSubmitting = false;
    notifyListeners();
    return success;
  }

  Future<bool> cancel(String id) async {
    if (_isSubmitting) return false;
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    var success = false;
    switch (await _repository.cancel(id)) {
      case Ok<WellBookingRequest>(:final value):
        success = true;
        _requests = [
          for (final r in _requests) if (r.id == id) value else r,
        ];
      case Error<WellBookingRequest>(:final error):
        _error = error;
    }

    _isSubmitting = false;
    notifyListeners();
    return success;
  }

  /// Program Sulama kuyu ekranındaki "Günün doluluğu" şeridi için: bu
  /// çağrı, ana `_requests` listesini/`isLoading` bayrağını etkilemez —
  /// sadece o an görüntülenen ekrana özel, anlık bir sorgudur.
  Future<List<WellScheduleEntry>> loadDaySchedule({
    required String wellId,
    required DateTime date,
  }) async {
    switch (await _repository.getDaySchedule(wellId: wellId, date: date)) {
      case Ok<List<WellScheduleEntry>>(:final value):
        return value;
      case Error<List<WellScheduleEntry>>():
        return const [];
    }
  }

  /// "Sıra Al" akışı: başarılı olursa yeni talep, "Taleplerim" listesine de
  /// hemen eklenir.
  Future<bool> requestSlot({
    required String wellId,
    required String wellName,
    required DateTime start,
    required DateTime end,
  }) async {
    if (_isSubmitting) return false;
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    var success = false;
    switch (await _repository.requestSlot(
      wellId: wellId,
      wellName: wellName,
      start: start,
      end: end,
    )) {
      case Ok<WellBookingRequest>(:final value):
        success = true;
        _requests = [..._requests, value];
      case Error<WellBookingRequest>(:final error):
        _error = error;
    }

    _isSubmitting = false;
    notifyListeners();
    return success;
  }
}
