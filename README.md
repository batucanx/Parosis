# Parosis Sulama

[![Flutter CI](https://github.com/batucanx/Parosis/actions/workflows/flutter.yml/badge.svg)](https://github.com/batucanx/Parosis/actions/workflows/flutter.yml)

Parosis sulama sistemlerinin mobil yönetimi için geliştirilen Flutter uygulaması. Tek kod tabanı üzerinden Android ve iOS hedeflerini destekler.

## Özellikler

- Programlı ve anlık sulama akışları
- Kuyu durumları ve aktif sulama takibi
- Bakiye, yükleme ve hesap hareketleri
- Kayıtlı kart ekleme, düzenleme ve silme akışları
- Kart saklama aydınlatma ve açık rıza arayüzleri
- Erişilebilir geri navigasyonu ve hareket azaltma desteği
- Android ve iOS platform yapılandırmaları

## Teknoloji

- Flutter 3.41 veya üzeri
- Dart 3.11 veya üzeri
- Android SDK ve Java 17
- iOS 13.0 veya üzeri
- Figtree değişken yazı tipi

## Kurulum

```bash
git clone https://github.com/batucanx/Parosis.git
cd Parosis
flutter pub get
flutter run
```

Bağlı cihazları görmek için:

```bash
flutter devices
```

## iPhone'a kurulum

iOS derlemesi ve fiziksel iPhone kurulumu macOS üzerinde Xcode gerektirir (Flutter 3.41 için güncel bir Xcode sürümü önerilir).

### Ön koşullar (Mac'te bir kez yapılır)

1. Xcode'u App Store'dan kurun, bir kez açıp lisans sözleşmesini onaylayın.
2. CocoaPods'u kurun. Projede üçüncü parti native eklenti olmasa da Flutter'ın iOS derlemesi kendi motoru için CocoaPods'a ihtiyaç duyar:
   ```bash
   sudo gem install cocoapods
   ```
3. Xcode → Settings → Accounts bölümünden Apple ID'nizi ekleyin (takım seçimi için gereklidir).
4. `flutter doctor` çalıştırıp iOS toolchain'inin eksiksiz olduğunu doğrulayın.

### Kurulum adımları

1. Repoyu Mac'e klonlayın ve `flutter pub get` çalıştırın.
2. `ios/Runner.xcworkspace` dosyasını Xcode ile açın.
3. `Runner > Signing & Capabilities` bölümünde Apple Developer takımınızı seçin.
4. Bundle Identifier değerinin `com.parosis.sulama` olduğunu doğrulayın.
5. iPhone'u bağlayın, cihazda Geliştirici Modu'nu etkinleştirin ve hedef cihaz olarak seçin.
6. Xcode'dan Run düğmesini veya aşağıdaki komutu kullanın:

```bash
flutter run -d <cihaz-id>
```

7. Uygulama telefona ilk kez yüklendiğinde açılmayabilir ("Untrusted Developer" hatası). Bunu çözmek için iPhone'da: **Ayarlar → Genel → VPN ve Cihaz Yönetimi**'nden geliştirici sertifikanıza dokunup **Güven**'i onaylayın.

> **Not:** Ücretsiz (Personal Team) Apple ID ile imzalanan uygulamalar cihazda yalnızca **7 gün** geçerlidir; süre dolunca uygulamayı Xcode'dan yeniden yüklemeniz gerekir. Kalıcı kurulum için ücretli Apple Developer Program üyeliği gerekir.

iOS release çıktısı:

```bash
flutter build ios --release
```

Apple Team ID, dağıtım sertifikaları ve provisioning profile dosyaları geliştirici hesabına özeldir; repoya dahil edilmez.

## Android derleme

Geliştirme APK'sı:

```bash
flutter build apk --debug
```

Google Play için release App Bundle:

```bash
flutter build appbundle --release
```

Üretim Android imzalama anahtarları `android/key.properties` üzerinden yerel olarak yapılandırılmalı ve Git'e eklenmemelidir. Başlangıç için `android/key.properties.example` dosyasını kopyalayıp yalnızca yerel değerlerle doldurun:

```bash
cp android/key.properties.example android/key.properties
```

Windows PowerShell karşılığı:

```powershell
Copy-Item android/key.properties.example android/key.properties
```

## Kod kalitesi

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

## Proje yapısı

```text
.
├── android/              Android platform projesi
├── ios/                  iOS/Xcode platform projesi
├── assets/               Logo ve yazı tipi varlıkları
├── lib/
│   ├── app/              Composition root, AppRoot kabuğu, typed navigasyon
│   ├── core/             Result, formatlama gibi feature'dan bağımsız yardımcılar
│   ├── features/         wells, irrigation, wallet, profile, payment_cards, home
│   │                     (her biri domain/data/presentation katmanlarıyla)
│   ├── icons/            Uygulama ikon bileşenleri
│   ├── theme/            Renk ve tipografi sistemi
│   └── widgets/          Paylaşılan arayüz bileşenleri (app-shell düzeyinde)
├── test/                 Flutter widget testleri
├── .github/workflows/    Otomatik analiz ve test iş akışı
└── pubspec.yaml          Paket ve varlık tanımları
```

## Güvenlik ve üretim notları

- Her feature'ın `data/repositories/Mock...Repository` sınıfı arayüz geliştirme verisi içerir; üretim backend'i değildir. API sözleşmesi geldiğinde yalnızca bu dosyalar `Remote...Repository` ile değiştirilir (bkz. `docs/architecture/API_READY_PLAN.md`).
- Kayıtlı kartların yalnızca görünen alanları (etiket, son 4 hane, son kullanma, kart ağı, varsayılan bayrağı) cihazda `shared_preferences` ile saklanır; tam kart numarası veya CVV/CVC hiçbir zaman saklanmaz.
- Gerçek kart numarası ve CVV/CVC uygulama içinde veya yerel depolamada saklanmamalıdır.
- Kart saklama işlemi PCI DSS uyumlu ödeme kuruluşunun tokenizasyon sistemi üzerinden yürütülmelidir.
- API adresleri, anahtarlar, sertifikalar ve imzalama dosyaları repoya eklenmemelidir.
- Aydınlatma ve açık rıza metinleri üretime çıkmadan önce şirketin hukuk/KVKK süreçleriyle doğrulanmalıdır.

## Uygulama kimlikleri

- Dart paketi: `parosis_sulama`
- Android application ID: `com.parosis.sulama`
- iOS bundle identifier: `com.parosis.sulama`
