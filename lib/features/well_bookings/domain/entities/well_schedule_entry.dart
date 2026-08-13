enum WellScheduleEntryKind { mine, occupied, pendingApproval }

/// A single block on a well's day-occupancy timeline (Program Sulama →
/// kuyu düzenleme ekranındaki "Günün doluluğu" şeridi).
///
/// [mine] = oturumdaki kullanıcının kendi (bekleyen ya da onaylı) talebi,
/// [occupied] = başka birinin onaylı/aktif kullanımı, [pendingApproval] =
/// başka birinin henüz onaylanmamış talebi.
class WellScheduleEntry {
  final String id;
  final DateTime start;

  /// null = süresi belirsiz, hâlâ devam ediyor (bkz. [isActiveAt]).
  final DateTime? end;
  final String personName;
  final WellScheduleEntryKind kind;

  const WellScheduleEntry({
    required this.id,
    required this.start,
    this.end,
    required this.personName,
    required this.kind,
  });

  bool isActiveAt(DateTime moment) {
    final end = this.end;
    return !start.isAfter(moment) && (end == null || !end.isBefore(moment));
  }
}
