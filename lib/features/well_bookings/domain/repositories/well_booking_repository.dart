import 'package:parosis_sulama/core/result/result.dart';
import 'package:parosis_sulama/features/well_bookings/domain/entities/well_booking_request.dart';
import 'package:parosis_sulama/features/well_bookings/domain/entities/well_schedule_entry.dart';

abstract interface class WellBookingRepository {
  Future<Result<List<WellBookingRequest>>> getRequests();

  /// Sadece `incoming` (bana gelen) talepler için: onaylar ya da reddeder.
  Future<Result<WellBookingRequest>> respond({
    required String id,
    required bool approve,
  });

  /// Sadece `outgoing` (benim gönderdiğim) talepler için: talebi iptal eder.
  Future<Result<WellBookingRequest>> cancel(String id);

  /// Program Sulama kuyu ekranındaki "Günün doluluğu" şeridi ve "Bu günün
  /// randevuları" listesi için: verilen kuyunun, verilen tarihteki tüm
  /// dolulukları (kendi taleplerim + diğer kullanıcıların dolulukları).
  Future<Result<List<WellScheduleEntry>>> getDaySchedule({
    required String wellId,
    required DateTime date,
  });

  /// "Sıra Al" akışı: verilen kuyu için seçilen zaman aralığında yeni bir
  /// randevu talebi (outgoing, pending) oluşturur.
  Future<Result<WellBookingRequest>> requestSlot({
    required String wellId,
    required String wellName,
    required DateTime start,
    required DateTime end,
  });
}
