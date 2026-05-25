// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Reversed Minesweeper';

  @override
  String get reversed => 'REVERSED';

  @override
  String get minesweeper => 'Minesweeper';

  @override
  String get discovered => 'DISCOVERED';

  @override
  String get remaining => 'REMAINING';

  @override
  String get btcLive => 'BTC LIVE';

  @override
  String get nextBlast => 'NEXT BLAST';

  @override
  String get pieces => 'PIECES';

  @override
  String get dragToBoard => 'Drag to board';

  @override
  String get footerHint =>
      'Drag pieces to rearrange the board · bombs auto-detonate every 10s';

  @override
  String get gameOverTitle => 'Game Over';

  @override
  String discoveredBombs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bombs discovered',
      one: '1 bomb discovered',
      zero: 'No bombs discovered',
    );
    return '$_temp0';
  }

  @override
  String get playAgain => 'Play Again';

  @override
  String get connectionError => 'Connection lost. Tap to retry.';

  @override
  String get retry => 'Retry';

  @override
  String get boardSize => 'Board Size';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get signOut => 'Sign Out';

  @override
  String get account => 'Account';

  @override
  String get playAsGuest => 'Play as guest';

  @override
  String get guestModeTitle => 'Guest mode';

  @override
  String get guestModeHint => 'Playing without signing in.';

  @override
  String get endGuestSession => 'End guest session';

  @override
  String get loginFeatureBtc => 'Live BTC price feeds the board in real time';

  @override
  String get loginFeatureMagic =>
      'Magic bombs trigger when BTC lands on \$0 or \$5';

  @override
  String get loginFeatureBlast => 'Hidden bombs auto-detonate every 10 seconds';

  @override
  String get authUnavailable =>
      'Sign-in is unavailable. Check your Firebase configuration.';

  @override
  String get settings => 'Settings';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String get paused => 'Paused';

  @override
  String magicBombBanner(String price) {
    return 'BTC $price — MAGIC BOMB!';
  }
}
