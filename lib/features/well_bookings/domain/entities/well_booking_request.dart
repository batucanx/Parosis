enum WellBookingDirection { incoming, outgoing }

enum WellBookingStatus { pending, approved, rejected, cancelled }

/// Bir kuyuda zaman dilimi ayırma (randevu) talebi. [WellBookingDirection]
/// yöne göre "Kuyularıma Gelen Talepler" (incoming — başkasının kuyumu
/// kullanma talebi, benim onaylamam gerekir) veya "Taleplerim" (outgoing —
/// benim başka bir kuyu için gönderdiğim talep) listesinde gösterilir.
class WellBookingRequest {
  final String id;
  final String wellId;
  final String wellName;
  final String counterpartName;
  final DateTime start;
  final DateTime end;
  final WellBookingDirection direction;
  final WellBookingStatus status;

  const WellBookingRequest({
    required this.id,
    required this.wellId,
    required this.wellName,
    required this.counterpartName,
    required this.start,
    required this.end,
    required this.direction,
    required this.status,
  });

  WellBookingRequest copyWith({WellBookingStatus? status}) =>
      WellBookingRequest(
        id: id,
        wellId: wellId,
        wellName: wellName,
        counterpartName: counterpartName,
        start: start,
        end: end,
        direction: direction,
        status: status ?? this.status,
      );
}
