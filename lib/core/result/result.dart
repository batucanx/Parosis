/// Utility class that simplifies handling errors.
///
/// Return a [Result] from a function to indicate success or failure.
/// A result is either an [Ok] with a value of type [T] or an [Error] with an
/// [Exception].
sealed class Result<T> {
  const Result();

  /// Creates a successful [Result], completed with [value].
  const factory Result.ok(T value) = Ok._;

  /// Creates an unsuccessful [Result], completed with [error].
  const factory Result.error(Exception error) = Error._;
}

/// A successful [Result] with a returned [value].
final class Ok<T> extends Result<T> {
  const Ok._(this.value);

  /// The returned value of this result.
  final T value;

  @override
  String toString() => 'Result<$T>.ok($value)';
}

/// An unsuccessful [Result] with a resulting [error].
final class Error<T> extends Result<T> {
  const Error._(this.error);

  /// The resulting error of this result.
  final Exception error;

  @override
  String toString() => 'Result<$T>.error($error)';
}
