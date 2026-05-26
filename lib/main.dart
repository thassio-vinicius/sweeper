import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sweeper/app.dart';
import 'package:sweeper/core/config/app_env.dart';
import 'package:sweeper/core/di/injection.dart';
import 'package:sweeper/core/firebase/firebase_bootstrap.dart';
import 'package:sweeper_l10n/sweeper_l10n.dart';
import 'package:sweeper_settings/sweeper_settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await EasyLocalization.ensureInitialized();
  await AppEnv.load();
  await FirebaseBootstrap.initialize();
  await configureDependencies();
  await warmUpAuthSession();

  final settingsCubit = SettingsCubit(getIt<SettingsRepository>());
  await settingsCubit.load();

  runApp(
    EasyLocalization(
      supportedLocales: AppLocales.supported,
      fallbackLocale: AppLocales.fallback,
      startLocale: AppLocales.localeFor(settingsCubit.state.languageCode),
      path: SweeperAssetLoader.translationsPath,
      assetLoader: const SweeperAssetLoader(),
      saveLocale: false,
      child: SweeperApp(settingsCubit: settingsCubit),
    ),
  );
}
