# Parosis — Oturum Durumu (2026-08-11)

Bu dosya, mobil login/kayıt/şifremi-unuttum akışı üzerinde yapılan çalışmanın
tam durumunu özetler. Başka bir bilgisayarda/Claude oturumunda devam ederken
önce bu dosyayı oku.

## Git durumu

- Branch: `main`
- Son commit: `b5e13df` — "Proje ilerledi"
- Bu commit **zaten `origin/main`'e push edilmiş** (`git rev-parse HEAD` ==
  `git rev-parse origin/main`). Diğer bilgisayarda sadece `git pull` yeterli.
- Çalışma ağacı bu commit'ten sonra temiz (untracked/uncommitted dosya yok).

```bash
git pull origin main
```

## Neden bu çalışma yapıldı

Kullanıcı, mevcut Flutter uygulamasına (feature-first mimari,
`docs/architecture/API_READY_PLAN.md`'de tarif edilen) 3 ekran görseli
göstererek "1:1 aynısı ama mobile uyarlanmış" bir login/kayıt/şifremi-unuttum
akışı istedi:

1. Login ekranı — ama:
   - Logo, kullanıcının verdiği yeni SVG (`Parosis Logo/parosis-akilli-sulama-favicon.svg`)
   - "Beni hatırla" checkbox'ı **kaldırıldı** (mobilde gereksiz)
   - "Facebook ile giriş yap" butonu → uygulamanın "kapalı/pasif" gri
     tonuyla (mist600, `#4F6763`) dolu bir **"Kayıt Ol"** butonuna dönüştü
   - "Hesabın yok mu? Kayıt ol" metin linki **kaldırıldı** (yerini gri
     buton aldı)
   - "Şifremi unuttum?" korundu
2. Şifremi Unuttum ekranı — gösterilen görseldeki tasarımla birebir
3. Kayıt Ol ekranı — tamamen Türkçe, alanlar: **Ad Soyad, E-posta,
   T.C. Kimlik No, Telefon, Şifre, Şifre Tekrar**
4. Login/kayıt tamamlanınca konum, kamera (fotoğraf), bildirim izinleri
   OS'in kendi izin pencereleriyle istenecek

### Kullanıcının verdiği 3 net karar (AskUserQuestion ile soruldu)

1. **Auth gate zorunlu**: Uygulama artık her açılışta önce Login ekranını
   gösterir, Home'a girişsiz erişilemez. "Gerçek mobil uygulama gibi."
2. **İzin akışı**: Ayrı bir "İzinler" ekranı YOK — login/kayıt başarılı
   olur olmaz doğrudan OS'in native izin pencereleri art arda açılır.
3. **Oturum kalıcılığı**: "Beni hatırla" kaldırıldığı için oturum, kullanıcı
   açıkça çıkış yapana kadar cihazda kalıcı kalır (varsayılan davranış,
   seçenek sunulmaz).

## Tamamlanan işler (hepsi commit'te)

### Yeni `auth` feature'ı (`lib/features/auth/`)

- `domain/entities/auth_user.dart` — oturum kimliği (id, fullName, email, phone).
  `profile` feature'ının kendi `User` modelinden **kasıtlı olarak ayrı** —
  mimari kural gereği feature'lar birbirine sızmıyor.
- `domain/repositories/auth_repository.dart` — `login`, `register`,
  `sendPasswordResetLink`, `restoreSession`, `logout` sözleşmesi.
- `data/repositories/mock_auth_repository.dart` — gerçek API gelene kadar
  kullanılan sahte "backend". Hesaplar + aktif oturum `shared_preferences`'a
  JSON olarak yazılır (uygulama kapansa da hesap listesi ve oturum kalır).
  **Seed (demo) hesap:**
  - E-posta: `demo@parosis.com`
  - Şifre: `Parosis123!`
- `presentation/controllers/auth_controller.dart` — `ChangeNotifier`,
  `isRestoring` / `isSubmitting` / `error` state'leri, projedeki diğer
  controller'larla (`WalletController` vb.) aynı desende.
- `presentation/widgets/`:
  - `auth_scaffold.dart` — logo + "Parosis" + "UZAKTAN KONTROL SİSTEMLERİ"
    başlığı + beyaz kart (`GlassPanel`) + telif satırı. Tüm 3 ekranın ortak
    iskeleti.
  - `auth_text_field.dart` — ikonlu, hata mesajlı, şifre alanlarında
    göster/gizle butonlu tek metin alanı bileşeni.
  - `auth_buttons.dart` — `AuthPrimaryButton` (nearBlack, "Giriş Yap" vb.),
    `AuthTonalButton` (mist600 gri, "Kayıt Ol"), `AuthOutlineButton`
    ("Google ile giriş yap" — bkz. aşağıdaki not), `AuthOrDivider`.
  - `auth_input_formatters.dart` — `TurkishPhoneInputFormatter` (05xx xxx xx xx
    gruplama).
- `presentation/screens/login_screen.dart`
- `presentation/screens/register_screen.dart`
- `presentation/screens/forgot_password_screen.dart` (gönderim sonrası
  başarı ekranı da aynı dosyada — "Bağlantı Gönderildi" state'i)
- `presentation/auth_flow.dart` — `AppRoot`'un enum tabanlı state machine
  desenini birebir kopyalayan, router paketi kullanmayan geçiş yöneticisi
  (login ↔ register ↔ forgot-password).

### Doğrulama (`lib/core/validation/auth_validators.dart`)

- `validateEmail`, `validatePassword`, `validateConfirmPassword`,
  `validateFullName`, `validatePhoneDigits`
- `validateTcKimlik` — **resmi T.C. Kimlik No checksum algoritması**
  (11 hane, ilk hane 0 olamaz, 10. ve 11. hane kontrol basamağı).
  Test/örnek olarak `10000000146` kullanılıyor (algoritmayı geçen, yaygın
  bilinen bir sahte/test numarası).

### İzinler (`lib/core/permissions/onboarding_permissions.dart`)

- `requestOnboardingPermissions()` — konum (`locationWhenInUse`), kamera,
  bildirim izinlerini sırayla ister. Platform eklentisi yoksa (masaüstü
  önizleme gibi) sessizce hiçbir şey yapmaz, akışı bloklamaz.
- Login/Register ekranlarında başarı sonrası `unawaited(...)` ile
  tetikleniyor (Home'a geçişi beklemeden, arka planda).
- **Eklenen paket:** `permission_handler: ^11.3.1` (pubspec.yaml).
- **Android:** `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`, `CAMERA`,
  `POST_NOTIFICATIONS` izinleri `android/app/src/main/AndroidManifest.xml`'e
  eklendi.
- **iOS:** `NSLocationWhenInUseUsageDescription`, `NSCameraUsageDescription`
  `ios/Runner/Info.plist`'e eklendi. (Bildirim izni iOS'ta plist anahtarı
  gerektirmiyor.)

### App-level bağlama

- `lib/app/app_gate.dart` (**yeni**) — kök widget. `authController.isRestoring`
  true iken kısa bir splash (yeni logo), sonra `isAuthenticated` false ise
  `AuthFlow`, true ise mevcut `AppRoot`'u gösterir. `ListenableBuilder` ile
  `AuthController`'ı dinler, otomatik geçiş yapar.
- `lib/app/app.dart` — `SulamaApp` artık `AppRoot` yerine `AppGate` render
  ediyor.
- `lib/app/app_dependencies.dart` — `AppDependencies`'e `authController`
  eklendi (`MockAuthRepository` ile kuruluyor), `dispose()`'a eklendi.
- `lib/app/app_root.dart` — `AppRoot` artık zorunlu `onLogout` callback'i
  alıyor, hamburger menüsündeki `AppDrawerOverlay`'e iletiyor.
- `lib/widgets/app_header.dart` — `AppDrawerOverlay`'e `onLogout` parametresi
  ve menüde ayraçla ayrılmış kırmızı **"Çıkış Yap"** satırı eklendi
  (`AppIcons.logout` yeni ikon).
- `lib/icons/app_icons.dart` — `eye`, `eyeOff`, `logout` ikonları eklendi
  (mevcut line-art stroke stiliyle).
- `assets/icons/parosis_mark.svg` (**yeni**) — kullanıcının verdiği yeni
  logo SVG'si buraya kopyalandı, `pubspec.yaml`'da asset olarak kayıtlı.
- `lib/features/profile/data/repositories/mock_profile_repository.dart` —
  eski "No login flow exists yet" yorumu güncellendi (artık yanlış bilgi
  içeriyordu).

### Testler

- `test/widget_test.dart` — `_signedInDependencies()` yardımcı fonksiyonu
  eklendi (demo hesapla repository seviyesinde giriş yapıp `AppDependencies`
  döner, UI üzerinden form doldurmadan). Home ekranını doğrulayan tüm
  testler artık önce bu şekilde giriş yapıyor. Yeni test: "Oturum yoksa
  açılışta giriş ekranı gösterilir".
- `test/features/auth/data/repositories/mock_auth_repository_test.dart`
  (**yeni**) — login başarı/başarısızlık, register + tekrar login, aynı
  e-posta ile ikinci kayıt reddi, kayıtsız e-posta ile şifre sıfırlama
  reddi, logout sonrası oturumun geri yüklenmemesi.
- `test/core/validation/auth_validators_test.dart` (**yeni**) — email,
  TC kimlik checksum, telefon, şifre tekrar doğrulamaları.

## ⚠️ BİLİNEN SORUN — auth işiyle İLGİSİZ, önceden var

`flutter analyze` şu 8 hatayı veriyor. **Bunların hiçbiri bu oturumdaki auth
çalışmasından kaynaklanmıyor** — `git diff` ile doğrulandı, `b1c6337`
("refactor: establish typed app architecture foundation") ve `451a490`
commit'lerinden (GitHub'dan bu oturumun başında pull edilen) kalma bir
uyumsuzluk:

- `lib/app/app_root.dart:107` — `ProfileScreen`'e `paymentCardsController`
  argümanı verilmiyor (zorunlu parametre).
- `lib/app/app_root.dart:109` — `ProfileScreen`'e artık var olmayan
  `onOpenCards` parametresi geçiriliyor.
- `lib/features/profile/presentation/screens/profile_screen.dart:149` —
  içeride tanımsız `onOpenCards` ismine referans var (muhtemelen
  `() => _openCards(context)` olmalıydı).
- `lib/app/app_root.dart:204` — `CardsModal`'a artık var olmayan `onClose`
  parametresi geçiriliyor.
- `test/features/payment_cards/presentation/screens/cards_responsive_test.dart:48`
  ve `test/features/profile/presentation/screens/profile_screen_test.dart:21/23`
  — aynı imza uyumsuzluğunun test tarafındaki yansımaları.

**Sonuç:** Proje şu an bu sebeple derlenmiyor (`flutter analyze` hata
veriyor, muhtemelen `flutter run`/`flutter test` de patlar). Bu, benim auth
değişikliklerimden bağımsız, refactor sırasında `ProfileScreen`/`CardsModal`
imzaları değişmiş ama çağıran taraflar (`AppRoot`, testler) güncellenmemiş.

## Sıradaki adımlar (öncelik sırasıyla)

1. **Önce yukarıdaki pre-existing hatayı düzelt** — muhtemel çözüm:
   - `AppRoot._buildScreen()`'deki `ProfileScreen(...)` çağrısına
     `paymentCardsController: deps.paymentCardsController` ekle, `onOpenCards`
     parametresini kaldır.
   - `ProfileScreen` içindeki `onTap: onOpenCards` satırını
     `onTap: () => _openCards(context)` yap (zaten tanımlı ama kullanılmayan
     `_openCards` metodu var — `unused_element` uyarısı da bunu doğruluyor).
   - `AppRoot`'taki `CardsModal(... onClose: ...)` çağrısından `onClose`
     argümanını kaldır (constructor artık almıyor).
   - İki test dosyasını da (`cards_responsive_test.dart`,
     `profile_screen_test.dart`) yeni imzalara göre güncelle.
2. `flutter analyze` temiz geçene kadar düzelt.
3. `flutter test` çalıştır, tüm testlerin geçtiğini doğrula (özellikle yeni
   auth testleri + güncellenen `widget_test.dart`).
4. Uygulamayı gerçek cihaz/emülatör veya `flutter run -d chrome` ile açıp
   görsel doğrulama yap:
   - Login ekranı → yeni logo doğru görünüyor mu, gri "Kayıt Ol" butonu
     doğru renkte mi
   - Kayıt Ol akışı → tüm alanlar, T.C. Kimlik No doğrulaması, başarılı
     kayıt sonrası otomatik giriş
   - Şifremi Unuttum → gönder sonrası başarı ekranı
   - Demo hesapla giriş (`demo@parosis.com` / `Parosis123!`) → Home'a
     düşüyor mu, izin pencereleri açılıyor mu (fiziksel cihazda/emülatörde
     görünür, web/masaüstü önizlemede sessizce atlanır)
   - Hamburger menüsü → "Çıkış Yap" → tekrar Login ekranına düşüyor mu
   - Uygulamayı kapat/aç → oturum hâlâ açık mı (kalıcılık testi)
5. Her şey yeşil olunca kullanıcıya görsel özet (ekran görüntüleri) sun.

## Dikkat edilecek tasarım/mimari kararları

- Router paketi **kullanılmıyor** (`API_READY_PLAN.md`'deki kısıtlama) —
  `AuthFlow` da `AppRoot` gibi enum + `setState` ile geçiş yapıyor.
- `auth` feature'ı `profile` feature'ından **bağımsız** tutuldu — login
  sonrası Profil ekranı hâlâ kendi sabit mock kullanıcısını (`Batuhan
  Canaracı`) gösteriyor, auth oturumundaki kullanıcıyla otomatik
  eşleşmiyor. Bu bilinçli bir sınır (mimari dokümanın "feature sınırları"
  kuralı); ileride profile'ı auth oturumuna bağlamak ayrı bir iş.
- "Google ile giriş yap" butonu görsel olarak korundu (kullanıcı sadece
  Facebook'u değiştirmemi istedi) ama gerçek OAuth entegrasyonu yok —
  tıklanınca "Google ile giriş yakında aktif olacak." snackbar'ı gösteriyor.
  Bu konuda kullanıcıya sorulmadı, mantıklı varsayım olarak uygulandı —
  istenirse kaldırılabilir veya gerçek entegrasyon eklenebilir.
- Renk paleti: gri buton için `AppColors.mist600` seçildi çünkü
  `lib/theme/colors.dart` içinde tam olarak "pasif / kapalı durumu" gri
  tonu olarak belgelenmiş — kullanıcının "kapalı gri renk gibi" tarifiyle
  birebir örtüşüyor.
