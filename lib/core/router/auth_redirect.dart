import 'app_paths.dart';
import 'package:sweeper_auth/session/auth_session.dart';

/// Resolves auth-aware navigation redirects for [GoRouter].
final class AuthRedirect {
  const AuthRedirect(this._authSession);

  final AuthSession _authSession;

  String? resolve(String matchedLocation) {
    final canPlay = _authSession.canPlayGame;
    final onLogin = AppPaths.isLogin(matchedLocation);

    if (!canPlay && !onLogin) return AppPaths.login;
    if (canPlay && onLogin) return AppPaths.home;
    return null;
  }
}
