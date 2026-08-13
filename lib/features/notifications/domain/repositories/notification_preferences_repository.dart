import 'package:parosis_sulama/core/result/result.dart';
import 'package:parosis_sulama/features/notifications/domain/entities/notification_preferences.dart';

abstract interface class NotificationPreferencesRepository {
  Future<Result<NotificationPreferences>> getPreferences();

  Future<Result<NotificationPreferences>> updatePreferences(
    NotificationPreferences preferences,
  );
}
