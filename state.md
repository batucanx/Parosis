# Parosis — Oturum Durumu (2026-08-12)

> Not: Bu dosyanın en altındaki "2026-08-11" bölümü önceki oturumun kaydı.
> Bugünkü (2026-08-12) oturumda **daha önce ertelenen kuyu sahipliği/sıra
> sistemi işine** başlandı — aşağıdaki yeni bölüm önce okunmalı.

## 2026-08-12 oturumu — Program Sulama kuyu düzenleme ekranı (Sıra Al akışı)

Önceki oturumda (`project_well_ownership_deferred` memory kaydı) bilinçli
olarak ertelenen iş burada kısmen ele alındı: kullanıcı, Program Sulama'da
bir kuyuya tıklandığında açılan ekranın içeriğini gösteren bir ekran
görüntüsü paylaştı (Başlangıç/Bitiş seçimi, "Günün doluluğu" şeridi, "Sıra
Al" butonu, "Bu günün randevuları" listesi) ve `WellEditScreen`'in
("Bu bölüm yakında aktif olacak." yer tutucusu) bu şekilde
doldurulmasını istedi.

**Bilinçli kapsam kararı:** Tam çoklu-kullanıcı kuyu havuzu (Well
entity'sine `ownerId` eklemek, Anlık Sulama'nın "Meşgul: X kullanıyor"
canlı durumunu göstermesi) hâlâ ayrı bırakıldı — `Well` entity'si
değiştirilmedi. Sadece Program Sulama'dan açılan `WellEditScreen`
dolduruldu; Anlık Sulama'dan açılan aynı ekran hâlâ eski yer tutucuyu
gösteriyor (`isSchedulingContext: false` durumunda).

**Yeni/değişen dosyalar:**
- [well_booking_request.dart](lib/features/well_bookings/domain/entities/well_booking_request.dart) —
  `wellId` alanı eklendi (artık taleplerin gerçek bir kuyuya bağlanması
  mümkün).
- `well_schedule_entry.dart` (yeni) — "Günün doluluğu" şeridi/"Bu günün
  randevuları" listesi için `WellScheduleEntry` (start, end?, personName,
  kind: mine/occupied/pendingApproval).
- [well_booking_repository.dart](lib/features/well_bookings/domain/repositories/well_booking_repository.dart) —
  arayüze `getDaySchedule(wellId, date)` ve `requestSlot(...)` eklendi.
- [mock_well_booking_repository.dart](lib/features/well_bookings/data/repositories/mock_well_booking_repository.dart) —
  yukarıdakilerin mock implementasyonu. Gerçek çoklu kullanıcı verisi
  olmadığı için "başkalarının dolulukları", kuyu id'sine ve güne göre
  **deterministik sahte veri** (`_syntheticOthers`, `dart:math` `Random`
  sabit seed ile) — her açılışta aynı sonucu verir, gerçek backend'e kadar
  geçici çözüm. Prefs anahtarı `well_bookings_v1_` → `well_bookings_v2_`
  olarak bump'landı (şema değişti, eski cache'i sessizce eziyor).
- [well_bookings_controller.dart](lib/features/well_bookings/presentation/controllers/well_bookings_controller.dart) —
  `loadDaySchedule(...)` (ekrana özel anlık sorgu, ana `_requests`/`isLoading`'i
  etkilemez) ve `requestSlot(...)` (başarılı olursa yeni talep hemen
  "Taleplerim" listesine de eklenir) eklendi.
