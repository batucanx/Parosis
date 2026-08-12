enum WellRequestStatus { pending, approved, rejected }

/// Yeni bir kuyunun sisteme kaydedilmesi için gönderilen başvuru. Onaylanınca
/// (yetkili tarafından, bu mobil uygulamanın dışında) gerçek API'de karşılığı
/// olan bir `Well` kaydı oluşur ve alt navbar'daki Kuyu listesine düşer —
/// bu mock katmanda o bağlantı henüz kurulmadı, sadece talep CRUD'u var.
class WellRequest {
  final String id;
  final String name;
  final String country;
  final String province;
  final String district;
  final String neighborhood;
  final String postalCode;
  final String address;
  final double? latitude;
  final double? longitude;
  final WellRequestStatus status;
  final DateTime createdAt;

  const WellRequest({
    required this.id,
    required this.name,
    required this.country,
    required this.province,
    required this.district,
    required this.neighborhood,
    required this.postalCode,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.createdAt,
  });

  String get locationLabel => '$district / $province';

  WellRequest copyWith({
    String? name,
    String? country,
    String? province,
    String? district,
    String? neighborhood,
    String? postalCode,
    String? address,
    double? latitude,
    double? longitude,
    WellRequestStatus? status,
  }) => WellRequest(
    id: id,
    name: name ?? this.name,
    country: country ?? this.country,
    province: province ?? this.province,
    district: district ?? this.district,
    neighborhood: neighborhood ?? this.neighborhood,
    postalCode: postalCode ?? this.postalCode,
    address: address ?? this.address,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    status: status ?? this.status,
    createdAt: createdAt,
  );
}
