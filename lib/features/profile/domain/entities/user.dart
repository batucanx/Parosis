class User {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String country;
  final String province;
  final String district;
  final String postalCode;
  final String address;

  const User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.country = '',
    this.province = '',
    this.district = '',
    this.postalCode = '',
    this.address = '',
  });

  bool get hasCompleteAddress =>
      country.trim().isNotEmpty &&
      province.trim().isNotEmpty &&
      district.trim().isNotEmpty &&
      postalCode.trim().isNotEmpty &&
      address.trim().isNotEmpty;

  String get statusLabel => hasCompleteAddress ? 'Aktif Üye' : 'Pasif Üye';

  User copyWith({
    String? country,
    String? province,
    String? district,
    String? postalCode,
    String? address,
  }) => User(
    id: id,
    fullName: fullName,
    email: email,
    phone: phone,
    country: country ?? this.country,
    province: province ?? this.province,
    district: district ?? this.district,
    postalCode: postalCode ?? this.postalCode,
    address: address ?? this.address,
  );
}
