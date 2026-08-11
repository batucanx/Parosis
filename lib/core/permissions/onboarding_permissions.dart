import 'package:permission_handler/permission_handler.dart';

/// Giriş/kayıt tamamlandığı anda bir kez tetiklenir: konum, kamera ve
/// bildirim için işletim sisteminin kendi izin pencerelerini sırayla açar.
/// Uygulamanın hiçbir akışı bu izinlerin sonucuna bağlı değildir — kullanıcı
/// reddetse de Home'a geçiş engellenmez.
Future<void> requestOnboardingPermissions() async {
  try {
    for (final permission in const [
      Permission.locationWhenInUse,
      Permission.camera,
      Permission.notification,
    ]) {
      if (await permission.status.isDenied) {
        await permission.request();
      }
    }
  } catch (_) {
    // Masaüstü/web gibi platform eklentisinin bulunmadığı ortamlarda
    // onboarding izinleri sessizce atlanır.
  }
}
