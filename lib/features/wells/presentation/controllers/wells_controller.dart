import 'package:flutter/foundation.dart';

import 'package:parosis_sulama/core/result/result.dart';
import 'package:parosis_sulama/features/wells/domain/entities/well.dart';
import 'package:parosis_sulama/features/wells/domain/repositories/well_repository.dart';

/// Holds the well list for the app shell. Screens read it via
/// [ListenableBuilder] instead of receiving a static snapshot from a parent.
final class WellsController extends ChangeNotifier {
  WellsController({required WellRepository repository})
    : _repository = repository {
    _load();
  }

  final WellRepository _repository;

  List<Well> _wells = const [];
  bool _isLoading = true;
  Object? _error;

  List<Well> get wells => _wells;
  bool get isLoading => _isLoading;
  Object? get error => _error;

  Future<void> _load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _repository.getWells();
    switch (result) {
      case Ok<List<Well>>(:final value):
        _wells = value;
      case Error<List<Well>>(:final error):
        _error = error;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() => _load();

  Well? byId(String id) {
    for (final well in _wells) {
      if (well.id == id) return well;
    }
    return null;
  }
}
