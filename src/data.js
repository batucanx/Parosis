/** Prototip verisi — backend yok, tüm ekranlar buradan besleniyor. */

/**
 * Kuyu etiketleri.
 * tone: 'green' = çalışıyor/normal, 'blue' = bilgi/bağlı, 'gray' = pasif/kapalı
 */
export const wells = [
  {
    id: 'k1',
    ad: 'Ova Kuyu 1',
    il: 'Denizli',
    ilce: 'Pamukkale',
    badges: [
      { label: 'Pompa',       tone: 'green' },
      { label: 'Termik',      tone: 'green' },
      { label: 'Enerji',      tone: 'green' },
      { label: 'Haberleşme',  tone: 'green' },
    ],
  },
  {
    id: 'k2',
    ad: 'Ova Kuyu 2',
    il: 'Denizli',
    ilce: 'Sarayköy',
    badges: [
      { label: 'Pompa',       tone: 'gray' },
      { label: 'Termik',      tone: 'green' },
      { label: 'Enerji',      tone: 'green' },
      { label: 'Haberleşme',  tone: 'green' },
    ],
  },
  {
    id: 'k3',
    ad: 'Yayla Yaylası Ana Sulama Kuyusu ABCABCAB',
    il: 'Denizli',
    ilce: 'Çivril',
    badges: [
      { label: 'Pompa',       tone: 'green' },
      { label: 'Termik',      tone: 'gray' },
      { label: 'Enerji',      tone: 'green' },
      { label: 'Haberleşme',  tone: 'gray' },
    ],
  },
  {
    id: 'k4',
    ad: 'Menderes Kuyu',
    il: 'Aydın',
    ilce: 'Söke',
    badges: [
      { label: 'Pompa',       tone: 'green' },
      { label: 'Termik',      tone: 'green' },
      { label: 'Enerji',      tone: 'green' },
      { label: 'Haberleşme',  tone: 'green' },
    ],
  },
  {
    id: 'k5',
    ad: 'Bağ Kuyu',
    il: 'Denizli',
    ilce: 'Honaz',
    badges: [
      { label: 'Pompa',       tone: 'gray' },
      { label: 'Termik',      tone: 'gray' },
      { label: 'Enerji',      tone: 'gray' },
      { label: 'Haberleşme',  tone: 'gray' },
    ],
  },
]

export const pastIrrigations = [
  { id: 'g1', kuyu: 'Ova Kuyu 1', ilce: 'Pamukkale', tarih: '2 Ağustos', saat: '06:30', sure: '45 dk', su: '1.250 L' },
  { id: 'g2', kuyu: 'Yayla Kuyu', ilce: 'Çivril', tarih: '1 Ağustos', saat: '05:00', sure: '60 dk', su: '1.680 L' },
  { id: 'g3', kuyu: 'Ova Kuyu 2', ilce: 'Sarayköy', tarih: '31 Temmuz', saat: '06:00', sure: '30 dk', su: '820 L' },
]

export const upcomingIrrigations = [
  { id: 'p1', kuyu: 'Ova Kuyu 1', ilce: 'Pamukkale', tarih: '4 Ağustos', saat: '05:00', sure: '60 dk' },
  { id: 'p2', kuyu: 'Menderes Kuyu', ilce: 'Söke', tarih: '5 Ağustos', saat: '06:30', sure: '45 dk' },
  { id: 'p3', kuyu: 'Yayla Kuyu', ilce: 'Çivril', tarih: '6 Ağustos', saat: '05:30', sure: '90 dk' },
]

/**
 * Hesap ekstresi — year + month bazlı filtreleme için tam tarih eklenmiştir.
 * year: sayı, month: 1-12
 */
export const statement = [
  { id: 'e1',  year: 2026, month: 8,  tarih: '2 Ağu',  aciklama: 'Bakiye yükleme',    yukleme: 150,  harcama: null },
  { id: 'e2',  year: 2026, month: 8,  tarih: '1 Ağu',  aciklama: 'Sulama · Yayla',    yukleme: null, harcama: 85  },
  { id: 'e3',  year: 2026, month: 7,  tarih: '31 Tem', aciklama: 'Sulama · Ova 2',    yukleme: null, harcama: 60  },
  { id: 'e4',  year: 2026, month: 7,  tarih: '29 Tem', aciklama: 'Sulama · Ova 1',    yukleme: null, harcama: 120 },
  { id: 'e5',  year: 2026, month: 7,  tarih: '27 Tem', aciklama: 'Bakiye yükleme',    yukleme: 200,  harcama: null },
  { id: 'e6',  year: 2026, month: 7,  tarih: '24 Tem', aciklama: 'Sulama · Ova 1',    yukleme: null, harcama: 65  },
  { id: 'e7',  year: 2026, month: 6,  tarih: '28 Haz', aciklama: 'Bakiye yükleme',    yukleme: 300,  harcama: null },
  { id: 'e8',  year: 2026, month: 6,  tarih: '20 Haz', aciklama: 'Sulama · Yayla',    yukleme: null, harcama: 95  },
  { id: 'e9',  year: 2026, month: 5,  tarih: '15 May', aciklama: 'Sulama · Ova 1',    yukleme: null, harcama: 70  },
  { id: 'e10', year: 2026, month: 5,  tarih: '3 May',  aciklama: 'Bakiye yükleme',    yukleme: 500,  harcama: null },
  { id: 'e11', year: 2026, month: 4,  tarih: '22 Nis', aciklama: 'Sulama · Menderes', yukleme: null, harcama: 110 },
  { id: 'e12', year: 2026, month: 4,  tarih: '8 Nis',  aciklama: 'Bakiye yükleme',    yukleme: 250,  harcama: null },
  { id: 'e13', year: 2026, month: 3,  tarih: '25 Mar', aciklama: 'Sulama · Bağ',      yukleme: null, harcama: 45  },
  { id: 'e14', year: 2026, month: 3,  tarih: '18 Mar', aciklama: 'Sulama · Ova 2',    yukleme: null, harcama: 80  },
  { id: 'e15', year: 2026, month: 3,  tarih: '10 Mar', aciklama: 'Bakiye yükleme',    yukleme: 400,  harcama: null },
  { id: 'e16', year: 2026, month: 3,  tarih: '2 Mar',  aciklama: 'Sulama · Ova 1',    yukleme: null, harcama: 130 },
  { id: 'e17', year: 2026, month: 2,  tarih: '14 Şub', aciklama: 'Bakiye yükleme',    yukleme: 200,  harcama: null },
  { id: 'e18', year: 2026, month: 1,  tarih: '5 Oca',  aciklama: 'Sulama · Yayla',    yukleme: null, harcama: 55  },
]

export const quickAmounts = [50, 100, 150, 200, 300, 500]

export const formatTL = (n) => n.toLocaleString('tr-TR')
