import 'package:flutter/foundation.dart';

import 'package:parosis_sulama/core/result/result.dart';
import 'package:parosis_sulama/features/notifications/domain/entities/notification_preferences.dart';
import 'package:parosis_sulama/features/notifications/domain/repositories/notification_preferences_repository.dart';

final class NotificationPreferencesController extends ChangeNotifier {
  NotificationPreferencesController({
    required NotificationPreferencesRepository repository,
  }) : _repository = repository {
    _load();
  }

  final NotificationPreferencesRepository _repository;

  NotificationPreferences? _preferences;
  bool _isLoading = true;

  NotificationPreferences? get preferences => _preferences;
  bool get isLoading => _isLoading;

  Future<void> _load() async {
    _isLoading = true;
    notifyListeners();

    switch (await _repository.getPreferences()) {
      case Ok<NotificationPreferences>(:final value):
        _preferences = value;
      case Error<NotificationPreferences>():
        _preferences = const NotificationPreferences();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() => _load();

  Future<void> update(NotificationPreferences next) async {
    final previous = _preferences;
    _preferences = next;
    notifyListeners();

    switch (await _repository.updatePreferences(next)) {
      case Ok<NotificationPreferences>():
        break;
      case Error<NotificationPreferences>():
        _preferences = previous;
        notifyListeners();
    }
  }
}
