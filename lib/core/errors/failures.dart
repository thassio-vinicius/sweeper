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

final class UnauthenticatedFailure extends Failure {
  const UnauthenticatedFailure([this.message = 'User is not authenticated']);

  final String message;
}

final class HttpRequestFailure extends Failure {
  const HttpRequestFailure(this.message, {this.statusCode});

  final String message;
  final int? statusCode;
}
