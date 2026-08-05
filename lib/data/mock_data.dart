// Prototip verisi — data.js'in birebir Dart karşılığı. Backend yok.

class WellBadge {
  final String label;
  final String tone; // 'green' | 'gray'
  const WellBadge(this.label, this.tone);
}

class Well {
  final String id;
  final String ad;
  final String il;
  final String ilce;
  final List<WellBadge> badges;
  const Well({
    required this.id,
    required this.ad,
    required this.il,
    required this.ilce,
    required this.badges,
  });
}

const wells = <Well>[
  Well(
    id: 'k1',
    ad: 'Ova Kuyu 1',
    il: 'Denizli',
    ilce: 'Pamukkale',
    badges: [
      WellBadge('Pompa', 'green'),
      WellBadge('Termik', 'green'),
      WellBadge('Enerji', 'green'),
      WellBadge('Haberleşme', 'green'),
    ],
  ),
  Well(
    id: 'k2',
    ad: 'Ova Kuyu 2',
    il: 'Denizli',
    ilce: 'Sarayköy',
    badges: [
      WellBadge('Pompa', 'gray'),
      WellBadge('Termik', 'green'),
      WellBadge('Enerji', 'green'),
      WellBadge('Haberleşme', 'green'),
    ],
  ),
  Well(
    id: 'k3',
    ad: 'Yayla Yaylası Ana Sulama Kuyusu ABCABCAB',
    il: 'Denizli',
    ilce: 'Çivril',
    badges: [
      WellBadge('Pompa', 'green'),
      WellBadge('Termik', 'gray'),
      WellBadge('Enerji', 'green'),
      WellBadge('Haberleşme', 'gray'),
    ],
  ),
  Well(
    id: 'k4',
    ad: 'Menderes Kuyu',
    il: 'Aydın',
    ilce: 'Söke',
    badges: [
      WellBadge('Pompa', 'green'),
      WellBadge('Termik', 'green'),
      WellBadge('Enerji', 'green'),
      WellBadge('Haberleşme', 'green'),
    ],
  ),
  Well(
    id: 'k5',
    ad: 'Bağ Kuyu',
    il: 'Denizli',
    ilce: 'Honaz',
    badges: [
      WellBadge('Pompa', 'gray'),
      WellBadge('Termik', 'gray'),
      WellBadge('Enerji', 'gray'),
      WellBadge('Haberleşme', 'gray'),
    ],
  ),
];

class PastIrrigation {
  final String id, kuyu, ilce, tarih, saat, sure, su;
  const PastIrrigation({
    required this.id,
    required this.kuyu,
    required this.ilce,
    required this.tarih,
    required this.saat,
    required this.sure,
    required this.su,
  });
}

const pastIrrigations = <PastIrrigation>[
  PastIrrigation(
    id: 'g1',
    kuyu: 'Ova Kuyu 1',
    ilce: 'Pamukkale',
    tarih: '2 Ağustos',
    saat: '06:30',
    sure: '45 dk',
    su: '1.250 L',
  ),
  PastIrrigation(
    id: 'g2',
    kuyu: 'Yayla Kuyu',
    ilce: 'Çivril',
    tarih: '1 Ağustos',
    saat: '05:00',
    sure: '60 dk',
    su: '1.680 L',
  ),
  PastIrrigation(
    id: 'g3',
    kuyu: 'Ova Kuyu 2',
    ilce: 'Sarayköy',
    tarih: '31 Temmuz',
    saat: '06:00',
    sure: '30 dk',
    su: '820 L',
  ),
];

class UpcomingIrrigation {
  final String id, kuyu, ilce, tarih, saat, sure;
  const UpcomingIrrigation({
    required this.id,
    required this.kuyu,
    required this.ilce,
    required this.tarih,
    required this.saat,
    required this.sure,
  });
}

const upcomingIrrigations = <UpcomingIrrigation>[
  UpcomingIrrigation(
    id: 'p1',
    kuyu: 'Ova Kuyu 1',
    ilce: 'Pamukkale',
    tarih: '4 Ağustos',
    saat: '05:00',
    sure: '60 dk',
  ),
  UpcomingIrrigation(
    id: 'p2',
    kuyu: 'Menderes Kuyu',
    ilce: 'Söke',
    tarih: '5 Ağustos',
    saat: '06:30',
    sure: '45 dk',
  ),
  UpcomingIrrigation(
    id: 'p3',
    kuyu: 'Yayla Kuyu',
    ilce: 'Çivril',
    tarih: '6 Ağustos',
    saat: '05:30',
    sure: '90 dk',
  ),
];

