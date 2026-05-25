import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sweeper_core/clock.dart';
import 'package:sweeper_game/domain/entities/game_config.dart';
import 'package:sweeper_game/domain/entities/game_entities.dart';
import 'package:sweeper_game/domain/entities/game_events.dart';
import 'package:sweeper_game/domain/repositories/btc_price_repository.dart';
import 'package:sweeper_game/domain/services/game_engine.dart';
import 'package:sweeper_game/presentation/cubit/game_state.dart';

class GameCubit extends Cubit<GameState> {
  GameCubit({
    required BtcPriceRepository btcPriceRepository,
    required Clock clock,
    GameConfig? config,
  })  : _btcPriceRepository = btcPriceRepository,
        _clock = clock,
        _config = config ?? const GameConfig(),
        super(const GameState());

  final BtcPriceRepository _btcPriceRepository;
  final Clock _clock;
  GameConfig _config;
  GameEngine? _engine;

  StreamSubscription<BtcPrice>? _btcSubscription;
  StreamSubscription<int>? _countdownSubscription;
  Timer? _explosionClearTimer;
  Timer? _magicBombClearTimer;
  Timer? _magicBombBannerClearTimer;
  GameStatus? _statusBeforePause;

  Future<void> startGame({GameConfig? config}) async {
    await _disposeSubscriptions();
    _statusBeforePause = null;
    _config = config ?? _config;
    _engine = GameEngine(config: _config);
    final result = _engine!.initialize();

    emit(
      GameState(
        status: GameStatus.playing,
        snapshot: result.snapshot,
        btcPrice: state.btcPrice,
        btcPriceDirection: state.btcPriceDirection,
      ),
    );

    _startTimer();
    await _startBtcStream();
  }

  void restart({GameConfig? config}) {
    startGame(config: config);
  }

  void pause() {
    if (state.status == GameStatus.gameOver ||
        state.status == GameStatus.paused) {
      return;
    }
    _statusBeforePause = state.status;
    emit(state.copyWith(status: GameStatus.paused));
  }

  void resume() {
    if (state.status != GameStatus.paused) return;
    emit(
      state.copyWith(
        status: _statusBeforePause ?? GameStatus.playing,
      ),
    );
    _statusBeforePause = null;
  }

  void movePiece({
    required int fromRow,
    required int fromCol,
    required int toRow,
    required int toCol,
  }) {
    if (_engine == null ||
        state.status == GameStatus.gameOver ||
        state.status == GameStatus.paused) {
      return;
    }

    final result = _engine!.movePiece(
      fromRow: fromRow,
      fromCol: fromCol,
      toRow: toRow,
      toCol: toCol,
    );

    if (result.events.any((e) => e is InvalidMoveEvent)) {
      _triggerSnapBack(fromRow, fromCol);
      return;
    }

    _applyResult(result);
  }

  void onInvalidDrop({required int fromRow, required int fromCol}) {
    _triggerSnapBack(fromRow, fromCol);
  }

  void _triggerSnapBack(int row, int col) {
    emit(
      state.copyWith(
        snapBackCell: (row: row, col: col),
        snapBackGeneration: state.snapBackGeneration + 1,
      ),
    );
  }

  void _applyResult(
    GameEngineResult result, {
    BtcPrice? btcPrice,
    int? btcPriceDirection,
  }) {
    var newStatus = state.status == GameStatus.paused
        ? GameStatus.paused
        : state.status;
    ({int row, int col})? explosionAt;
    ({int row, int col})? magicBombAt;
    var magicBombGeneration = state.magicBombGeneration;
    var magicBombBannerGeneration = state.magicBombBannerGeneration;
    var remainingPulseGeneration = state.remainingPulseGeneration;
    int? magicBombBannerWholeDollars;
    var isGameOver = result.snapshot.phase == GamePhase.gameOver;

    for (final event in result.events) {
      switch (event) {
        case BombDiscoveredEvent(:final row, :final col):
          if (!isGameOver && state.status != GameStatus.paused) {
            explosionAt = (row: row, col: col);
            newStatus = GameStatus.animating;
            _scheduleExplosionClear();
          }
        case BombExplodedEvent():
          break;
        case GameOverEvent():
          isGameOver = true;
          newStatus = GameStatus.gameOver;
        case InvalidMoveEvent():
          break;
        case MagicBombAddedEvent(:final row, :final col, :final triggerWholeDollars):
          magicBombAt = (row: row, col: col);
          magicBombGeneration++;
          magicBombBannerWholeDollars = triggerWholeDollars;
          magicBombBannerGeneration++;
          remainingPulseGeneration++;
          _scheduleMagicBombClear();
          _scheduleMagicBombBannerClear();
      }
    }

    if (isGameOver) {
      newStatus = GameStatus.gameOver;
      _explosionClearTimer?.cancel();
      _magicBombClearTimer?.cancel();
      _magicBombBannerClearTimer?.cancel();
      explosionAt = null;
      magicBombAt = null;
      magicBombBannerWholeDollars = null;
      _stopGameLoop();
    }

    emit(
      state.copyWith(
        snapshot: result.snapshot,
        status: newStatus,
        btcPrice: btcPrice,
        btcPriceDirection: btcPriceDirection,
        explosionAt: explosionAt,
        magicBombAt: magicBombAt,
        magicBombGeneration: magicBombGeneration,
        magicBombBannerWholeDollars: magicBombBannerWholeDollars,
        magicBombBannerGeneration: magicBombBannerGeneration,
        remainingPulseGeneration: remainingPulseGeneration,
        clearSnapBack: true,
        clearExplosion: isGameOver,
        clearMagicBomb: isGameOver,
        clearMagicBombBanner: isGameOver,
      ),
    );
  }

