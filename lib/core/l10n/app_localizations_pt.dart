// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Campo Minado Reverso';

  @override
  String get reversed => 'REVERSO';

  @override
  String get minesweeper => 'Campo Minado';

  @override
  String get discovered => 'DESCOBERTAS';

  @override
  String get remaining => 'RESTANTES';

  @override
  String get btcLive => 'BTC AO VIVO';

  @override
  String get nextBlast => 'PRÓXIMA EXPLOSÃO';

  @override
  String get pieces => 'PEÇAS';

  @override
  String get dragToBoard => 'Arraste para o tabuleiro';

  @override
  String get footerHint =>
      'Arraste as peças para reorganizar o tabuleiro · bombas detonam a cada 10s';

  @override
  String get gameOverTitle => 'Fim de Jogo';

  @override
  String discoveredBombs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bombas descobertas',
      one: '1 bomba descoberta',
      zero: 'Nenhuma bomba descoberta',
    );
    return '$_temp0';
  }

  @override
  String get playAgain => 'Jogar Novamente';

  @override
  String get connectionError => 'Conexão perdida. Toque para tentar novamente.';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get boardSize => 'Tamanho do Tabuleiro';

  @override
  String get signInWithGoogle => 'Entrar com Google';

  @override
  String get signOut => 'Sair';

  @override
  String get settings => 'Configurações';

  @override
  String get pause => 'Pausar';

  @override
  String get resume => 'Continuar';

  @override
  String get paused => 'Pausado';
}
