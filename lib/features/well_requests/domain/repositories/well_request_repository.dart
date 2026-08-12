import 'package:parosis_sulama/core/result/result.dart';
import 'package:parosis_sulama/features/well_requests/domain/entities/well_request.dart';

abstract interface class WellRequestRepository {
  Future<Result<List<WellRequest>>> getMyRequests();

  Future<Result<WellRequest>> createRequest({
    required String name,
    required String country,
    required String province,
    required String district,
    required String neighborhood,
    required String postalCode,
    required String address,
    double? latitude,
    double? longitude,
  });

  /// Yalnızca `pending` durumundaki talepler düzenlenebilir; onaylanmış/
  /// reddedilmiş bir talebi güncellemeye çalışmak hata döner.
  Future<Result<WellRequest>> updateRequest({
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
  });

  Future<Result<bool>> deleteRequest(String id);
}
