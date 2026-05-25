import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sweeper/core/l10n/app_localizations.dart';
import 'package:sweeper/core/utils/clock.dart';
import 'package:sweeper/core/auth/auth_session.dart';
import 'package:sweeper/core/config/app_access_config.dart';
import 'package:sweeper/features/auth/domain/repositories/auth_repository.dart';
import 'package:sweeper/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:sweeper/features/game/domain/entities/game_config.dart';
import 'package:sweeper/features/game/domain/repositories/btc_price_repository.dart';
import 'package:sweeper/features/game/presentation/cubit/game_cubit.dart';
import 'package:sweeper/features/game/presentation/pages/game_page.dart';
import 'package:sweeper/features/settings/presentation/cubit/settings_cubit.dart';

class MockBtcPriceRepository extends Mock implements BtcPriceRepository {}

class MockClock extends Mock implements Clock {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockBtcPriceRepository btcRepo;
  late MockClock clock;
  late MockAuthRepository authRepo;

  setUp(() {
    btcRepo = MockBtcPriceRepository();
    clock = MockClock();
    authRepo = MockAuthRepository();

    when(() => btcRepo.watchPrice()).thenAnswer((_) => const Stream.empty());
    when(() => btcRepo.connect()).thenAnswer((_) async {});
    when(() => btcRepo.disconnect()).thenAnswer((_) async {});
    when(() => clock.periodic(const Duration(seconds: 1)))
        .thenAnswer((_) => const Stream.empty());
    when(() => authRepo.authStateChanges).thenAnswer((_) => const Stream.empty());
    when(() => authRepo.currentUser).thenReturn(null);
    when(() => authRepo.isAvailable).thenReturn(false);
    when(() => authRepo.waitForInitialAuthState()).thenAnswer((_) async {});
    when(() => authRepo.getIdToken(forceRefresh: any(named: 'forceRefresh')))
        .thenAnswer((_) async => null);
  });

  Widget buildApp(Widget child) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MultiBlocProvider(
        providers: [
          BlocProvider<GameCubit>(
            create: (_) => GameCubit(
              btcPriceRepository: btcRepo,
              clock: clock,
              config: const GameConfig(
                gridSize: 8,
                initialBombCount: 5,
                emptyCellBuffer: 5,
              ),
            ),
          ),
          BlocProvider<SettingsCubit>(create: (_) => SettingsCubit()),
          BlocProvider<AuthCubit>(
            create: (_) => AuthCubit(
              authRepo,
              AuthSession(
                authRepository: authRepo,
                accessConfig: const AppAccessConfig(
                  androidGuestModeEnabled: false,
                ),
              ),
            ),
          ),
        ],
        child: child,
      ),
    );
  }

  testWidgets('GamePage renders title', (tester) async {
    await tester.pumpWidget(buildApp(const GamePage()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Minesweeper'), findsOneWidget);
  });
}
