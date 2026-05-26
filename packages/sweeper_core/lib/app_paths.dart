/// Shared route path constants for the app shell and feature packages.
abstract final class AppPaths {
  static const login = '/login';
  static const home = '/';
  static const gameOver = '/game-over';

  static bool isLogin(String location) => location == login;
}