  void _scheduleExplosionClear() {
    _explosionClearTimer?.cancel();
    _explosionClearTimer = Timer(const Duration(milliseconds: 800), () {
      if (isClosed) return;
      if (state.status == GameStatus.animating) {
        final isOver = state.snapshot?.phase == GamePhase.gameOver;
        emit(
          state.copyWith(
            status: isOver ? GameStatus.gameOver : GameStatus.playing,
            clearExplosion: true,
          ),
        );
        if (isOver) {
          _stopGameLoop();
        }
      }
    });
  }

  void _scheduleMagicBombClear() {
    _magicBombClearTimer?.cancel();
    _magicBombClearTimer = Timer(const Duration(milliseconds: 900), () {
      if (isClosed) return;
      emit(state.copyWith(clearMagicBomb: true));
    });
  }

  void _scheduleMagicBombBannerClear() {
    _magicBombBannerClearTimer?.cancel();
    _magicBombBannerClearTimer = Timer(const Duration(milliseconds: 2400), () {
      if (isClosed) return;
      emit(state.copyWith(clearMagicBombBanner: true));
    });
  }

  void _startTimer() {
    final interval = _config.tickInterval;
    var secondsLeft = interval.inSeconds;

    _countdownSubscription?.cancel();
    _countdownSubscription = _clock.periodic(const Duration(seconds: 1)).listen(
      (_) {
        if (isClosed ||
            state.status == GameStatus.gameOver ||
            state.status == GameStatus.paused) {
          return;
        }
        if (_engine?.snapshot.phase == GamePhase.gameOver) {
          _stopGameLoop();
          return;
        }

        secondsLeft--;
        if (secondsLeft <= 0) {
          secondsLeft = interval.inSeconds;
          if (_engine != null) {
            final result = _engine!.onTimerTick();
            _applyResult(result);
          }
        } else {
          _engine?.updateCountdown(secondsLeft);
          if (_engine != null && !isClosed) {
            emit(state.copyWith(snapshot: _engine!.snapshot));
          }
        }
      },
    );
  }

  void _stopGameLoop() {
    _explosionClearTimer?.cancel();
    _magicBombClearTimer?.cancel();
    _magicBombBannerClearTimer?.cancel();
    _countdownSubscription?.cancel();
    _countdownSubscription = null;
  }

  void _handleBtcPrice(BtcPrice price) {
    if (isClosed) return;

    final prevWhole = state.btcPrice?.wholeDollarPrice;
    final newWhole = price.wholeDollarPrice;
    var direction = state.btcPriceDirection;
    if (prevWhole != null) {
      if (newWhole > prevWhole) {
        direction = 1;
      } else if (newWhole < prevWhole) {
        direction = -1;
      }
    } else {
      direction = 1;
    }

    final canProcessEngine = _engine != null &&
        state.status != GameStatus.gameOver &&
        _engine!.snapshot.phase != GamePhase.gameOver;

    if (!canProcessEngine) {
      emit(
        state.copyWith(
          btcPrice: price,
          btcPriceDirection: direction,
          clearError: true,
        ),
      );
      return;
    }

    if (state.status == GameStatus.paused) {
      emit(
        state.copyWith(
          btcPrice: price,
          btcPriceDirection: direction,
          clearError: true,
        ),
      );
      return;
    }

    final result = _engine!.onBtcPriceUpdate(price);
    _applyResult(
      result,
      btcPrice: price,
      btcPriceDirection: direction,
    );
  }

  Future<void> _startBtcStream() async {
    try {
      await _btcSubscription?.cancel();
      await _btcPriceRepository.connect();
      _btcSubscription = _btcPriceRepository.watchPrice().listen(
        _handleBtcPrice,
        onError: (_) {
          if (isClosed) return;
          emit(
            state.copyWith(
              errorMessage: 'connectionError',
            ),
          );
        },
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(
          errorMessage: 'connectionError',
        ),
      );
    }
  }

  Future<void> retryConnection() async {
    emit(state.copyWith(clearError: true, status: GameStatus.playing));
    await _startBtcStream();
  }

  Future<void> stopGame() async {
    await _disposeSubscriptions();
    await _btcPriceRepository.disconnect();
    _engine = null;
    _statusBeforePause = null;
    emit(const GameState());
  }

  Future<void> _disposeSubscriptions() async {
    _stopGameLoop();
    await _btcSubscription?.cancel();
    _btcSubscription = null;
  }

  @override
  Future<void> close() async {
    await _disposeSubscriptions();
    await _btcPriceRepository.disconnect();
    return super.close();
  }
}
