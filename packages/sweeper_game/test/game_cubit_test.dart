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

class MockBtcPriceRepository extends Mock implements BtcPriceRepository {}

class MockClock extends Mock implements Clock {}

void main() {
  late MockBtcPriceRepository btcRepo;
  late MockClock clock;
  late StreamController<BtcPrice> priceController;
  late StreamController<int> tickController;

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
    build: () => GameCubit(
      btcPriceRepository: btcRepo,
      clock: clock,
      config: const GameConfig(gridSize: 8, initialBombCount: 5, emptyCellBuffer: 5),
    ),
    act: (cubit) => cubit.startGame(),
    verify: (cubit) {
      expect(cubit.state.status, GameStatus.playing);
      expect(cubit.state.snapshot, isNotNull);
    },
  );

  blocTest<GameCubit, GameState>(
    'BTC price update forwarded to engine',
    build: () => GameCubit(
      btcPriceRepository: btcRepo,
      clock: clock,
      config: const GameConfig(
        gridSize: 8,
        initialBombCount: 5,
        emptyCellBuffer: 5,
      ),
    ),
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
}
