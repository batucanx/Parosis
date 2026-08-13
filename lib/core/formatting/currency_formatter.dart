String formatTL(num value) {
  final isNegative = value < 0;
  final integerPart = value.abs().truncate().toString();
  final buffer = StringBuffer();

  for (var index = 0; index < integerPart.length; index++) {
    if (index > 0 && (integerPart.length - index) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(integerPart[index]);
  }

  return '${isNegative ? '-' : ''}$buffer';
}
