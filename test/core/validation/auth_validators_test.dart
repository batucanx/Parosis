import 'package:flutter_test/flutter_test.dart';
import 'package:parosis_sulama/core/validation/auth_validators.dart';

void main() {
  group('validateEmail', () {
    test('geçerli e-postayı kabul eder', () {
      expect(validateEmail('demo@parosis.com'), isNull);
    });

    test('@ içermeyen değeri reddeder', () {
      expect(validateEmail('gecersiz'), isNotNull);
    });
  });

  group('validateTcKimlik', () {
    test('geçerli kontrol basamaklarını kabul eder', () {
      expect(validateTcKimlik('10000000146'), isNull);
    });

    test('bozuk kontrol basamağını reddeder', () {
      expect(validateTcKimlik('10000000147'), isNotNull);
    });

    test('0 ile başlayan numarayı reddeder', () {
      expect(validateTcKimlik('01000000146'), isNotNull);
    });

    test('11 haneden farklı uzunluğu reddeder', () {
      expect(validateTcKimlik('123'), isNotNull);
    });
  });

  group('validatePhoneDigits', () {
    test('0 ile başlayan 11 haneli numarayı kabul eder', () {
      expect(validatePhoneDigits('05321180476'), isNull);
    });

    test('0 ile başlamayan numarayı reddeder', () {
      expect(validatePhoneDigits('5321180476'), isNotNull);
    });
  });

  group('validateConfirmPassword', () {
    test('eşleşen şifreleri kabul eder', () {
      expect(validateConfirmPassword('abc123', 'abc123'), isNull);
    });

    test('eşleşmeyen şifreleri reddeder', () {
      expect(validateConfirmPassword('abc123', 'abc124'), isNotNull);
    });
  });
}
