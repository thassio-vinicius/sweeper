import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sweeper_settings/domain/entities/user_settings.dart';
import 'package:sweeper_settings/domain/repositories/settings_repository.dart';
import 'package:sweeper_settings/presentation/cubit/settings_cubit.dart';
import 'package:sweeper_settings/presentation/cubit/settings_state.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late MockSettingsRepository repository;

  setUpAll(() {
    registerFallbackValue(8);
  });

  setUp(() {
    repository = MockSettingsRepository();
    when(repository.load).thenAnswer(
      (_) async => const UserSettings(),
    );
    when(() => repository.saveGridSize(any())).thenAnswer((_) async {});
    when(() => repository.saveLanguageCode(any())).thenAnswer((_) async {});
  });

  blocTest<SettingsCubit, SettingsState>(
    'load applies defaults when storage is empty',
    build: () => SettingsCubit(repository),
    act: (cubit) => cubit.load(),
    expect: () => [
      const SettingsState(isLoaded: true, gridSize: 10, languageCode: 'en'),
    ],
  );

  blocTest<SettingsCubit, SettingsState>(
    'load restores persisted grid size and language',
    setUp: () {
      when(repository.load).thenAnswer(
        (_) async => const UserSettings(gridSize: 12, languageCode: 'es'),
      );
    },
    build: () => SettingsCubit(repository),
    act: (cubit) => cubit.load(),
    expect: () => [
      const SettingsState(isLoaded: true, gridSize: 12, languageCode: 'es'),
    ],
  );

  blocTest<SettingsCubit, SettingsState>(
    'setGridSize persists and emits',
    build: () => SettingsCubit(repository),
    seed: () => const SettingsState(isLoaded: true),
    act: (cubit) => cubit.setGridSize(8),
    expect: () => [const SettingsState(isLoaded: true, gridSize: 8)],
    verify: (_) {
      verify(() => repository.saveGridSize(8)).called(1);
    },
  );

  blocTest<SettingsCubit, SettingsState>(
    'setLanguageCode persists and emits',
    build: () => SettingsCubit(repository),
    seed: () => const SettingsState(isLoaded: true, languageCode: 'en'),
    act: (cubit) => cubit.setLanguageCode('pt'),
    expect: () => [
      const SettingsState(isLoaded: true, languageCode: 'pt'),
    ],
    verify: (_) {
      verify(() => repository.saveLanguageCode('pt')).called(1);
    },
  );

  blocTest<SettingsCubit, SettingsState>(
    'setGridSize ignores unsupported sizes',
    build: () => SettingsCubit(repository),
    seed: () => const SettingsState(isLoaded: true, gridSize: 10),
    act: (cubit) => cubit.setGridSize(9),
    expect: () => <SettingsState>[],
    verify: (_) {
      verifyNever(() => repository.saveGridSize(any()));
    },
  );
}
