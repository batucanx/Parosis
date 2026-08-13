const List<String> turkishMonthNames = [
  'Ocak',
  'Şubat',
  'Mart',
  'Nisan',
  'Mayıs',
  'Haziran',
  'Temmuz',
  'Ağustos',
  'Eylül',
  'Ekim',
  'Kasım',
  'Aralık',
];

const List<String> _turkishShortMonthNames = [
  'Oca',
  'Şub',
  'Mar',
  'Nis',
  'May',
  'Haz',
  'Tem',
  'Ağu',
  'Eyl',
  'Eki',
  'Kas',
  'Ara',
];

String formatTurkishDate(DateTime date) =>
    '${date.day} ${turkishMonthNames[date.month - 1]}';

String formatTurkishShortDate(DateTime date) =>
    '${date.day} ${_turkishShortMonthNames[date.month - 1]}';

String formatClock(DateTime date) =>
    '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
