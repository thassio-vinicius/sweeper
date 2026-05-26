import 'package:go_router/go_router.dart';
import 'package:sweeper/core/router/auth_redirect.dart';
import 'package:sweeper/core/router/auth_refresh_notifier.dart';
import 'package:sweeper_auth/presentation/pages/login_page.dart';
import 'package:sweeper_auth/session/auth_session.dart';
import 'app_paths.dart';
import 'package:sweeper_game/presentation/pages/game_over_page.dart';
import 'package:sweeper_game/presentation/pages/game_page.dart';

class AppRouter {
  AppRouter({
    required AuthSession authSession,
    required AuthRefreshNotifier refreshNotifier,
  })  : _redirect = AuthRedirect(authSession),
        _refreshNotifier = refreshNotifier;

  final AuthRedirect _redirect;
  final AuthRefreshNotifier _refreshNotifier;

  late final GoRouter router = GoRouter(
    initialLocation: AppPaths.home,
    refreshListenable: _refreshNotifier,
    redirect: (context, state) => _redirect.resolve(state.matchedLocation),
    routes: [
      GoRoute(
        path: AppPaths.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppPaths.home,
        builder: (context, state) => const GamePage(),
      ),
      GoRoute(
        path: AppPaths.gameOver,
        builder: (context, state) {
          final count = state.extra as int? ?? 0;
          return GameOverPage(discoveredCount: count);
        },
      ),
    ],
  );
}
