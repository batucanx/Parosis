# Sulama Sistemi — Tasarım Prototipi

Flutter ile geliştirilecek iOS/Android sulama kontrol uygulamasının **görsel tasarım
prototipi**. React + Tailwind CSS v4 ile yapıldı; amaç Flutter implementasyonu için
birebir referans oluşturmak.

**Hedef kitle yaşlı kullanıcıları da kapsıyor** — tüm arayüz kararları buna göre
alındı: büyük dokunma hedefleri, yüksek kontrast, etiketli navigasyon, sade akış.

## Çalıştırma

```bash
npm install
npm run dev
```

Tarayıcıda http://localhost:5173 adresini aç.

## Ekranlar

| Ekran | Dosya | Nasıl açılır |
| --- | --- | --- |
| Ana Sayfa | `src/screens/HomeScreen.jsx` | Navbar → Ana Sayfa |
| Program Sulama | `src/screens/ProgramScreen.jsx` | Ana Sayfa → "Program Sulama" |
| Anlık Sulama | `src/screens/InstantScreen.jsx` | Ana Sayfa → "Anlık Sulama" |
| Bakiyem | `src/screens/BalanceScreen.jsx` | Navbar → Bakiyem, ya da header'daki bakiye butonu |
| Bakiye Yükle | `src/screens/TopUpScreen.jsx` | Bakiyem → "Bakiye Yükle" |
| Profil | `src/screens/ProfileScreen.jsx` | Navbar → Profil |

Ekran geçişi `src/App.jsx` içindeki `screen` state'i ile yapılır (router yok —
prototip amaçlı bilinçli tercih). Alt sayfalar `tabOfScreen` eşlemesi üzerinden
doğru navbar sekmesini aktif gösterir.

## Erişilebilirlik kararları

- **Dokunma hedefleri:** navbar butonları 74px, ana eylem butonları 76–96px,
  kart içi "Başlat" 64px — hepsi 44px'lik iOS/Android minimumunun belirgin üzerinde.
- **Tipografi:** gövde 15–17px, başlıklar 20–26px, bakiye tutarı 52px.
- **Navigasyon:** ikonlar tek başına bırakılmadı; her sekmede metin etiketi var.
- **Durum bilgisi renge bağlı değil:** kuyu etiketleri ve site bağlantı durumu
  hem renk hem metin taşır ("Bağlı" / "Bağlı değil").
- **Klavye odağı:** `:focus-visible` ile tüm butonlarda 3px görünür outline.
- **Ana eylem butonları düz dolgu:** cam efekti yerine tam kontrastlı yeşil/mavi
  zemin kullanıldı — glassmorphism kartlarda ve header'da korunuyor, ancak birincil
  butonlarda okunabilirlik önceliklendirildi.

## Tasarım dili

- **Tema:** Modern light theme + katmanlı glassmorphism ("layered frost")
- **Arka plan:** Uçuk su yeşili / soluk mavi soft gradient (`.app-bg`)
- **Panel katmanları:** `.glass` (kartlar), `.glass-soft` (ikon kutuları),
  `.glass-nav` (alt navigasyon — en derin blur)
- **Tipografi:** Figtree (Google Fonts, `index.html` içinden yüklenir)
- **İkonlar:** `src/components/Icons.jsx` — tamamı inline SVG, line-art,
  `stroke-width: 1.8`, `currentColor`

### Renk paleti

`src/index.css` içinde `@theme` bloğunda tanımlı:

| Token | Değer | Anlamı |
| --- | --- | --- |
| `brand-600` | `#17735f` | Yeşil — birincil eylem, "aktif / normal" |
| `sea-600` | `#21648e` | Mavi — ikincil eylem, "bilgi / enerji" |
| `mist-600` | `#4f6763` | Gri — nötr, "pasif / kapalı" |
| `ink` | `#08302a` | Ana metin |
| `ink-soft` | `#35605a` | İkincil metin |
| `ink-faint` | `#4a6f69` | Etiket metni |

Kuyu etiketlerinin (`Pompa`, `Termik`, `Enerji`, `Haberleşme`) rengi durumu
gösterir: yeşil = çalışıyor, mavi = bağlı/bilgi, gri = pasif. Eşleme
`src/data.js` içindeki `tone` alanından gelir.

## Dosya yapısı

```
src/
  App.jsx                  ekran state'i, bakiye state'i, kabuk
  data.js                  kuyular, sulama kayıtları, hesap ekstresi
  index.css                tema token'ları, glass katmanları, arka plan
  components/
    PhoneFrame.jsx         cihaz çerçevesi + iOS durum çubuğu
    AppHeader.jsx          logo + "600 TL · Yükle" butonu
    BottomNav.jsx          etiketli alt navigasyon (Ana Sayfa / Bakiyem / Profil)
    PageHeading.jsx        alt sayfalarda geri butonu + başlık
    WellList.jsx           arama + kuyu kartları (iki sulama ekranının ortak gövdesi)
    Icons.jsx              line-art SVG ikon seti
  screens/
    HomeScreen.jsx  ProgramScreen.jsx  InstantScreen.jsx
    BalanceScreen.jsx  TopUpScreen.jsx  ProfileScreen.jsx
```

`WellList` iki sulama ekranı tarafından paylaşılır. Tek fark `onStart` prop'udur:
verildiğinde her kartta "Başlat" butonu çıkar (Anlık Sulama), verilmediğinde
çıkmaz (Program Sulama). Böylece iki ekran tasarım olarak birebir aynı kalır.

## Etkileşimler

- **Hızlı seçim → input:** Bakiye Yükle ekranında `50/100/150/200 TL` butonlarından
  birine basınca `amount` state'i güncellenir ve "Tutar giriniz" alanı otomatik dolar.
  Manuel yazınca hızlı seçim vurgusu kalkar; input yalnızca rakam kabul eder.
- **Bakiye güncellemesi:** Yükleme onaylanınca `balance` state'i artar, Bakiyem
  ekranına dönülür ve onay bildirimi gösterilir. Header'daki tutar da güncellenir.
- **Kuyu arama:** `toLocaleLowerCase('tr-TR')` ile Türkçe karakter duyarlı filtre
  (ör. "ÇİVRİL" → "Çivril" eşleşir). Sonuç yoksa boş durum kartı gösterilir.
- **Başlat:** Anlık Sulama'da basılan kuyunun butonu "Sulama Başladı" durumuna geçer.

## Notlar

- Tüm veriler statiktir (`src/data.js`) — backend bağlantısı yok, tasarım odaklı prototip.
- `PhoneFrame` cihaz çerçevesini yalnızca `sm:` (≥640px) ve üzeri genişlikte
  gösterir; mobilde tam ekran render edilir.
