import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sweeper_l10n/sweeper_l10n.dart';
import 'package:sweeper_auth/presentation/cubit/auth_cubit.dart';
import 'package:sweeper_auth/config/app_access_config.dart';
import 'package:sweeper_auth/domain/repositories/auth_repository.dart';
import 'package:sweeper_auth/session/auth_session.dart';
import 'package:sweeper_game/core/clock.dart';
import 'package:sweeper_game/domain/repositories/btc_price_repository.dart';
import 'package:sweeper_game/presentation/cubit/game_cubit.dart';
import 'package:sweeper_game/presentation/widgets/game_settings_sheet.dart';
import 'package:sweeper_settings/sweeper_settings.dart';

class MockBtcPriceRepository extends Mock implements BtcPriceRepository {}

class MockClock extends Mock implements Clock {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSettingsStorage extends Mock implements SettingsStorage {}

void main() {
  late MockSettingsStorage settingsStorage;
  late MockAuthRepository authRepository;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  setUp(() {
    settingsStorage = MockSettingsStorage();
    authRepository = MockAuthRepository();

    when(() => settingsStorage.readGridSize()).thenAnswer((_) async => 10);
    when(() => settingsStorage.readLanguageCode()).thenAnswer((_) async => 'en');
    when(() => settingsStorage.writeGridSize(any())).thenAnswer((_) async {});
    when(() => settingsStorage.writeLanguageCode(any()))
        .thenAnswer((_) async {});

    when(() => authRepository.authStateChanges)
        .thenAnswer((_) => const Stream.empty());
    when(() => authRepository.currentUser).thenReturn(null);
    when(() => authRepository.waitForInitialAuthState()).thenAnswer((_) async {});
  });

  Future<void> pumpSettingsSheet(WidgetTester tester) async {
    final settingsCubit = SettingsCubit(settingsStorage);
    await settingsCubit.load();

    final btcRepo = MockBtcPriceRepository();
    final clock = MockClock();
    when(() => btcRepo.watchPrice()).thenAnswer((_) => const Stream.empty());
    when(() => btcRepo.connect()).thenAnswer((_) async {});
    when(() => btcRepo.disconnect()).thenAnswer((_) async {});
    when(() => clock.periodic(const Duration(seconds: 1)))
        .thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: AppLocales.supported,
        fallbackLocale: AppLocales.fallback,
        startLocale: AppLocales.fallback,
        path: SweeperAssetLoader.translationsPath,
        assetLoader: const SweeperAssetLoader(),
        saveLocale: false,
        child: MultiBlocProvider(
          providers: [
            BlocProvider<SettingsCubit>.value(value: settingsCubit),
            BlocProvider(
              create: (_) => GameCubit(
                btcPriceRepository: btcRepo,
                clock: clock,
              ),
            ),
            BlocProvider(
              create: (_) => AuthCubit(
                authRepository,
                AuthSession(
                  authRepository: authRepository,
                  accessConfig: const AppAccessConfig(
                    androidGuestModeEnabled: false,
                  ),
                ),
              ),
            ),
          ],
          child: Builder(
            builder: (context) {
              return MaterialApp(
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,
                home: Builder(
                  builder: (navContext) {
                    return Scaffold(
                      body: Center(
                        child: ElevatedButton(
                          onPressed: () {
                            showGameSettingsSheet(
                              navContext,
                              gameCubit: navContext.read<GameCubit>(),
                            );
                          },
                          child: const Text('open'),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('settings sheet shows sections and switches language', (tester) async {
    await pumpSettingsSheet(tester);

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Board Size'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Español'), findsOneWidget);
    expect(find.text('Português'), findsOneWidget);
    expect(find.text('10x10'), findsOneWidget);

    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();

    expect(find.text('Idioma'), findsOneWidget);
    expect(find.text('Tamaño del tablero'), findsOneWidget);
  });
}
