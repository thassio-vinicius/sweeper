import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sweeper/core/auth/auth_session.dart';
import 'package:sweeper/core/router/auth_refresh_notifier.dart';
import 'package:sweeper/features/auth/presentation/pages/login_page.dart';
import 'package:sweeper/features/game/presentation/pages/game_over_page.dart';
import 'package:sweeper/features/game/presentation/pages/game_page.dart';

class AppRouter {
  AppRouter({
    required AuthSession authSession,
    required AuthRefreshNotifier refreshNotifier,
  })  : _authSession = authSession,
        _refreshNotifier = refreshNotifier;

  final AuthSession _authSession;
  final AuthRefreshNotifier _refreshNotifier;

  late final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: _refreshNotifier,
    redirect: _redirect,
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const GamePage(),
      ),
      GoRoute(
        path: '/game-over',
        builder: (context, state) {
          final count = state.extra as int? ?? 0;
          return GameOverPage(discoveredCount: count);
        },
      ),
    ],
  );

  String? _redirect(BuildContext context, GoRouterState state) {
    if (!_authSession.isAvailable) {
      return state.matchedLocation == '/login' ? '/' : null;
    }

    final canPlay = _authSession.canPlayGame;
    final isLoggingIn = state.matchedLocation == '/login';

    if (!canPlay && !isLoggingIn) {
      return '/login';
    }

    if (canPlay && isLoggingIn) {
      return '/';
    }

    return null;
  }
}
