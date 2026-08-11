final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

String? validateEmail(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return 'E-posta adresi gerekli.';
  if (!_emailPattern.hasMatch(trimmed)) return 'Geçerli bir e-posta girin.';
  return null;
}

String? validatePassword(String value) {
  if (value.isEmpty) return 'Şifre gerekli.';
  if (value.length < 6) return 'Şifre en az 6 karakter olmalı.';
  return null;
}

String? validateConfirmPassword(String password, String confirm) {
  if (confirm.isEmpty) return 'Şifre tekrarı gerekli.';
  if (confirm != password) return 'Şifreler eşleşmiyor.';
  return null;
}

String? validateFullName(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return 'Ad soyad gerekli.';
  if (!trimmed.contains(RegExp(r'\s'))) return 'Ad ve soyadınızı girin.';
  return null;
}

String? validatePhoneDigits(String digits) {
  if (digits.isEmpty) return 'Telefon numarası gerekli.';
  if (digits.length != 11 || !digits.startsWith('0')) {
    return 'Geçerli bir telefon numarası girin.';
  }
  return null;
}

/// T.C. Kimlik No resmi doğrulama algoritması: 11 haneli, ilk hane 0
/// olamaz, 10. ve 11. haneler kontrol basamaklarıdır.
String? validateTcKimlik(String digits) {
  if (digits.length != 11) return 'T.C. Kimlik No 11 haneli olmalı.';
  if (digits[0] == '0') return 'Geçerli bir T.C. Kimlik No girin.';

  final d = digits.split('').map(int.parse).toList();
  final oddSum = d[0] + d[2] + d[4] + d[6] + d[8];
  final evenSum = d[1] + d[3] + d[5] + d[7];
  final digit10 = ((oddSum * 7) - evenSum) % 10;
  if (digit10 != d[9]) return 'Geçerli bir T.C. Kimlik No girin.';

  final digit11 = d.take(10).reduce((a, b) => a + b) % 10;
  if (digit11 != d[10]) return 'Geçerli bir T.C. Kimlik No girin.';

  return null;
}
