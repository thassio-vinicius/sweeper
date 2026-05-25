import 'package:sweeper/core/errors/failures.dart';

sealed class Result<T, F extends Failure> {
  const Result();
}

final class Success<T, F extends Failure> extends Result<T, F> {
  const Success(this.value);

  final T value;
}

final class Err<T, F extends Failure> extends Result<T, F> {
  const Err(this.failure);

  final F failure;
}

extension ResultX<T, F extends Failure> on Result<T, F> {
  bool get isSuccess => this is Success<T, F>;
  bool get isErr => this is Err<T, F>;

  T? get valueOrNull => switch (this) {
        Success(value: final v) => v,
        Err() => null,
      };

  F? get failureOrNull => switch (this) {
        Success() => null,
        Err(failure: final f) => f,
      };

  Result<R, F> map<R>(R Function(T value) transform) => switch (this) {
        Success(value: final v) => Success(transform(v)),
        Err(failure: final f) => Err(f),
      };
}
