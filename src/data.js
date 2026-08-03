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
    ad: 'Yayla Kuyu',
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

/** Hesap ekstresi — yukleme / harcama alanlarından yalnızca biri dolu olur. */
export const statement = [
  { id: 'e1', tarih: '2 Ağu', aciklama: 'Bakiye yükleme', yukleme: 150, harcama: null },
  { id: 'e2', tarih: '1 Ağu', aciklama: 'Sulama · Yayla', yukleme: null, harcama: 85 },
  { id: 'e3', tarih: '31 Tem', aciklama: 'Sulama · Ova 2', yukleme: null, harcama: 60 },
  { id: 'e4', tarih: '29 Tem', aciklama: 'Sulama · Ova 1', yukleme: null, harcama: 120 },
  { id: 'e5', tarih: '27 Tem', aciklama: 'Bakiye yükleme', yukleme: 200, harcama: null },
  { id: 'e6', tarih: '24 Tem', aciklama: 'Sulama · Ova 1', yukleme: null, harcama: 65 },
]

export const quickAmounts = [50, 100, 150, 200, 300, 500]

export const formatTL = (n) => n.toLocaleString('tr-TR')
