import 'package:flutter/foundation.dart';

import 'package:parosis_sulama/core/result/result.dart';
import 'package:parosis_sulama/features/irrigation/domain/entities/active_irrigation.dart';
import 'package:parosis_sulama/features/irrigation/domain/entities/past_irrigation.dart';
import 'package:parosis_sulama/features/irrigation/domain/entities/upcoming_irrigation.dart';
import 'package:parosis_sulama/features/irrigation/domain/repositories/irrigation_repository.dart';

final class IrrigationController extends ChangeNotifier {
  IrrigationController({required IrrigationRepository repository})
    : _repository = repository {
    _load();
  }

  final IrrigationRepository _repository;

  List<ActiveIrrigation> _active = const [];
  List<UpcomingIrrigation> _upcoming = const [];
  List<PastIrrigation> _past = const [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  Object? _error;

  /// Onaylanıp "Durdur" işlemi devam eden kuyular — bkz. [isStopping].
  final Set<String> _stoppingWellIds = {};

  List<ActiveIrrigation> get active => _active;
  List<UpcomingIrrigation> get upcoming => _upcoming;
  List<PastIrrigation> get past => _past;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  Object? get error => _error;

  bool isActiveForWell(String wellId) =>
      _active.any((irrigation) => irrigation.wellId == wellId);

  /// Kullanıcı "Durdur"u onayladıktan sonra, istek hâlâ işlenirken true —
  /// Aktif Sulamalar kartının ve Anlık Sulama'daki kuyu kartının pasif/gri
  /// "kapatılıyor" görünümünü tetiklemek için.
  bool isStopping(String wellId) => _stoppingWellIds.contains(wellId);

  Future<void> _load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    switch (await _repository.getActiveIrrigations()) {
      case Ok<List<ActiveIrrigation>>(:final value):
        _active = value;
      case Error<List<ActiveIrrigation>>(:final error):
        _error = error;
    }

    switch (await _repository.getUpcomingIrrigations()) {
      case Ok<List<UpcomingIrrigation>>(:final value):
        _upcoming = value;
      case Error<List<UpcomingIrrigation>>(:final error):
        _error = error;
    }

    switch (await _repository.getPastIrrigations()) {
      case Ok<List<PastIrrigation>>(:final value):
        _past = value;
      case Error<List<PastIrrigation>>(:final error):
        _error = error;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() => _load();

  Future<void> start(String wellId) async {
    if (_isSubmitting || isActiveForWell(wellId)) return;
    _isSubmitting = true;
    notifyListeners();

    switch (await _repository.startIrrigation(wellId)) {
      case Ok<ActiveIrrigation>(:final value):
        _active = [..._active, value];
      case Error<ActiveIrrigation>(:final error):
        _error = error;
    }

    _isSubmitting = false;
    notifyListeners();
  }

  Future<void> stop(String wellId) async {
    if (isStopping(wellId)) return;
    _stoppingWellIds.add(wellId);
    notifyListeners();

    switch (await _repository.stopIrrigation(wellId)) {
      case Ok<bool>():
        _active = _active.where((i) => i.wellId != wellId).toList();
      case Error<bool>(:final error):
        _error = error;
    }

    _stoppingWellIds.remove(wellId);
    notifyListeners();
  }
}
