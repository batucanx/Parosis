import 'package:flutter/foundation.dart';

import 'package:parosis_sulama/core/result/result.dart';
import 'package:parosis_sulama/features/profile/domain/entities/user.dart';
import 'package:parosis_sulama/features/profile/domain/repositories/profile_repository.dart';

final class ProfileController extends ChangeNotifier {
  ProfileController({required ProfileRepository repository})
    : _repository = repository {
    _load();
  }

  final ProfileRepository _repository;

  User? _user;
  bool _isLoading = true;
  bool _isSubmitting = false;
  Object? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  Object? get error => _error;

  Future<void> _load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    switch (await _repository.getCurrentUser()) {
      case Ok<User>(:final value):
        _user = value;
      case Error<User>(:final error):
        _error = error;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() => _load();

  Future<bool> updateAddress({
    required String country,
    required String province,
    required String district,
    required String postalCode,
    required String address,
  }) async {
    if (_isSubmitting) return false;
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    var success = false;
    switch (await _repository.updateAddress(
      country: country,
      province: province,
      district: district,
      postalCode: postalCode,
      address: address,
    )) {
      case Ok<User>(:final value):
        _user = value;
        success = true;
      case Error<User>(:final error):
        _error = error;
    }

    _isSubmitting = false;
    notifyListeners();
    return success;
  }
}
