# Parosis Sulama

[![Flutter CI](https://github.com/batucanx/SulamaProject/actions/workflows/flutter.yml/badge.svg)](https://github.com/batucanx/SulamaProject/actions/workflows/flutter.yml)

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
git clone https://github.com/batucanx/SulamaProject.git
cd SulamaProject
flutter pub get
flutter run
```

Bağlı cihazları görmek için:

```bash
flutter devices
```

## iPhone'a kurulum

iOS derlemesi ve fiziksel iPhone kurulumu macOS üzerinde Xcode gerektirir.

1. Repoyu Mac'e klonlayın ve `flutter pub get` çalıştırın.
2. `ios/Runner.xcworkspace` dosyasını Xcode ile açın.
3. `Runner > Signing & Capabilities` bölümünde Apple Developer takımınızı seçin.
4. Bundle Identifier değerinin `com.parosis.sulama` olduğunu doğrulayın.
5. iPhone'u bağlayın, cihazda Geliştirici Modu'nu etkinleştirin ve hedef cihaz olarak seçin.
6. Xcode'dan Run düğmesini veya aşağıdaki komutu kullanın:

```bash
flutter run -d <cihaz-id>
```

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
│   ├── data/             Geçici yerel veri modelleri
│   ├── icons/            Uygulama ikon bileşenleri
│   ├── screens/          Uygulama ekranları
│   ├── theme/            Renk ve tipografi sistemi
│   └── widgets/          Paylaşılan arayüz bileşenleri
├── test/                 Flutter widget testleri
├── .github/workflows/    Otomatik analiz ve test iş akışı
└── pubspec.yaml          Paket ve varlık tanımları
```

## Güvenlik ve üretim notları

- Mevcut `lib/data/mock_data.dart` dosyası arayüz geliştirme verileri içerir; üretim backend'i değildir.
- Gerçek kart numarası ve CVV/CVC uygulama içinde veya yerel depolamada saklanmamalıdır.
- Kart saklama işlemi PCI DSS uyumlu ödeme kuruluşunun tokenizasyon sistemi üzerinden yürütülmelidir.
- API adresleri, anahtarlar, sertifikalar ve imzalama dosyaları repoya eklenmemelidir.
- Aydınlatma ve açık rıza metinleri üretime çıkmadan önce şirketin hukuk/KVKK süreçleriyle doğrulanmalıdır.

## Uygulama kimlikleri

- Dart paketi: `parosis_sulama`
- Android application ID: `com.parosis.sulama`
- iOS bundle identifier: `com.parosis.sulama`
