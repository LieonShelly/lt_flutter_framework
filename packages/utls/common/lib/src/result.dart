sealed class Result<T> {
  const Result();
}

final class Ok<T> extends Result<T> {
  const Ok._(this.value);

  final T value;

  @override
  String toString() {
    return 'Result<$T>.ok($value)';
  }
}

final class Error<T> extends Result<T> {
  const Error._(this.error);
  final Exception error;

  @override
  String toString() => 'Result<$T>.error($error)';
}
