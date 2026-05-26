import 'package:flutter/material.dart';
import 'package:sweeper/app.dart';
import 'package:sweeper/core/config/app_env.dart';
import 'package:sweeper/core/di/injection.dart';
import 'package:sweeper/core/firebase/firebase_bootstrap.dart';
import 'package:sweeper_l10n/sweeper_l10n.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await AppEnv.load();
  await FirebaseBootstrap.initialize();
  await configureDependencies();
  await warmUpAuthSession();
  runApp(
    EasyLocalization(
      supportedLocales: AppLocales.supported,
      fallbackLocale: AppLocales.fallback,
      path: SweeperAssetLoader.translationsPath,
      assetLoader: const SweeperAssetLoader(),
      saveLocale: false,
      child: const SweeperApp(),
    ),
  );
}
