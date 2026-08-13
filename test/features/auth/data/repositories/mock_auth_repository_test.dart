import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parosis_sulama/core/result/result.dart';
import 'package:parosis_sulama/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:parosis_sulama/features/auth/domain/entities/auth_user.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('MockAuthRepository', () {
    test(
      'seed hesapla giriş başarılı olur ve oturumu kalıcı hâle getirir',
      () async {
        final repository = MockAuthRepository();

        final result = await repository.login(
          email: 'demo@parosis.com',
          password: 'Parosis123!',
        );

        expect(result, isA<Ok<AuthUser>>());
        final user = (result as Ok<AuthUser>).value;
        expect(user.email, 'demo@parosis.com');

        final restored = await MockAuthRepository().restoreSession();
        expect(restored?.id, user.id);
      },
    );

    test('yanlış şifreyle giriş reddedilir', () async {
      final repository = MockAuthRepository();

      final result = await repository.login(
        email: 'demo@parosis.com',
        password: 'yanlis-sifre',
      );

      expect(result, isA<Error<AuthUser>>());
    });

    test(
      'yeni kayıt oturumu başlatır ve sonraki girişte kullanılabilir',
      () async {
        final repository = MockAuthRepository();

        final registerResult = await repository.register(
          fullName: 'Ayşe Yılmaz',
          email: 'ayse@example.com',
          tcKimlik: '10000000146',
          phone: '05551234567',
          password: 'GucluSifre1',
        );
        expect(registerResult, isA<Ok<AuthUser>>());

        await repository.logout();

        final loginResult = await MockAuthRepository().login(
          email: 'ayse@example.com',
          password: 'GucluSifre1',
        );
        expect(loginResult, isA<Ok<AuthUser>>());
      },
    );

    test('aynı e-posta ile ikinci kayıt reddedilir', () async {
      final repository = MockAuthRepository();
      await repository.register(
        fullName: 'Mehmet Demir',
        email: 'mehmet@example.com',
        tcKimlik: '10000000146',
        phone: '05551112233',
        password: 'GucluSifre1',
      );

      final result = await repository.register(
        fullName: 'Mehmet Demir',
        email: 'mehmet@example.com',
        tcKimlik: '10000000146',
        phone: '05551112233',
        password: 'BaskaSifre2',
      );

      expect(result, isA<Error<AuthUser>>());
    });

    test('kayıtlı olmayan e-posta ile şifre sıfırlama reddedilir', () async {
      final repository = MockAuthRepository();

      final result = await repository.sendPasswordResetLink(
        email: 'bilinmeyen@example.com',
      );

      expect(result, isA<Error<bool>>());
    });

    test('logout sonrası oturum geri yüklenmez', () async {
      final repository = MockAuthRepository();
      await repository.login(
        email: 'demo@parosis.com',
        password: 'Parosis123!',
      );
      await repository.logout();

      final restored = await MockAuthRepository().restoreSession();
      expect(restored, isNull);
    });
  });
}
