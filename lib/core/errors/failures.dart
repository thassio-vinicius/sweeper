sealed class Failure {
  const Failure();
}

final class NetworkFailure extends Failure {
  const NetworkFailure([this.message]);

  final String? message;
}

final class GameRuleFailure extends Failure {
  const GameRuleFailure([this.message]);

  final String? message;
}

final class AuthFailure extends Failure {
  const AuthFailure([this.message]);

  final String? message;
}
