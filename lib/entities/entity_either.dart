/// An abstract class representing an either type, where the value can be either
/// of type [L] or [R].
abstract class Either<L, R> {
  /// Returns the result of applying either [left] or [right] function depending
  /// on whether the value is of type [Left] or [Right].
  ///
  /// If the value is of type [Left], the [left] function is applied to the
  /// [value] of type [L]. Otherwise, the [right] function is applied to the
  /// [value] of type [R].
  ///
  /// Example usage:
  ///
  /// ```
  /// final value = Right<int, String>('hello');
  /// final result = value.when(
  ///   (leftValue) => leftValue * 2, // not executed
  ///   (rightValue) => rightValue.toUpperCase(), // executed and returns 'HELLO'
  /// );
  /// ```
  T when<T>(
    T Function(L) left,
    T Function(R) right,
  ) {
    if (this is Left<L, R>) {
      return left((this as Left<L, R>).value);
    }
    return right((this as Right<L, R>).value);
  }
}

/// A class representing the left value of the [Either] type.
class Left<L, R> extends Either<L, R> {
  /// Creates a new [Left] object with the given [value] of type [L].
  Left(this.value);

  /// The value of type [L] stored in the [Left] object.
  final L value;
}

/// A class representing the right value of the [Either] type.
class Right<L, R> extends Either<L, R> {
  /// Creates a new [Right] object with the given [value] of type [R].
  Right(this.value);

  /// The value of type [R] stored in the [Right] object.
  final R value;
}
