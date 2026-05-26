import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sweeper_game/core/clock.dart';
import 'package:sweeper_game/domain/entities/game_config.dart';
import 'package:sweeper_game/domain/entities/game_entities.dart';
import 'package:sweeper_game/domain/repositories/btc_price_repository.dart';
import 'package:sweeper_game/presentation/cubit/game_cubit.dart';
import 'package:sweeper_game/presentation/cubit/game_state.dart';
import 'package:sweeper_game/presentation/cubit/pause_reason.dart';
import 'test_helpers/board_moves.dart';

class MockBtcPriceRepository extends Mock implements BtcPriceRepository {}

class MockClock extends Mock implements Clock {}

void main() {
  late MockBtcPriceRepository btcRepo;
  late MockClock clock;
  late StreamController<BtcPrice> priceController;
  late StreamController<int> tickController;

  const config = GameConfig(
    gridSize: 8,
    initialBombCount: 5,
    emptyCellBuffer: 5,
  );

  GameCubit buildCubit() => GameCubit(
        btcPriceRepository: btcRepo,
        clock: clock,
        config: config,
      );

  setUp(() {
    btcRepo = MockBtcPriceRepository();
    clock = MockClock();
    priceController = StreamController<BtcPrice>.broadcast();
    tickController = StreamController<int>.broadcast();

    when(() => btcRepo.watchPrice()).thenAnswer((_) => priceController.stream);
    when(() => btcRepo.connect()).thenAnswer((_) async {});
    when(() => btcRepo.disconnect()).thenAnswer((_) async {});
    when(() => clock.periodic(const Duration(seconds: 1)))
        .thenAnswer((_) => tickController.stream);
    when(clock.now).thenReturn(DateTime(2024, 1, 1));
  });

  tearDown(() async {
    await priceController.close();
    await tickController.close();
  });

  blocTest<GameCubit, GameState>(
    'startGame initializes playing state',
    build: buildCubit,
    act: (cubit) => cubit.startGame(),
    verify: (cubit) {
      expect(cubit.state.status, GameStatus.playing);
      expect(cubit.state.snapshot, isNotNull);
    },
  );

  blocTest<GameCubit, GameState>(
    'BTC price update forwarded to engine',
    build: buildCubit,
    act: (cubit) async {
      await cubit.startGame();
      priceController.add(
        BtcPrice(priceUsd: 50000, receivedAt: DateTime.now()),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
    },
    verify: (cubit) {
      expect(cubit.state.btcPrice?.integerPrice, 50000);
    },
  );

  blocTest<GameCubit, GameState>(
    'valid move updates board immediately without animating',
    build: buildCubit,
    act: (cubit) async {
      await cubit.startGame();
      final move = findSafeMove(cubit.state.snapshot!);
      expect(move, isNotNull, reason: 'test board should allow a safe move');

      cubit.movePiece(
        fromRow: move!.fromRow,
        fromCol: move.fromCol,
        toRow: move.toRow,
        toCol: move.toCol,
      );
    },
    verify: (cubit) {
      expect(cubit.state.status, GameStatus.playing);
      expect(cubit.state.explosionAt, isNull);
    },
  );

  blocTest<GameCubit, GameState>(
    'bomb discovery triggers explosion animation',
    build: buildCubit,
    act: (cubit) async {
      await cubit.startGame();

      MoveCoords? discoveryMove;
      for (var attempt = 0; attempt < 20; attempt++) {
        await cubit.restart();
        discoveryMove = findHiddenBombMove(cubit.state.snapshot!);
        if (discoveryMove != null) break;
      }

      expect(
        discoveryMove,
        isNotNull,
        reason: 'expected a hidden bomb adjacent to a piece within 20 boards',
      );

      cubit.movePiece(
        fromRow: discoveryMove!.fromRow,
        fromCol: discoveryMove.fromCol,
        toRow: discoveryMove.toRow,
        toCol: discoveryMove.toCol,
      );
    },
    verify: (cubit) {
      expect(cubit.state.status, GameStatus.animating);
      expect(cubit.state.explosionAt, isNotNull);
      expect(cubit.state.snapshot!.discoveredBombCount, 1);
    },
  );

  blocTest<GameCubit, GameState>(
    'timer tick explodes a bomb and shows explosion animation',
    build: buildCubit,
    act: (cubit) async {
      await cubit.startGame();
      final hiddenBefore = cubit.state.snapshot!.board.hiddenBombCount;

      for (var tick = 0; tick < 10; tick++) {
        tickController.add(tick);
        await Future<void>.delayed(Duration.zero);
      }

      expect(cubit.state.snapshot!.board.hiddenBombCount, hiddenBefore - 1);
    },
    verify: (cubit) {
      expect(cubit.state.explosionAt, isNotNull);
      expect(cubit.state.status, GameStatus.animating);
      expect(cubit.state.snapshot!.explodedBombCount, 1);
    },
  );

  blocTest<GameCubit, GameState>(
    'timer and BTC engine are paused while animating',
    build: buildCubit,
    act: (cubit) async {
      await cubit.startGame();

      MoveCoords? discoveryMove;
      for (var attempt = 0; attempt < 20; attempt++) {
        await cubit.restart();
        discoveryMove = findHiddenBombMove(cubit.state.snapshot!);
        if (discoveryMove != null) break;
      }
      expect(discoveryMove, isNotNull);

      cubit.movePiece(
        fromRow: discoveryMove!.fromRow,
        fromCol: discoveryMove.fromCol,
        toRow: discoveryMove.toRow,
        toCol: discoveryMove.toCol,
      );

      final hiddenBefore = cubit.state.snapshot!.board.hiddenBombCount;
      for (var tick = 0; tick < 12; tick++) {
        tickController.add(tick);
        await Future<void>.delayed(Duration.zero);
      }

      priceController.add(
        BtcPrice(priceUsd: 95000, receivedAt: DateTime.now()),
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(cubit.state.snapshot!.board.hiddenBombCount, hiddenBefore);
      expect(cubit.state.status, GameStatus.animating);
    },
  );

  blocTest<GameCubit, GameState>(
    'move is ignored while animating',
    build: buildCubit,
    act: (cubit) async {
      await cubit.startGame();

      MoveCoords? discoveryMove;
      for (var attempt = 0; attempt < 20; attempt++) {
        await cubit.restart();
        discoveryMove = findHiddenBombMove(cubit.state.snapshot!);
        if (discoveryMove != null) break;
      }
      expect(discoveryMove, isNotNull);

      cubit.movePiece(
        fromRow: discoveryMove!.fromRow,
        fromCol: discoveryMove.fromCol,
        toRow: discoveryMove.toRow,
        toCol: discoveryMove.toCol,
      );

      final snapshotAfterDiscovery = cubit.state.snapshot;
      final secondMove = findSafeMove(snapshotAfterDiscovery!);
      expect(secondMove, isNotNull);

      cubit.movePiece(
        fromRow: secondMove!.fromRow,
        fromCol: secondMove.fromCol,
        toRow: secondMove.toRow,
        toCol: secondMove.toCol,
      );

      expect(cubit.state.snapshot, snapshotAfterDiscovery);
    },
  );

  blocTest<GameCubit, GameState>(
    'pause and resume restore playing status',
    build: buildCubit,
    act: (cubit) async {
      await cubit.startGame();
      cubit.pause();
      cubit.resume();
    },
    verify: (cubit) {
      expect(cubit.state.status, GameStatus.playing);
      expect(cubit.state.pauseReason, PauseReason.none);
    },
  );

  blocTest<GameCubit, GameState>(
    'invalid move triggers snap-back state',
    build: buildCubit,
    act: (cubit) async {
      await cubit.startGame();
      final snapshot = cubit.state.snapshot!;
      final board = snapshot.board;

      int? fromRow;
      int? fromCol;
      int? occupiedRow;
      int? occupiedCol;

      for (var row = 0; row < board.gridSize; row++) {
        for (var col = 0; col < board.gridSize; col++) {
          final cell = board.cellAt(row, col);
          if (cell.piece != null && fromRow == null) {
            fromRow = row;
            fromCol = col;
          } else if (cell.piece != null && fromRow != null) {
            occupiedRow = row;
            occupiedCol = col;
            break;
          }
        }
        if (occupiedRow != null) break;
      }

      expect(fromRow, isNotNull);
      expect(occupiedRow, isNotNull);

      cubit.movePiece(
        fromRow: fromRow!,
        fromCol: fromCol!,
        toRow: occupiedRow!,
        toCol: occupiedCol!,
      );
    },
    verify: (cubit) {
      expect(cubit.state.snapBackCell, isNotNull);
      expect(cubit.state.snapBackGeneration, 1);
    },
  );

  blocTest<GameCubit, GameState>(
    'BTC magic bomb update sets magic bomb UI state',
    build: buildCubit,
    act: (cubit) async {
      await cubit.startGame();
      for (var tick = 0; tick < 10; tick++) {
        tickController.add(tick);
        await Future<void>.delayed(Duration.zero);
      }
      await Future<void>.delayed(const Duration(milliseconds: 850));

      priceController.add(
        BtcPrice(priceUsd: 67454, receivedAt: DateTime.now()),
      );
      priceController.add(
        BtcPrice(priceUsd: 67455, receivedAt: DateTime.now()),
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));
    },
    verify: (cubit) {
      expect(cubit.state.magicBombAt, isNotNull);
      expect(cubit.state.magicBombBannerWholeDollars, 67455);
    },
  );

  blocTest<GameCubit, GameState>(
    'stopGame resets cubit state',
    build: buildCubit,
    act: (cubit) async {
      await cubit.startGame();
      await cubit.stopGame();
    },
    verify: (cubit) {
      expect(cubit.state.status, GameStatus.initial);
      expect(cubit.state.snapshot, isNull);
    },
  );

  blocTest<GameCubit, GameState>(
    'onInvalidDrop triggers snap-back state',
    build: buildCubit,
    act: (cubit) async {
      await cubit.startGame();
      cubit.onInvalidDrop(fromRow: 0, fromCol: 0);
    },
    verify: (cubit) {
      expect(cubit.state.snapBackCell, (row: 0, col: 0));
      expect(cubit.state.snapBackGeneration, 1);
    },
  );

  blocTest<GameCubit, GameState>(
    'winning move transitions to game over',
    build: buildCubit,
    act: (cubit) async {
      await cubit.startGame();

      MoveCoords? discoveryMove;
      for (var attempt = 0; attempt < 30; attempt++) {
        await cubit.restart(
          config: const GameConfig(
            gridSize: 6,
            initialBombCount: 1,
            emptyCellBuffer: 2,
          ),
        );
        discoveryMove = findHiddenBombMove(cubit.state.snapshot!);
        if (discoveryMove != null) break;
      }

      expect(discoveryMove, isNotNull);
      cubit.movePiece(
        fromRow: discoveryMove!.fromRow,
        fromCol: discoveryMove.fromCol,
        toRow: discoveryMove.toRow,
        toCol: discoveryMove.toCol,
      );
      await Future<void>.delayed(const Duration(milliseconds: 850));
    },
    verify: (cubit) {
      expect(cubit.state.status, GameStatus.gameOver);
      expect(cubit.state.explosionAt, isNull);
    },
  );

  blocTest<GameCubit, GameState>(
    'BTC stream error sets connection error message',
    build: buildCubit,
    setUp: () {
      when(() => btcRepo.connect()).thenAnswer((_) async {});
      when(() => btcRepo.watchPrice()).thenAnswer(
        (_) => Stream<BtcPrice>.error(Exception('socket')),
      );
    },
    act: (cubit) async {
      await cubit.startGame();
      await Future<void>.delayed(const Duration(milliseconds: 20));
    },
    verify: (cubit) {
      expect(cubit.state.errorMessage, 'connectionError');
    },
  );

  blocTest<GameCubit, GameState>(
    'explosion animation clears back to playing',
    build: buildCubit,
    act: (cubit) async {
      await cubit.startGame();

      MoveCoords? discoveryMove;
      for (var attempt = 0; attempt < 20; attempt++) {
        await cubit.restart();
        discoveryMove = findHiddenBombMove(cubit.state.snapshot!);
        if (discoveryMove != null) break;
      }
      expect(discoveryMove, isNotNull);

      cubit.movePiece(
        fromRow: discoveryMove!.fromRow,
        fromCol: discoveryMove.fromCol,
        toRow: discoveryMove.toRow,
        toCol: discoveryMove.toCol,
      );
      await Future<void>.delayed(const Duration(milliseconds: 850));
    },
    verify: (cubit) {
      expect(cubit.state.status, GameStatus.playing);
      expect(cubit.state.explosionAt, isNull);
    },
  );

  blocTest<GameCubit, GameState>(
    'BTC price direction reflects decreases',
    build: buildCubit,
    act: (cubit) async {
      await cubit.startGame();
      priceController.add(
        BtcPrice(priceUsd: 50005, receivedAt: DateTime.now()),
      );
      priceController.add(
        BtcPrice(priceUsd: 50000, receivedAt: DateTime.now()),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
    },
    verify: (cubit) {
      expect(cubit.state.btcPriceDirection, -1);
    },
  );

  blocTest<GameCubit, GameState>(
    'magic bomb UI clears after animation timers',
    build: buildCubit,
    act: (cubit) async {
      await cubit.startGame();
      for (var tick = 0; tick < 10; tick++) {
        tickController.add(tick);
        await Future<void>.delayed(Duration.zero);
      }
      await Future<void>.delayed(const Duration(milliseconds: 850));

      priceController.add(
        BtcPrice(priceUsd: 67454, receivedAt: DateTime.now()),
      );
      priceController.add(
        BtcPrice(priceUsd: 67455, receivedAt: DateTime.now()),
      );
      await Future<void>.delayed(const Duration(milliseconds: 2500));
    },
    verify: (cubit) {
      expect(cubit.state.magicBombAt, isNull);
      expect(cubit.state.magicBombBannerWholeDollars, isNull);
    },
  );

  blocTest<GameCubit, GameState>(
    'retryConnection clears error and reconnects',
    build: buildCubit,
    setUp: () {
      var attempts = 0;
      when(() => btcRepo.connect()).thenAnswer((_) async {
        attempts++;
        if (attempts == 1) {
          throw Exception('offline');
        }
      });
    },
    act: (cubit) async {
      await cubit.startGame();
      await cubit.retryConnection();
    },
    verify: (cubit) {
      expect(cubit.state.errorMessage, isNull);
      expect(cubit.state.status, GameStatus.playing);
      verify(() => btcRepo.connect()).called(2);
    },
  );
}
