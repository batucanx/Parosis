import 'package:flutter/foundation.dart';

import 'package:parosis_sulama/core/result/result.dart';
import 'package:parosis_sulama/features/well_requests/domain/entities/well_request.dart';
import 'package:parosis_sulama/features/well_requests/domain/repositories/well_request_repository.dart';

final class WellRequestsController extends ChangeNotifier {
  WellRequestsController({required WellRequestRepository repository})
    : _repository = repository {
    _load();
  }

  final WellRequestRepository _repository;

  List<WellRequest> _requests = const [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  Object? _error;

  List<WellRequest> get requests => _requests;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  Object? get error => _error;

  Future<void> _load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    switch (await _repository.getMyRequests()) {
      case Ok<List<WellRequest>>(:final value):
        _requests = value;
      case Error<List<WellRequest>>(:final error):
        _error = error;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() => _load();

  Future<WellRequest?> createRequest({
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
    if (_isSubmitting) return null;
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    WellRequest? created;
    switch (await _repository.createRequest(
      name: name,
      country: country,
      province: province,
      district: district,
      neighborhood: neighborhood,
      postalCode: postalCode,
      address: address,
      latitude: latitude,
      longitude: longitude,
    )) {
      case Ok<WellRequest>(:final value):
        created = value;
        _requests = [..._requests, value];
      case Error<WellRequest>(:final error):
        _error = error;
    }

    _isSubmitting = false;
    notifyListeners();
    return created;
  }

  Future<WellRequest?> updateRequest({
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
    if (_isSubmitting) return null;
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    WellRequest? updated;
    switch (await _repository.updateRequest(
      id: id,
      name: name,
      country: country,
      province: province,
      district: district,
      neighborhood: neighborhood,
      postalCode: postalCode,
      address: address,
      latitude: latitude,
      longitude: longitude,
    )) {
      case Ok<WellRequest>(:final value):
        updated = value;
        _requests = [
          for (final r in _requests) if (r.id == id) value else r,
        ];
      case Error<WellRequest>(:final error):
        _error = error;
    }

    _isSubmitting = false;
    notifyListeners();
    return updated;
  }

  Future<bool> deleteRequest(String id) async {
    if (_isSubmitting) return false;
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    var success = false;
    switch (await _repository.deleteRequest(id)) {
      case Ok<bool>():
        success = true;
        _requests = _requests.where((r) => r.id != id).toList();
      case Error<bool>(:final error):
        _error = error;
    }

    _isSubmitting = false;
    notifyListeners();
    return success;
  }
}
