import 'package:freezed_annotation/freezed_annotation.dart';

part 'structures.freezed.dart';

class Failure {
  /// Portuguese description to a failure
  final String description;
  const Failure(this.description);
}

/// Data class that stores either a value (sucess) or a failure.
/// It should be used every time a function can return a failure.
/// When you use this class it becomes mandatory for the user to deal with the
/// failures.
@freezed
class Either<S, F extends Failure> with _$Either<S, F> {
  // ignore: unused_element
  const Either._();

  const factory Either.success(S success) = _Success;
  const factory Either.failure(F failure) = _Failure;

  S? get successOrNull => when(
        success: (s) => s,
        failure: (f) => null,
      );

  F? get failureOrNull => when(
        success: (s) => null,
        failure: (f) => f,
      );
}