class StatementRow {
  final String id;
  final int year;
  final int month;
  final String tarih;
  final String aciklama;
  final int? yukleme;
  final int? harcama;
  const StatementRow({
    required this.id,
    required this.year,
    required this.month,
    required this.tarih,
    required this.aciklama,
    this.yukleme,
    this.harcama,
  });
}

const statement = <StatementRow>[
  StatementRow(
    id: 'e1',
    year: 2026,
    month: 8,
    tarih: '2 Ağu',
    aciklama: 'Bakiye yükleme',
    yukleme: 150,
  ),
  StatementRow(
    id: 'e2',
    year: 2026,
    month: 8,
    tarih: '1 Ağu',
    aciklama: 'Sulama · Yayla',
    harcama: 85,
  ),
  StatementRow(
    id: 'e3',
    year: 2026,
    month: 7,
    tarih: '31 Tem',
    aciklama: 'Sulama · Ova 2',
    harcama: 60,
  ),
  StatementRow(
    id: 'e4',
    year: 2026,
    month: 7,
    tarih: '29 Tem',
    aciklama: 'Sulama · Ova 1',
    harcama: 120,
  ),
  StatementRow(
    id: 'e5',
    year: 2026,
    month: 7,
    tarih: '27 Tem',
    aciklama: 'Bakiye yükleme',
    yukleme: 200,
  ),
  StatementRow(
    id: 'e6',
    year: 2026,
    month: 7,
    tarih: '24 Tem',
    aciklama: 'Sulama · Ova 1',
    harcama: 65,
  ),
  StatementRow(
    id: 'e7',
    year: 2026,
    month: 6,
    tarih: '28 Haz',
    aciklama: 'Bakiye yükleme',
    yukleme: 300,
  ),
  StatementRow(
    id: 'e8',
    year: 2026,
    month: 6,
    tarih: '20 Haz',
    aciklama: 'Sulama · Yayla',
    harcama: 95,
  ),
  StatementRow(
    id: 'e9',
    year: 2026,
    month: 5,
    tarih: '15 May',
    aciklama: 'Sulama · Ova 1',
    harcama: 70,
  ),
  StatementRow(
    id: 'e10',
    year: 2026,
    month: 5,
    tarih: '3 May',
    aciklama: 'Bakiye yükleme',
    yukleme: 500,
  ),
  StatementRow(
    id: 'e11',
    year: 2026,
    month: 4,
    tarih: '22 Nis',
    aciklama: 'Sulama · Menderes',
    harcama: 110,
  ),
  StatementRow(
    id: 'e12',
    year: 2026,
    month: 4,
    tarih: '8 Nis',
    aciklama: 'Bakiye yükleme',
    yukleme: 250,
  ),
  StatementRow(
    id: 'e13',
    year: 2026,
    month: 3,
    tarih: '25 Mar',
    aciklama: 'Sulama · Bağ',
    harcama: 45,
  ),
  StatementRow(
    id: 'e14',
    year: 2026,
    month: 3,
    tarih: '18 Mar',
    aciklama: 'Sulama · Ova 2',
    harcama: 80,
  ),
  StatementRow(
    id: 'e15',
    year: 2026,
    month: 3,
    tarih: '10 Mar',
    aciklama: 'Bakiye yükleme',
    yukleme: 400,
  ),
  StatementRow(
    id: 'e16',
    year: 2026,
    month: 3,
    tarih: '2 Mar',
    aciklama: 'Sulama · Ova 1',
    harcama: 130,
  ),
  StatementRow(
    id: 'e17',
    year: 2026,
    month: 2,
    tarih: '14 Şub',
    aciklama: 'Bakiye yükleme',
    yukleme: 200,
  ),
  StatementRow(
    id: 'e18',
    year: 2026,
    month: 1,
    tarih: '5 Oca',
    aciklama: 'Sulama · Yayla',
    harcama: 55,
  ),
];

const quickAmounts = <int>[50, 100, 150, 200, 300, 500];

const monthLabels = <int, String>{
  1: 'Ocak',
  2: 'Şubat',
  3: 'Mart',
  4: 'Nisan',
  5: 'Mayıs',
  6: 'Haziran',
  7: 'Temmuz',
  8: 'Ağustos',
  9: 'Eylül',
  10: 'Ekim',
  11: 'Kasım',
  12: 'Aralık',
};

/// data.js `formatTL` — tr-TR biçimi (binlik ayraç nokta).
String formatTL(num n) {
  final isNegative = n < 0;
  final intPart = n.abs().truncate().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < intPart.length; i++) {
    if (i > 0 && (intPart.length - i) % 3 == 0) buffer.write('.');
    buffer.write(intPart[i]);
  }
  return '${isNegative ? '-' : ''}$buffer';
}
