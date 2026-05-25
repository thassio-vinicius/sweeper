import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'Reversed Minesweeper'**
  String get appTitle;

  /// No description provided for @reversed.
  ///
  /// In en, this message translates to:
  /// **'REVERSED'**
  String get reversed;

  /// No description provided for @minesweeper.
  ///
  /// In en, this message translates to:
  /// **'Minesweeper'**
  String get minesweeper;

  /// No description provided for @discovered.
  ///
  /// In en, this message translates to:
  /// **'DISCOVERED'**
  String get discovered;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'REMAINING'**
  String get remaining;

  /// No description provided for @btcLive.
  ///
  /// In en, this message translates to:
  /// **'BTC LIVE'**
  String get btcLive;

  /// No description provided for @nextBlast.
  ///
  /// In en, this message translates to:
  /// **'NEXT BLAST'**
  String get nextBlast;

  /// No description provided for @pieces.
  ///
  /// In en, this message translates to:
  /// **'PIECES'**
  String get pieces;

  /// No description provided for @dragToBoard.
  ///
  /// In en, this message translates to:
  /// **'Drag to board'**
  String get dragToBoard;

  /// No description provided for @footerHint.
  ///
  /// In en, this message translates to:
  /// **'Drag pieces to rearrange the board · bombs auto-detonate every 10s'**
  String get footerHint;

  /// No description provided for @gameOverTitle.
  ///
  /// In en, this message translates to:
  /// **'Game Over'**
  String get gameOverTitle;

  /// No description provided for @discoveredBombs.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No bombs discovered} =1{1 bomb discovered} other{{count} bombs discovered}}'**
  String discoveredBombs(int count);

  /// No description provided for @playAgain.
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get playAgain;

  /// No description provided for @connectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection lost. Tap to retry.'**
  String get connectionError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @boardSize.
  ///
  /// In en, this message translates to:
  /// **'Board Size'**
  String get boardSize;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @playAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Play as guest'**
  String get playAsGuest;

  /// No description provided for @guestModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Guest mode'**
  String get guestModeTitle;

  /// No description provided for @guestModeHint.
  ///
  /// In en, this message translates to:
  /// **'Playing without signing in.'**
  String get guestModeHint;

  /// No description provided for @endGuestSession.
  ///
  /// In en, this message translates to:
  /// **'End guest session'**
  String get endGuestSession;

  /// No description provided for @loginFeatureBtc.
  ///
  /// In en, this message translates to:
  /// **'Live BTC price feeds the board in real time'**
  String get loginFeatureBtc;

  /// No description provided for @loginFeatureMagic.
  ///
  /// In en, this message translates to:
  /// **'Magic bombs trigger when BTC lands on \$0 or \$5'**
  String get loginFeatureMagic;

  /// No description provided for @loginFeatureBlast.
  ///
  /// In en, this message translates to:
  /// **'Hidden bombs auto-detonate every 10 seconds'**
  String get loginFeatureBlast;

  /// No description provided for @authUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Sign-in is unavailable. Check your Firebase configuration.'**
  String get authUnavailable;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @magicBombBanner.
  ///
  /// In en, this message translates to:
  /// **'BTC {price} — MAGIC BOMB!'**
  String magicBombBanner(String price);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
