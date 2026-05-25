// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Buscaminas Inverso';

  @override
  String get reversed => 'INVERSO';

  @override
  String get minesweeper => 'Buscaminas';

  @override
  String get discovered => 'DESCUBIERTAS';

  @override
  String get remaining => 'RESTANTES';

  @override
  String get btcLive => 'BTC EN VIVO';

  @override
  String get nextBlast => 'PRÓXIMA EXPLOSIÓN';

  @override
  String get pieces => 'PIEZAS';

  @override
  String get dragToBoard => 'Arrastra al tablero';

  @override
  String get footerHint =>
      'Arrastra las piezas para reorganizar el tablero · las bombas detonan cada 10s';

  @override
  String get gameOverTitle => 'Fin del Juego';

  @override
  String discoveredBombs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bombas descubiertas',
      one: '1 bomba descubierta',
      zero: 'Ninguna bomba descubierta',
    );
    return '$_temp0';
  }

  @override
  String get playAgain => 'Jugar de Nuevo';

  @override
  String get connectionError => 'Conexión perdida. Toca para reintentar.';

  @override
  String get retry => 'Reintentar';

  @override
  String get boardSize => 'Tamaño del Tablero';

  @override
  String get signInWithGoogle => 'Iniciar sesión con Google';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get account => 'Cuenta';

  @override
  String get playAsGuest => 'Jugar como invitado';

  @override
  String get guestModeTitle => 'Modo invitado';

  @override
  String get guestModeHint => 'Jugando sin iniciar sesión.';

  @override
  String get endGuestSession => 'Terminar sesión de invitado';

  @override
  String get loginFeatureBtc =>
      'El precio de BTC en vivo alimenta el tablero en tiempo real';

  @override
  String get loginFeatureMagic =>
      'Las bombas mágicas se activan cuando BTC termina en \$0 o \$5';

  @override
  String get loginFeatureBlast =>
      'Las bombas ocultas detonan automáticamente cada 10 segundos';

  @override
  String get authUnavailable =>
      'Inicio de sesión no disponible. Revisa la configuración de Firebase.';

  @override
  String get settings => 'Configuración';

  @override
  String get pause => 'Pausar';

  @override
  String get resume => 'Reanudar';

  @override
  String get paused => 'Pausado';

  @override
  String magicBombBanner(String price) {
    return 'BTC $price — ¡BOMBA MÁGICA!';
  }
}
