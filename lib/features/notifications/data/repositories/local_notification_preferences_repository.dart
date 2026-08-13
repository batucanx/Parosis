import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:parosis_sulama/core/result/result.dart';
import 'package:parosis_sulama/features/notifications/domain/entities/notification_preferences.dart';
import 'package:parosis_sulama/features/notifications/domain/repositories/notification_preferences_repository.dart';

/// Bildirim tercihleri henüz bir push-bildirim backend'ine bağlı değil;
/// tercihler yalnızca cihazda, oturum açan hesaba özel olarak saklanır
/// (bkz. `MockPaymentCardsRepository` ile aynı desen). Gerçek bir bildirim
/// servisi bağlandığında bu sınıfın yerini `RemoteNotificationPreferencesRepository`
/// alır, sözleşme değişmez.
final class LocalNotificationPreferencesRepository
    implements NotificationPreferencesRepository {
  LocalNotificationPreferencesRepository({
    required String? Function() currentUserId,
  }) : _currentUserId = currentUserId;

  final String? Function() _currentUserId;

  static const _prefsKeyPrefix = 'notification_prefs_v1_';

  String? _prefsKeyForCurrentUser() {
    final userId = _currentUserId();
    return userId == null ? null : '$_prefsKeyPrefix$userId';
  }

  NotificationPreferences _fromJson(Map<String, dynamic> json) =>
      NotificationPreferences(
        irrigationAlerts: json['irrigationAlerts'] as bool? ?? true,
        balanceAlerts: json['balanceAlerts'] as bool? ?? true,
        requestAlerts: json['requestAlerts'] as bool? ?? true,
        announcements: json['announcements'] as bool? ?? true,
      );

  Map<String, dynamic> _toJson(NotificationPreferences prefs) => {
    'irrigationAlerts': prefs.irrigationAlerts,
    'balanceAlerts': prefs.balanceAlerts,
    'requestAlerts': prefs.requestAlerts,
    'announcements': prefs.announcements,
  };

  @override
  Future<Result<NotificationPreferences>> getPreferences() async {
    final key = _prefsKeyForCurrentUser();
    if (key == null) {
      return Result.error(Exception('Oturum açılmamış.'));
    }
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) return const Result.ok(NotificationPreferences());
    return Result.ok(_fromJson(jsonDecode(raw) as Map<String, dynamic>));
  }

  @override
  Future<Result<NotificationPreferences>> updatePreferences(
    NotificationPreferences preferences,
  ) async {
    final key = _prefsKeyForCurrentUser();
    if (key == null) {
      return Result.error(Exception('Oturum açılmamış.'));
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(_toJson(preferences)));
    return Result.ok(preferences);
  }
}
