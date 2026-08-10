# Parosis API-Ready Mimari Planı

## Amaç

Mevcut Flutter arayüzünü ve davranışını korurken mock veriyi ekranlardan ayırmak,
API geldiğinde yalnızca data katmanını değiştirerek entegrasyon yapabilmek ve bir
özellikteki değişikliğin diğer özellikleri bozma riskini azaltmak.

Bu plan mevcut bağımlılıklara bağlı kalır. İlk yapısal dönüşümde yeni paket
eklenmeyecektir. `provider`, `dio`, `go_router`, kod üretimi veya service locator
kullanılmayacaktır.

## Mimari karar

Proje feature-first, katmanlı bir yapıya taşınacaktır:

```text
lib/
├── app/
│   ├── app.dart
│   ├── app_dependencies.dart
│   ├── app_root.dart
│   └── navigation/
├── core/
│   ├── error/
│   ├── result/
│   ├── formatting/
│   ├── theme/
│   ├── icons/
│   └── widgets/
└── features/
    ├── home/
    │   └── presentation/
    ├── wells/
    │   ├── domain/
    │   │   ├── entities/
    │   │   └── repositories/
    │   ├── data/
    │   │   └── repositories/
    │   └── presentation/
    │       ├── controllers/
    │       ├── screens/
    │       └── widgets/
    ├── irrigation/
    │   ├── domain/
    │   ├── data/
    │   └── presentation/
    ├── wallet/
    │   ├── domain/
    │   ├── data/
    │   └── presentation/
    ├── profile/
    │   ├── domain/
    │   ├── data/
    │   └── presentation/
    └── payment_cards/
        ├── domain/
        ├── data/
        └── presentation/
```

Her feature'da yalnız ihtiyaç duyulan klasörler oluşturulur. Boş veya tek satırlık
katmanlar sırf şablon tamamlamak için eklenmez.

## İzin verilen temel API ve desenler

- Dart 3 `sealed class`, `abstract interface class` ve exhaustive `switch`.
- Flutter `ChangeNotifier`, `Listenable` ve `ListenableBuilder`.
- SDK `Future`, `Stream`, `dart:convert` ve immutable modeller.
- Constructor injection: `Service -> Repository -> Controller -> Screen`.
- Projede yerel olarak tanımlanan `Result<T>`, `Ok<T>` ve `Error<T>`.
- Testlerde fake repository ve fake service implementasyonları.

Referanslar:

