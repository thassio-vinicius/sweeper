import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sweeper_settings/settings_cubit.dart';
import 'package:sweeper_settings/settings_storage.dart';

class MockSettingsStorage extends Mock implements SettingsStorage {}

void main() {
  late MockSettingsStorage storage;

  setUp(() {
    storage = MockSettingsStorage();
    when(() => storage.readGridSize()).thenAnswer((_) async => null);
    when(() => storage.readLanguageCode()).thenAnswer((_) async => null);
    when(() => storage.writeGridSize(any())).thenAnswer((_) async {});
    when(() => storage.writeLanguageCode(any())).thenAnswer((_) async {});
  });

  blocTest<SettingsCubit, SettingsState>(
    'load applies defaults when storage is empty',
    build: () => SettingsCubit(storage),
    act: (cubit) => cubit.load(),
    expect: () => [
      const SettingsState(isLoaded: true, gridSize: 10, languageCode: 'en'),
    ],
  );

  blocTest<SettingsCubit, SettingsState>(
    'load restores persisted grid size and language',
    setUp: () {
      when(() => storage.readGridSize()).thenAnswer((_) async => 12);
      when(() => storage.readLanguageCode()).thenAnswer((_) async => 'es');
    },
    build: () => SettingsCubit(storage),
    act: (cubit) => cubit.load(),
    expect: () => [
      const SettingsState(isLoaded: true, gridSize: 12, languageCode: 'es'),
    ],
  );

  blocTest<SettingsCubit, SettingsState>(
    'setGridSize persists and emits',
    build: () => SettingsCubit(storage),
    seed: () => const SettingsState(isLoaded: true),
    act: (cubit) => cubit.setGridSize(8),
    expect: () => [const SettingsState(isLoaded: true, gridSize: 8)],
    verify: (_) {
      verify(() => storage.writeGridSize(8)).called(1);
    },
  );

  blocTest<SettingsCubit, SettingsState>(
    'setLanguageCode persists and emits',
    build: () => SettingsCubit(storage),
    seed: () => const SettingsState(isLoaded: true, languageCode: 'en'),
    act: (cubit) => cubit.setLanguageCode('pt'),
    expect: () => [
      const SettingsState(isLoaded: true, languageCode: 'pt'),
    ],
    verify: (_) {
      verify(() => storage.writeLanguageCode('pt')).called(1);
    },
  );

  blocTest<SettingsCubit, SettingsState>(
    'setGridSize ignores unsupported sizes',
    build: () => SettingsCubit(storage),
    seed: () => const SettingsState(isLoaded: true, gridSize: 10),
    act: (cubit) => cubit.setGridSize(9),
    expect: () => <SettingsState>[],
    verify: (_) {
      verifyNever(() => storage.writeGridSize(any()));
    },
  );
}
