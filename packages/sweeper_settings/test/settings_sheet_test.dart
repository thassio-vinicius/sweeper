import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sweeper_l10n/sweeper_l10n.dart';
import 'package:sweeper_settings/domain/entities/user_settings.dart';
import 'package:sweeper_settings/domain/repositories/settings_repository.dart';
import 'package:sweeper_settings/presentation/cubit/settings_cubit.dart';
import 'package:sweeper_settings/presentation/widgets/settings_sheet.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late MockSettingsRepository repository;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    registerFallbackValue(8);
  });

  setUp(() {
    repository = MockSettingsRepository();
    when(repository.load).thenAnswer(
      (_) async => const UserSettings(gridSize: 10, languageCode: 'en'),
    );
    when(() => repository.saveGridSize(any())).thenAnswer((_) async {});
    when(() => repository.saveLanguageCode(any())).thenAnswer((_) async {});
  });

  Future<void> pumpSettingsSheet(WidgetTester tester) async {
    final settingsCubit = SettingsCubit(repository);
    await settingsCubit.load();

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: AppLocales.supported,
        fallbackLocale: AppLocales.fallback,
        startLocale: AppLocales.fallback,
        path: SweeperAssetLoader.translationsPath,
        assetLoader: const SweeperAssetLoader(),
        saveLocale: false,
        child: BlocProvider<SettingsCubit>.value(
          value: settingsCubit,
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
                          onPressed: () => showSettingsSheet(navContext),
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
    verify(() => repository.saveLanguageCode('es')).called(1);
  });
}
