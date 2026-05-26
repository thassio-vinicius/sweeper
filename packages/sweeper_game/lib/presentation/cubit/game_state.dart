import 'package:equatable/equatable.dart';
import 'package:sweeper_game/domain/entities/game_entities.dart';
import 'package:sweeper_game/presentation/cubit/pause_reason.dart';

enum GameStatus {
  initial,
  playing,
  paused,
  animating,
  gameOver,
  error,
}

class GameState extends Equatable {
  const GameState({
    this.status = GameStatus.initial,
    this.pauseReason = PauseReason.none,
    this.snapshot,
    this.btcPrice,
    this.btcPriceDirection = 0,
    this.explosionAt,
    this.magicBombAt,
    this.magicBombGeneration = 0,
    this.magicBombBannerWholeDollars,
    this.magicBombBannerGeneration = 0,
    this.remainingPulseGeneration = 0,
    this.errorMessage,
    this.snapBackCell,
    this.snapBackGeneration = 0,
  });

  final GameStatus status;
  final PauseReason pauseReason;
  final GameSnapshot? snapshot;
  final BtcPrice? btcPrice;
  final int btcPriceDirection;
  final ({int row, int col})? explosionAt;
  final ({int row, int col})? magicBombAt;
  final int magicBombGeneration;
  final int? magicBombBannerWholeDollars;
  final int magicBombBannerGeneration;
  final int remainingPulseGeneration;
  final String? errorMessage;
  final ({int row, int col})? snapBackCell;
  final int snapBackGeneration;

  bool get isInteractive => status == GameStatus.playing;

  bool get showPauseOverlay =>
      status == GameStatus.paused && pauseReason == PauseReason.manual;

  int get discoveredCount => snapshot?.discoveredBombCount ?? 0;
  int get remainingCount => snapshot?.remainingHiddenBombs ?? 0;
  int get secondsUntilBlast => snapshot?.secondsUntilNextBlast ?? 10;

  GameState copyWith({
    GameStatus? status,
    PauseReason? pauseReason,
    GameSnapshot? snapshot,
    BtcPrice? btcPrice,
    int? btcPriceDirection,
    ({int row, int col})? explosionAt,
    ({int row, int col})? magicBombAt,
    int? magicBombGeneration,
    int? magicBombBannerWholeDollars,
    int? magicBombBannerGeneration,
    int? remainingPulseGeneration,
    String? errorMessage,
    ({int row, int col})? snapBackCell,
    int? snapBackGeneration,
    bool clearExplosion = false,
    bool clearMagicBomb = false,
    bool clearMagicBombBanner = false,
    bool clearError = false,
    bool clearSnapBack = false,
  }) {
    return GameState(
      status: status ?? this.status,
      pauseReason: pauseReason ?? this.pauseReason,
      snapshot: snapshot ?? this.snapshot,
      btcPrice: btcPrice ?? this.btcPrice,
      btcPriceDirection: btcPriceDirection ?? this.btcPriceDirection,
      explosionAt: clearExplosion ? null : (explosionAt ?? this.explosionAt),
      magicBombAt: clearMagicBomb ? null : (magicBombAt ?? this.magicBombAt),
      magicBombGeneration: magicBombGeneration ?? this.magicBombGeneration,
      magicBombBannerWholeDollars: clearMagicBombBanner
          ? null
          : (magicBombBannerWholeDollars ?? this.magicBombBannerWholeDollars),
      magicBombBannerGeneration:
          magicBombBannerGeneration ?? this.magicBombBannerGeneration,
      remainingPulseGeneration:
          remainingPulseGeneration ?? this.remainingPulseGeneration,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      snapBackCell: clearSnapBack ? null : (snapBackCell ?? this.snapBackCell),
      snapBackGeneration: snapBackGeneration ?? this.snapBackGeneration,
    );
  }

  @override
  List<Object?> get props => [
        status,
        pauseReason,
        snapshot,
        btcPrice,
        btcPriceDirection,
        explosionAt,
        magicBombAt,
        magicBombGeneration,
        magicBombBannerWholeDollars,
        magicBombBannerGeneration,
        remainingPulseGeneration,
        errorMessage,
        snapBackCell,
        snapBackGeneration,
      ];
}
