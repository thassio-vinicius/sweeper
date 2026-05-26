sealed class Failure {
  const Failure();
}

final class AuthFailure extends Failure {
  const AuthFailure([this.message]);

  final String? message;
}
