import 'package:flutter_test/flutter_test.dart';
import 'package:parosis_sulama/core/result/result.dart';

void main() {
  group('Result', () {
    test('Ok success değerini taşır', () {
      const result = Result<int>.ok(42);

      expect(result, isA<Ok<int>>());
      expect(switch (result) {
        Ok<int>() => result.value,
        Error<int>() => fail('Ok sonucu bekleniyordu.'),
      }, 42);
      expect(result.toString(), 'Result<int>.ok(42)');
    });

    test('Error exception değerini taşır', () {
      const exception = FormatException('Geçersiz veri');
      const result = Result<int>.error(exception);

      expect(result, isA<Error<int>>());
      expect(switch (result) {
        Ok<int>() => fail('Error sonucu bekleniyordu.'),
        Error<int>() => result.error,
      }, same(exception));
      expect(
        result.toString(),
        'Result<int>.error(FormatException: Geçersiz veri)',
      );
    });
  });
}
