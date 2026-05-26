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
}
