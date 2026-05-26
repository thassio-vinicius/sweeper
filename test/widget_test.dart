import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sweeper_l10n/sweeper_l10n.dart';
import 'package:sweeper_game/core/clock.dart';
import 'package:sweeper_auth/session/auth_session.dart';
import 'package:sweeper_auth/config/app_access_config.dart';
import 'package:sweeper_auth/domain/repositories/auth_repository.dart';
import 'package:sweeper_auth/presentation/cubit/auth_cubit.dart';
import 'package:sweeper_game/domain/entities/game_config.dart';
import 'package:sweeper_game/domain/repositories/btc_price_repository.dart';
import 'package:sweeper_game/presentation/cubit/game_cubit.dart';
import 'package:sweeper_game/presentation/pages/game_page.dart';
import 'package:sweeper_settings/sweeper_settings.dart';

class MockBtcPriceRepository extends Mock implements BtcPriceRepository {}

class MockClock extends Mock implements Clock {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSettingsStorage extends Mock implements SettingsStorage {}

void main() {
  late MockBtcPriceRepository btcRepo;
  late MockClock clock;
  late MockAuthRepository authRepo;
  late MockSettingsStorage settingsStorage;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  setUp(() {
    btcRepo = MockBtcPriceRepository();
    clock = MockClock();
    authRepo = MockAuthRepository();
    settingsStorage = MockSettingsStorage();

    when(() => btcRepo.watchPrice()).thenAnswer((_) => const Stream.empty());
    when(() => btcRepo.connect()).thenAnswer((_) async {});
    when(() => btcRepo.disconnect()).thenAnswer((_) async {});
    when(() => clock.periodic(const Duration(seconds: 1)))
        .thenAnswer((_) => const Stream.empty());
    when(() => authRepo.authStateChanges).thenAnswer((_) => const Stream.empty());
    when(() => authRepo.currentUser).thenReturn(null);
    when(() => authRepo.waitForInitialAuthState()).thenAnswer((_) async {});
    when(() => settingsStorage.readGridSize()).thenAnswer((_) async => 8);
    when(() => settingsStorage.readLanguageCode()).thenAnswer((_) async => 'en');
    when(() => settingsStorage.writeGridSize(any())).thenAnswer((_) async {});
    when(() => settingsStorage.writeLanguageCode(any())).thenAnswer((_) async {});
  });

  testWidgets('GamePage renders title', (tester) async {
    final settingsCubit = SettingsCubit(settingsStorage);
    await settingsCubit.load();

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: AppLocales.supported,
        fallbackLocale: AppLocales.fallback,
        startLocale: AppLocales.fallback,
        path: SweeperAssetLoader.translationsPath,
        assetLoader: const SweeperAssetLoader(),
        saveLocale: false,
        child: Builder(
          builder: (context) {
            return MaterialApp(
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
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
                  BlocProvider<SettingsCubit>.value(value: settingsCubit),
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
                child: const GamePage(),
              ),
            );
          },
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Minesweeper'), findsOneWidget);
  });
}
