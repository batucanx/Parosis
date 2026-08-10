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
  Object? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
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
}