- [well_screens.dart](lib/features/wells/presentation/screens/well_screens.dart) —
  `WellEditScreen` artık `StatefulWidget`; `isSchedulingContext=true` iken
  tam ekran (bkz. aşağıdaki "devam" bölümü — bu ekran aynı oturumda ikinci
  kez revize edildi, Bitiş picker'ı kaldırılıp saat girişine çevrildi).
- [app_root.dart](lib/app/app_root.dart) — `WellEditScreen`'e artık
  `wellBookingsController` ve `isSchedulingContext` (`_wellEditBackTarget
  == AppDestination.program`) geçiliyor.
- [pubspec.yaml](pubspec.yaml) + [app.dart](lib/app/app.dart) — native
  `showDatePicker` Türkçe görünsün diye `flutter_localizations` SDK
  paketi eklendi, `MaterialApp`'e `locale: Locale('tr')` +
  `localizationsDelegates` tanımlandı. **Bu oturumda `flutter pub get`
  çalıştırılmadı** (self-testing yok kuralı) — ilk derlemede otomatik
  çekilecek, ama ilk `flutter run`/`pub get` denemesi önemli.

## Aynı oturumun devamı — Bitiş kaldırıldı, saat girişi, dost saat seçici, navbar, Geçmiş Sulamalar, kırmızı rozet nabzı

Yukarıdaki Program Sulama ekranı bittikten hemen sonra, **aynı oturumda**,
kullanıcı arka arkaya 5 farklı revizyon/yeni özellik istedi. Hepsi
tamamlandı, kod tabanı tutarlı durumda ama **hiçbiri test edilmedi**
(`flutter analyze`/`test`/`run` çalıştırılmadı — kural gereği).

### 1. Program Sulama ekranı — Bitiş picker'ı kaldırıldı, "kaç saat" girişi eklendi

Kullanıcı: Başlangıç tarih+saat kalsın ama Bitiş tamamen kaldırılsın;
onun yerine "kaç saat sulama yapılacak" sorulsun, Bitiş bu saate göre
otomatik hesaplansın (50 saat gibi büyük değerler günü aşabilir).

- `_WellEditScreenState`'te `_end` artık ayrı bir state değil,
  `_start + _durationHours saat` şeklinde hesaplanan bir **getter**.
  `_durationHours` (`int?`, kullanıcı süreyi girene kadar `null`) +
  `_hoursController` (`TextEditingController`, başlangıçta boş, hint
  "Örn: 2") eklendi. Min süre artık **15 dk değil, 1 saat**
  (`_minDurationHours`).
- `_BookingRangePanel` tek sütuna indi (sadece BAŞLANGIÇ), altına
  `_HoursField` (sayısal, sadece rakam, max 3 hane) ve altına da
  salt-okunur `_ComputedEndRow` ("Bitiş: DD.MM.YYYY HH:mm", süre
  girilmeden "Süreyi girin, bitiş otomatik hesaplansın." uyarısı)
  eklendi.
- Çakışma kontrolü hâlâ sadece **başlangıç gününün** günlük programına
  bakıyor — 50 saatlik bir seçim 2-3 günü kapsasa bile "Günün doluluğu"
  şeridi ve çakışma kontrolü yalnızca ilk günü değerlendiriyor (çok
  günlü çakışma kontrolü ayrı bir iş, şimdilik bilinçli sınırlama).

### 2. Saat seçimi — native clock dial yerine dost tekerlekli seçici

Kullanıcı: tarih seçimi iyi ama saat seçimi (`showTimePicker`'ın analog
kadranı) kullanıcı dostu değil, değiştir.

- Yeni `_showFriendlyTimePicker` + `_TimePickerSheet` + `_TimeWheel`
  ([well_screens.dart](lib/features/wells/presentation/screens/well_screens.dart)) —
  alttan açılan sayfa, `CupertinoPicker` ile saat (0-23) ve dakika
  (5'er dakika, 0-55) için iki ayrı kaydırmalı tekerlek + "Tamam" butonu.
  Bunun için `flutter/cupertino.dart` import edildi (Material'la birlikte
  kullanımı standart, çakışma yok). Tarih seçimi hâlâ standart
  `showDatePicker`.

### 3. Alt navigasyon — "damla" (yüzen pill) model kaldırıldı, ekranın altına bitişik

Kullanıcı: navbar artık yüzen/tam yuvarlak (damla) model olmayacak, alt
kenara bitişik olsun.

- [app_root.dart](lib/app/app_root.dart) — `BottomNav`'ı saran
  `Positioned`, `left:12/right:12/bottom:16` (yüzen, kenarlardan boşluklu)
  yerine `left:0/right:0/bottom:0` (tam ekran genişliğinde, alta bitişik).
- [bottom_nav.dart](lib/widgets/bottom_nav.dart) — dış `GlassNav`'ın
  `borderRadius`'u tam yuvarlak `circular(999)` yerine sadece üst
  köşelerden yuvarlak (`BorderRadius.vertical(top: Radius.circular(22))`) —
  artık bir "dock" gibi, pill/damla değil.

### 4. Yeni ekran: "Geçmiş Sulamalar" (hamburger menüde daha önce hiçbir yere gitmeyen dead-stub girişti)

Kullanıcı, referans "Su" panelinden 4 ekran görüntüsü paylaştı: bir kuyu
seçme listesi, ardından o kuyunun GÜN/TOPLAM KULLANIM özet kutuları,
günlük kullanım çubuk grafiği, "Detayı gizle/göster" ile açılıp kapanan
gün bazlı liste (her günde birden fazla **farklı kişinin** kullanım
süresi + oturum sayısı + o günün toplamı). Tek istisna: detay
ekranındaki "Kuyu değiştir" butonu **eklenmedi** — geri tuşu zaten listeye
dönüyor.

Bu, geçen oturumdan ertelenen çoklu-kullanıcı kuyu havuzu temasıyla aynı
soy (bkz. memory `project_well_ownership_deferred`) — aynı kuyuda birden
fazla ismin görünmesi gerekiyordu, bu yüzden `Well` entity'sine
dokunulmadı, veri sentetik/sahte üretildi (tıpkı `well_bookings`'teki
`_syntheticOthers` gibi).

**Yeni/değişen dosyalar:**
- [past_irrigation.dart](lib/features/irrigation/domain/entities/past_irrigation.dart) —
  `personName` alanı eklendi (kuyuyu kim kullandı).
- [mock_irrigation_repository.dart](lib/features/irrigation/data/repositories/mock_irrigation_repository.dart) —
  eski 3 sabit `_past` kaydı kaldırıldı, yerine `_generatePastIrrigations(wellId)`
  geldi: her kuyu id'sine göre deterministik (Random, `wellId.hashCode`
  seed'li) 5-8 gün, günde 1-4 oturum, kişi adı 5 kişilik sabit havuzdan
  (`Ali Yurtseven, Mehmet Polat, Fatma Yılmaz, Hasan Demir, Ayşe Kara` —
  `well_bookings`'teki havuzla aynı isimler, tutarlılık için), süre
  ~%70 kısa (1-60 dk) / %30 uzun (1-20 saat) karışık, `waterLiters` eski
  sabit veriyle aynı orana (~27.5 L/dk) göre hesaplanıyor. Tüm 5 mock kuyu
  (k1-k5) için üretiliyor.
- `past_irrigations_screen.dart` (yeni,
  [lib/features/irrigation/presentation/screens/](lib/features/irrigation/presentation/screens/past_irrigations_screen.dart)) —
  `PastIrrigationsScreen` (aranabilir kuyu listesi, `WellsController`'ı
  kullanır) + `PastIrrigationDetailScreen` (GÜN/TOPLAM KULLANIM
  `_StatTile`'ları, `_DailyUsageChart` — elle çizilmiş çubuk grafik,
  yeni bir chart paketi eklenmedi —, `_DetailToggle` ile açılır/kapanır
  `_DayDetailCard` listesi, her günde kişi bazlı `_PersonBadge`'ler).
  Grafikte bir güne dokunursa (`onBarTap`) detay otomatik açılır ve o
  günün kartı yeşil çerçeveyle vurgulanır (otomatik scroll yok, sadece
  vurgu — kapsam dışı bırakıldı).
- [app_destination.dart](lib/app/navigation/app_destination.dart) —
  `pastIrrigations` (liste) ve `pastIrrigationDetail` (detay, geri hedefi
  her zaman `pastIrrigations`) eklendi.
- [app_root.dart](lib/app/app_root.dart) — `_selectedHistoryWellId` state'i
  + `_openPastIrrigationDetail`, iki yeni destination `_buildScreen()`'e
  eklendi, `AppDrawerOverlay`'e `onOpenHistory` bağlandı.
- [app_header.dart](lib/widgets/app_header.dart) — `AppDrawerOverlay`
  artık `onOpenHistory` parametresi alıyor; "Geçmiş Sulamalar" satırı
  önceden sadece menüyü kapatıyordu (`onTap: onClose`), artık gerçekten
  `pastIrrigations` ekranına gidiyor.

### 5. Kırmızı (deaktif) bileşen rozetleri — dikkat çekmek için yavaş nabız

Kullanıcı: Pompa/Termik/Enerji/Haberleşme rozetlerinden deaktif olanlar
(kırmızı) hafifçe yanıp sönsün, ~2 saniyede bir, sert/hızlı olmasın.

- [well_screens.dart](lib/features/wells/presentation/screens/well_screens.dart) —
  `_WellComponentBadge` artık `StatefulWidget`. Sadece **offline**
  rozetler için `AnimationController` (1sn, `repeat(reverse: true)` →
  tam döngü ~2sn, `Curves.easeInOut`) arkaplan ve nokta rengini
  `red100↔red200` / `red500↔red600` arası yumuşakça geçiriyor; **yazı
  rengi sabit** kalıyor (okunaklılık için). `MediaQuery.disableAnimationsOf`
  açıksa (reduce motion) animasyon atlanıp sabit kırmızı gösteriliyor.
  Online (yeşil) rozetler değişmedi, animasyonsuz.

## Sıradaki adımlar

1. **Kullanıcı kendi doğrulasın** (self-testing yok kuralı — hiçbiri
   bu oturumda çalıştırılmadı):
   - `flutter pub get` (yeni `flutter_localizations` bağımlılığı için).
   - `flutter analyze` — özellikle bu oturumda çok değişen
     `well_screens.dart` (~1630 satır) ve yeni `past_irrigations_screen.dart`.
   - `flutter test`.
2. Görsel doğrulama:
   - Program Sulama → bir kuyu seç → Başlangıç tarih/saat seç (saat artık
     tekerlekli alt sayfa), "kaç saat" gir, Bitiş'in otomatik dolduğunu
     gör, "Sıra Al" ile talep gönder.
   - Alt navigasyon artık ekranın en altına bitişik ve üst köşeleri
     yuvarlak (damla/pill değil).
   - Hamburger menü → "Geçmiş Sulamalar" → bir kuyu seç → grafik + detay
     aç/kapa + kişi bazlı rozetler doğru görünüyor mu; bir çubuğa dokunca
     detay açılıp o gün vurgulanıyor mu.
   - Herhangi bir kuyu kartında offline (kırmızı) bir bileşen rozeti
     bulup yavaşça nabız attığını, yeşil rozetlerin sabit kaldığını
     doğrula.
3. `Well` entity'sine gerçek sahiplik (`ownerId`) hâlâ eklenmedi — bkz.
   memory `project_well_ownership_deferred`. Hem "Günün doluluğu" hem
   "Geçmiş Sulamalar"daki diğer kişilerin verisi hâlâ sentetik/sahte.
4. Anlık Sulama'dan açılan `WellEditScreen` hâlâ eski "yakında aktif
   olacak" yer tutucusunu gösteriyor (`isSchedulingContext=false`).
5. Her şey yeşil olunca commit at.

---

# Parosis — Oturum Durumu (2026-08-11)

Bu dosya, mobil login/kayıt akışı + kayıtlı kart/profil düzeltmeleri + yeni
"Taleplerim" ekranı üzerinde yapılan çalışmanın tam durumunu özetler. Başka
bir bilgisayarda/Claude oturumunda devam ederken önce bu dosyayı oku.

## Git durumu

- Branch: `main`
- Son commit: `5197786` — "Oturum devam belgesi (state.md) eklendi" — bu
  commit **zaten `origin/main`'e push edilmiş**.
- **Bu oturumdaki tüm işler henüz commit'lenmedi** (proje kuralı:
  self-testing yok, Claude commit atmıyor — kullanıcı kendi test edip
  commit atacak). `git status` çıktısı:

```
M  assets/icons/parosis_mark.svg
M  lib/app/app_dependencies.dart
M  lib/app/app_root.dart
M  lib/app/navigation/app_destination.dart
M  lib/features/auth/data/repositories/mock_auth_repository.dart
M  lib/features/payment_cards/data/repositories/mock_payment_cards_repository.dart
M  lib/features/payment_cards/presentation/screens/cards_modal.dart
M  lib/features/profile/data/repositories/mock_profile_repository.dart
M  lib/features/profile/presentation/screens/profile_screen.dart
M  lib/widgets/app_header.dart
M  pubspec.lock
M  test/features/payment_cards/presentation/screens/cards_responsive_test.dart
M  test/features/profile/presentation/screens/profile_screen_test.dart
?? ios/Podfile
?? lib/core/geo/                       (turkey_provinces.dart, countries.dart)
?? lib/features/well_bookings/         (yeni feature)
?? lib/features/well_requests/         (yeni feature)
?? lib/widgets/searchable_picker_field.dart
```

## Bu oturumda tamamlanan işler

### 1. Runtime hata düzeltmesi — kayıt olurken çöküyordu

`lib/features/auth/data/repositories/mock_auth_repository.dart:76` —
`_seedAccounts()` `const` (değiştirilemez) bir liste döndürüyordu;
`_loadAccounts()` ilk çalıştırmada bunu doğrudan `_cache`'e atıyordu, sonra
`register()` bu listeye `.add()` yapmaya çalışınca
`Unsupported operation: Cannot add to an unmodifiable list` ile çöküyordu.
Fix: `_cache = List<_Account>.of(_seedAccounts());`.

### 2. Logo SVG'si siyah kutu olarak görünüyordu

`assets/icons/parosis_mark.svg` — Illustrator'dan export edilmiş, `<style>`
bloğu + CSS class (`class="cls-1"` vb.) tabanlıydı. `flutter_svg`,
`<style>` bloğundaki class-tabanlı fill tanımlarını çözemiyor, elemanlar
SVG varsayılanı olan siyahla doluyordu. Fix: her class referansı doğrudan
elemanın üzerine `fill="..."` attribute'u olarak yazıldı, `<style>` bloğu
kaldırıldı.

### 3. Profil ve Kayıtlı Kartlar artık oturum kullanıcısına bağlı

Önceden: `MockProfileRepository` sabit "Batuhan Canaracı" verisi
döndürüyordu, `MockPaymentCardsRepository` tüm hesaplar için **tek** global
kart listesi kullanıyordu (yeni kayıt olan kullanıcı bile eski test
kartlarını görüyordu).

Fix:
- `MockProfileRepository` artık composition root'tan (`AppDependencies`)
  verilen `currentAuthUser: () => AuthUser?` callback'i ile oturumdaki
  kullanıcıyı okuyor.
- `MockPaymentCardsRepository` artık `currentUserId` ile
  `payment_cards_v1_<userId>` şeklinde kullanıcı bazlı `shared_preferences`
  anahtarı kullanıyor. **Sadece sabit demo hesap** (`SLM-10001`) örnek
  kartlarla geliyor; her yeni gerçek kullanıcı boş listeyle başlıyor.
- `AppDependencies.mock()` içinde `authController.addListener(...)` ile
  login/kayıt/çıkışta bu iki controller otomatik `refresh()` ediliyor.
- `cards_modal.dart`'a kart listesi boşken "Henüz kayıtlı kartınız yok"
  empty-state eklendi.
- Telefon numarası artık Profil'de `0532 118 04 76` formatlı gösteriliyor
  (ham veri `05321180476` — `_formatPhone` ile formatlanıyor).

### 4. iOS Podfile eklendi (permission_handler için)

`ios/Podfile` projede **hiç yoktu** (iOS build hiç tetiklenmedi çünkü
geliştirme Windows'ta). `permission_handler` (konum/kamera/bildirim,
[onboarding_permissions.dart](lib/core/permissions/onboarding_permissions.dart))
iOS'ta CocoaPods entegrasyonunda her izni `GCC_PREPROCESSOR_DEFINITIONS`
ile açıkça açmayı gerektiriyor. Podfile, sadece kullanılan 3 izni
(`PERMISSION_CAMERA`, `PERMISSION_LOCATION_WHENINUSE`,
`PERMISSION_NOTIFICATIONS`) açık bırakacak şekilde yazıldı, geri kalanı
kapalı. **Mac/Xcode olmadığı için bu dosya derlenip test edilemedi** —
kullanıcı Mac'e geçtiğinde `cd ios && pod install` ile ilk denemeyi
kendisi yapmalı.

### 5. Yeni "Taleplerim" ekranı — hamburger menüdeki 2 girişin birleşimi

Kullanıcı, referans bir "Su" web panelinin ekran görüntülerini paylaşarak
hamburger menüdeki ayrı "Kuyu Taleplerim" ve "Talepler" girişlerinin
(ki ikisi de daha önce **hiçbir yere gitmiyordu**, sadece menüyü
kapatıyordu) tek bir ekranda birleştirilmesini istedi. Netleştirilen 3
karar (AskUserQuestion ile soruldu):

1. Onaylanan kuyu talebi, ileride Kuyu sekmesindeki listeye otomatik
   eklenecek (backend işi, bu oturumda bağlanmadı — bkz. aşağıdaki not).
2. "Randevu talebi" = kullanıcıların birbirlerinin kuyusunda zaman dilimi
   ayırması (paylaşımlı sulama sistemi).
3. Bu oturumda **sadece** birleşik "Taleplerim" ekranı kurulacak; kuyu
   sahipliği + sıra/kuyruk sistemi (Program Sulama/Anlık Sulama rework)
   **ayrı bir oturuma bırakıldı** — kullanıcı bunu hatırlatmamı istedi.

**Yeni dosyalar:**
- `lib/core/geo/turkey_provinces.dart` — TÜİK kaynaklı gerçek il/ilçe
  verisi (81 il, 973 ilçe; GitHub'daki `volkansenturk/turkiye-iller-ilceler`
  JSON'undan script ile üretildi, elle yazılmadı).
- `lib/core/geo/countries.dart` — Türkçe ülke listesi, "Türkiye" en üstte.
- `lib/widgets/searchable_picker_field.dart` — yeniden kullanılabilir,
  aranabilir tek seçim alanı (bottom sheet + arama kutusu).
- `lib/features/well_requests/` — yeni kuyu kayıt talebi feature'ı (domain
  + `MockWellRequestRepository` + `WellRequestsController` + liste ekranı
  + form ekranı — Kuyu Adı, Ülke/İl/İlçe/Mahalle/Posta Kodu/Açık
  Adres/Koordinat).
- `lib/features/well_bookings/` — randevu talebi feature'ı
  (basitleştirilmiş model: sadece listeleme + onayla/reddet/iptal et,
  **yeni randevu oluşturma akışı yok** — bkz. aşağıdaki not).
- `RequestsScreen` (`well_requests/presentation/screens/requests_screen.dart`)
  — iki sekmeli birleşik ekran ("Kuyu Talepleri" / "Randevu Talepleri").

**Wiring:** `AppDestination.requests` eklendi, `AppDependencies`'e
`wellRequestsController`/`wellBookingsController` eklendi (auth değişince
otomatik `refresh()`), `app_header.dart`'taki hamburger menüsü artık
tek bir "Taleplerim" satırı gösteriyor ve gerçekten `RequestsScreen`'e
gidiyor. "Geçmiş Sulamalar" girişi hâlâ bağlanmadı (ayrı iş).

Her iki mock repository de sadece sabit demo hesap (`SLM-10001`) için
örnek veriyle geliyor (kuyu talebi: 1 bekleyen; randevu: 1 gelen bekleyen,
1 giden bekleyen, 1 giden onaylanmış) — gerçek yeni kullanıcılar boş
listeyle başlıyor.

## ⚠️ Bilerek YAPILMAYAN / ertelenen iş — bir sonraki oturumda hatırlat

Kullanıcı, Anlık Sulama/Program Sulama ekranlarının aslında **çok
kullanıcılı, paylaşımlı bir kuyu havuzu** olduğunu gösteren ek ekran
görüntüleri paylaştı (kuyular farklı kişilere ait, "Meşgul: X kullanıyor"
canlı durumu, Program Sulama'da "Sıra Al" ile günün doluluk çizelgesinden
randevu alma akışı). Bu, `Well` entity'sine sahiplik eklemeyi ve
`ProgramScreen`/`InstantScreen`'i ([well_screens.dart](lib/features/wells/presentation/screens/well_screens.dart))
baştan yazmayı gerektiren büyük bir iş — kullanıcı bunu **bilinçli olarak
bu oturumun kapsamı dışında bıraktı** ve "başka oturumda hatırlat" dedi.
Detaylar Claude'un memory sisteminde (`project_well_ownership_deferred`)
kayıtlı; wells/Program Sulama/Anlık Sulama/randevu konuşulduğunda bunu
proaktif olarak gündeme getir.

## Sıradaki adımlar (öncelik sırasıyla)

1. **Kullanıcı kendi doğrulasın** (self-testing yok kuralı):
   - `flutter analyze` — temiz geçmeli. Yeni eklenen çok sayıda dosya var,
     ilk analiz turu önemli.
   - `flutter test` — özellikle güncellenen `cards_responsive_test.dart`
     ve `profile_screen_test.dart`.
2. Görsel doğrulama:
   - Yeni logo doğru görünüyor mu (artık siyah kutu değil).
   - Yeni bir hesapla kayıt ol → Profil bilgileri doğru mu, Kayıtlı
     Kartlar boş başlıyor mu.
   - Hamburger menü → "Taleplerim" → iki sekme çalışıyor mu:
     - Kuyu Talepleri: "Yeni Kuyu Talebi" formu (Ülke/İl/İlçe arama
       sheet'leri dahil), Düzenle/Sil.
     - Randevu Talepleri: durum filtreleri, Onayla/Reddet/İptal Et.
   - Demo hesapla (`demo@parosis.com` / `Parosis123!`) girince her iki
     sekmede de örnek veri görünmeli.
3. iOS tarafı: Mac'e geçince `pod install` dene, izin pencerelerini
   fiziksel cihazda doğrula (bkz. yukarıdaki Podfile notu).
4. Her şey yeşil olunca commit at.
5. Sıradaki içerik işi: "Geçmiş Sulamalar" hamburger menü girişini
   doldurmak (henüz hiç ele alınmadı).
