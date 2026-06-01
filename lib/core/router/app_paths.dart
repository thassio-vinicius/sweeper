import 'package:sweeper_game/navigation/game_navigation.dart';

/// Route path constants for the app shell router.
abstract final class AppPaths {
  static const login = GameNavigation.login;
  static const home = GameNavigation.home;
  static const gameOver = GameNavigation.gameOver;

  static bool isLogin(String location) => location == login;
}