- [Flutter app architecture guide](https://docs.flutter.dev/app-architecture/guide)
- [Flutter architecture recommendations](https://docs.flutter.dev/app-architecture/recommendations)
- [Flutter case-study package structure](https://docs.flutter.dev/app-architecture/case-study#package-structure)
- [Flutter Result pattern](https://docs.flutter.dev/app-architecture/design-patterns/result#putting-it-all-together)
- [Flutter dependency injection](https://docs.flutter.dev/app-architecture/case-study/dependency-injection#dependency-injection)
- [Flutter architecture testing](https://docs.flutter.dev/app-architecture/case-study/testing)

## Katman kuralları

```text
Screen/Widget -> Controller -> Repository interface -> Repository implementation -> Service
```

- Presentation yalnız kendi controller'ını ve domain modellerini bilir.
- Controller repository interface'ini constructor üzerinden alır.
- Repository bir veri tipinin tek doğruluk kaynağıdır.
- Service yalnız dış veri kaynağını sarar; widget, controller veya `BuildContext`
  bilmez.
- API DTO'ları data katmanında kalır ve domain entity'lerine map edilir.
- Domain ve data katmanları Flutter widget/form sınıflarını import etmez.
- Feature presentation katmanları birbirini import etmez. Özellikler arası
  navigasyon `app` katmanı üzerinden callback veya route argümanıyla yapılır.
- Repository'ler birbirini çağırmaz. Birden çok feature verisini birleştiren akış
  controller'da, gerçekten karmaşıksa ayrı bir use-case içinde kurulur.

## Feature sınırları

- `wells`: kuyu kimliği, konum, kuyu durumu, listeleme ve düzenleme.
- `irrigation`: başlatma, durdurma, programlama, aktif oturum, geçmiş ve yaklaşan
  sulamalar. Kuyuya yalnız `wellId` üzerinden referans verir.
- `wallet`: bakiye, hesap hareketleri ve bakiye yükleme işlemi.
- `profile`: kullanıcı kimliği ve iletişim bilgileri.
- `payment_cards`: kart listesi, ekleme, silme, varsayılan kart ve kart saklama
  onayı. Profil ve wallet'tan ayrı tutulur.
- `home`: diğer feature'lardan gelen salt-okunur özetleri gösterir; mutation
  sahibi değildir.

## Faz 0 - Dokümantasyon ve sözleşme keşfi

Durum: Tamamlandı.

- Mevcut bağımlılıklar, ekran veri akışları ve test dikişleri çıkarıldı.
- Resmi Flutter/Dart mimari dokümanı incelendi.
- API dokümanı gelmeden endpoint, DTO alanı, auth veya payment-provider davranışı
  tanımlanmaması kararlaştırıldı.

Doğrulama:

- `flutter analyze`
- `flutter test`
- `pubspec.yaml` içinde yeni runtime bağımlılığı bulunmadığının kontrolü

Anti-pattern koruması:

- Transitive gelen `http` paketini doğrudan import etme.
- Henüz bulunmayan API methodu veya JSON alanı uydurma.

## Faz 1 - Core ve composition root

Durum: Tamamlandı. `core/result`, `core/formatting`, `AppDestination` typed
navigasyon ve `AppDependencies` composition root (`AppDependencies.mock()`)
kuruldu.

Uygulama:

1. Resmi Flutter örneğindeki `Result<T>`, `Ok<T>` ve `Error<T>` yapısını
   `core/result` altına uyarlayarak kopyala.
2. `AppDependencies` oluştur; repository implementasyonlarını tek bir composition
   root'ta kur.
3. `SulamaApp` ve `AppRoot` bağımlılıkları constructor ile alsın.
4. `formatTL` gibi feature bağımsız saf yardımcıları `core/formatting` altına taşı.
5. String ekran adlarını tek bir typed navigation tanımında topla. Router paketi
   ekleme.

Doküman:

- [Result pattern](https://docs.flutter.dev/app-architecture/design-patterns/result#putting-it-all-together)
- [Constructor injection](https://docs.flutter.dev/app-architecture/case-study/dependency-injection#dependency-injection)

Doğrulama:

- `Result` başarı/hata unit testleri.
- Mock dependency'lerle uygulamanın açılması.
- Mevcut 9 widget testinin geçmesi.
- `rg "mock_data.dart" lib/core lib/app` sonucunun boş olması.

Anti-pattern koruması:

- Global singleton veya service locator oluşturma.
- Repository'yi `BuildContext` üzerinden çözme.
- Core içine feature entity veya fixture taşıma.

## Faz 2 - Immutable domain ve mock repository'ler

Durum: Tamamlandı. Beş feature da immutable domain entity + `abstract
interface class ...Repository` + `Mock...Repository` üçlüsüne sahip.
`payment_cards`, görünen alanları (tam kart numarası/CVV hariç) cihazda
`shared_preferences` ile kalıcı hâle getiriyor; diğer dördü bellek-içi.

Uygulama sırası:

1. `wells`
2. `irrigation`
3. `wallet`
4. `profile`
5. `payment_cards`

Her feature için:

1. Flutter'dan bağımsız, immutable domain entity oluştur.
2. `abstract interface class ...Repository` sözleşmesini tanımla.
3. Mevcut mock veriyi feature-local mock repository arkasına taşı.
4. Liste döndüren repository'lerde mutable koleksiyonu dışarı açma.
5. Tarih, süre, miktar ve durumları önceden formatlanmış string yerine semantik
   tiplerle modelle; formatlama presentation/core katmanında yapılsın.

Örnek sözleşme:

```dart
abstract interface class WellRepository {
  Future<Result<List<Well>>> getWells();
}
```

Doğrulama:

- Her mock repository için unit test.
- `rg "mock_data.dart" lib/features` sonucunun boş olması.
- Entity dosyalarında `package:flutter` importu bulunmaması.
- Mevcut ekran çıktıları ve filtre davranışlarının değişmemesi.

Anti-pattern koruması:

- Bütün modelleri `core/models` altında toplama.
- API DTO ile domain entity'yi aynı sınıf yapma.
- Kart entity'sine `TextEditingController`, `FocusNode`, formatter veya Türkçe hata
  metni taşıma.
- `WellBadge.tone` gibi görsel renk bilgisini domain'de tutma.

## Faz 3 - Controller ve async UI state

Durum: Tamamlandı. Her feature'ın `ChangeNotifier` controller'ı
loading/data/error alanları taşıyor, mutasyonlarda `isSubmitting` ile tekrar
gönderimi engelliyor, ekranlar `ListenableBuilder` ile yalnız kendi
controller'ını dinliyor. Home ekranındaki canlı süre sayacı, controller'a
timer eklemek yerine widget'ın kendi `dispose()`'unda güvenle iptal edilen
yerel bir `Timer` ile çözüldü.

Uygulama:

1. Feature başına yalnız gereken controller'ları `ChangeNotifier` ile oluştur.
2. Controller repository'yi constructor ile alsın ve private tutsun.
3. UI state en az `initial/loading/data/empty/error` durumlarını temsil etsin.
4. Ekranlar `ListenableBuilder` ile yalnız gerekli alt ağacı rebuild etsin.
5. Kullanıcı komutlarında tekrar gönderimi önleyen running state ve görülebilir
   hata/başarı sonucu sağla.
6. Controller yaşam döngüsü ilgili screen/app katmanında açıkça dispose edilsin.

Doküman:

- [Flutter UI layer case study](https://docs.flutter.dev/app-architecture/case-study/ui-layer)
- [ChangeNotifier](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html)
- [ListenableBuilder](https://api.flutter.dev/flutter/widgets/ListenableBuilder-class.html)

Doğrulama:

- Controller unit testlerinde success, empty ve error yolları.
- Widget testlerinde loading/error/retry durumları.
- `Future`'ın `build()` içinde oluşturulmadığının kontrolü.
- Test bitiminde controller listener/dispose hatası bulunmaması.

Anti-pattern koruması:

- Widget içinde network/repository çağrısı yapma.
- Mutable listeyi yerinde değiştirip notification bekleme.
- `FutureBuilder` builder'ında navigation/snackbar/network side effect yapma.

## Faz 4 - Ekranları feature bazında taşıma

Durum: Kısmen tamamlandı. Tüm ekranlar `lib/features/*/presentation/screens`
altına taşındı, `lib/data/mock_data.dart` kaldırıldı, cross-feature
presentation importu yok. Kalan iş: aşağıdaki madde 5 — 2.000 satırlık kart
dosyasının kendi içinde alt dosyalara bölünmesi henüz yapılmadı; dosya
taşındı ve artık repository/controller üzerinden çalışıyor, ama tek dosya
olarak kalıyor.

Her feature tek başına taşınır ve doğrulanır:

1. Wells picker/list/edit sınırını `well_screens.dart` içinden çıkar.
2. Irrigation program/instant/home-summary ekranlarını wells presentation'dan ayır.
3. Wallet screen, top-up ve statement bileşenlerini birlikte taşı.
4. Profile modellerini sabit widget metinlerinden repository/controller'a al.
5. Yaklaşık 2.000 satırlık kart dosyasını entity, validation, controller,
   list/add/edit/legal ekranları ve feature widget'larına böl.
6. `AppHeader` ve `BottomNav` app-shell altında kalsın.

Doğrulama:

- Her feature taşımasından sonra `flutter analyze && flutter test`.
- Presentation-to-presentation cross-feature import bulunmaması.
- `lib/data/mock_data.dart` kullanımının sıfıra inmesi ve dosyanın kaldırılması.
- Kart responsive test matrisinin iPhone SE, notch'lu iPhone ve kompakt Android'de
  geçmesi.

Anti-pattern koruması:

- `well_screens.dart` dosyasını topluca wells veya irrigation feature'ına taşıma.
- `_CardEditResult` gibi navigation tiplerini domain katmanına koyma.
- `AppRoot` içinde bakiye/kart/sulama business state'i tutmaya devam etme.

## Faz 5 - API sözleşmesi geldiğinde remote data katmanı

Ön koşul:

- Swagger/OpenAPI, Postman collection veya doğrulanmış endpoint/JSON örnekleri.
- Auth, error body, pagination, tarih/saat ve para formatlarının açıklanması.

Uygulama:

1. Yalnız belgelenmiş endpointler için stateless service oluştur.
2. API DTO'larını data katmanında tanımla ve domain entity'lerine map et.
3. `Remote...Repository` implementasyonlarını ekle.
4. `AppDependencies.mock()` ve `AppDependencies.remote()` composition'larını
   ayır.
5. Auth/token saklama ve transport bağımlılığını ayrıca değerlendir; güvenli
   storage veya HTTP paketi gerekiyorsa bu fazda açıkça ekle.
6. Realtime ihtiyaç belgelenirse polling/WebSocket/MQTT seçimini sözleşmeye göre
   yap.
7. Kart numarası/CVV'yi repository veya yerel storage'da saklama; payment-provider
   tokenizasyonunu kullan.

Doğrulama:

- Service testleri fake transport/fixture ile.
- Repository mapping, success/error ve bozuk response testleri.
- ViewModel ve widget testleri remote transporttan bağımsız kalmalı.
- Mock ve remote composition aynı repository sözleşme testlerinden geçmeli.

Anti-pattern koruması:

- Belgede olmayan endpoint, query parametresi veya JSON alanı ekleme.
- API DTO'larını widget'a kadar taşıma.
- Token, API anahtarı, kart numarası veya CVV'yi repoya yazma.

## Faz 6 - Son doğrulama

- `dart format --output=none --set-exit-if-changed .`
- `flutter analyze`
- `flutter test`
- Android debug build.
- iOS simulator/fiziksel cihaz smoke testi.
- Import-boundary taraması.
- Loading, error, retry, empty, back navigation ve safe-area matrisi.

## API gelmeden cevaplanması gerekmeyen, API fazını belirleyen sorular

1. Sözleşme Swagger/OpenAPI, Postman veya başka formatta mı gelecek?
2. Authentication JWT/refresh token, OTP veya farklı bir yöntem mi kullanacak?
3. Kuyu/aktif sulama durumu polling, WebSocket veya MQTT ile mi güncellenecek?
4. Kart tokenizasyonu ve bakiye yükleme için hangi ödeme sağlayıcısı kullanılacak?
5. Offline cache ve güvenli yerel oturum saklama zorunlu mu?

Faz 1-4 bu cevaplar olmadan güvenle uygulanabilir. Faz 5 bu bilgiler gelmeden
başlatılmamalıdır.
