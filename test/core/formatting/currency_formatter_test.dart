import 'package:flutter_test/flutter_test.dart';
import 'package:parosis_sulama/core/formatting/currency_formatter.dart';

void main() {
  test('formatTL Türkçe binlik ayraç davranışını korur', () {
    expect(formatTL(0), '0');
    expect(formatTL(450), '450');
    expect(formatTL(1234567), '1.234.567');
    expect(formatTL(-1250), '-1.250');
    expect(formatTL(99.9), '99');
  });
}
