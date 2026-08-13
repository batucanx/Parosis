class NotificationPreferences {
  final bool irrigationAlerts;
  final bool balanceAlerts;
  final bool requestAlerts;
  final bool announcements;

  const NotificationPreferences({
    this.irrigationAlerts = true,
    this.balanceAlerts = true,
    this.requestAlerts = true,
    this.announcements = true,
  });

  NotificationPreferences copyWith({
    bool? irrigationAlerts,
    bool? balanceAlerts,
    bool? requestAlerts,
    bool? announcements,
  }) => NotificationPreferences(
    irrigationAlerts: irrigationAlerts ?? this.irrigationAlerts,
    balanceAlerts: balanceAlerts ?? this.balanceAlerts,
    requestAlerts: requestAlerts ?? this.requestAlerts,
    announcements: announcements ?? this.announcements,
  );
}
