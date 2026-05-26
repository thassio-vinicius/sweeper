import 'package:get_it/get_it.dart';
import 'package:sweeper/core/config/app_env.dart';
import 'package:sweeper/core/router/app_router.dart';
import 'package:sweeper/core/router/auth_refresh_notifier.dart';
import 'package:sweeper_auth/config/app_access_config.dart';
import 'package:sweeper_auth/config/create_app_access_config.dart';
import 'package:sweeper_auth/data/repositories/auth_repository_impl.dart';
import 'package:sweeper_auth/domain/repositories/auth_repository.dart';
import 'package:sweeper_auth/session/auth_session.dart';
import 'package:sweeper_game/core/clock.dart';
import 'package:sweeper_game/data/datasources/binance_ws.dart';
import 'package:sweeper_game/data/repositories/btc_price_repository_impl.dart';
import 'package:sweeper_game/domain/repositories/btc_price_repository.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  getIt.registerLazySingleton<Clock>(SystemClock.new);
  getIt.registerLazySingleton<AppAccessConfig>(createAppAccessConfig);

  getIt.registerLazySingleton<BinanceWebSocketDataSource>(
    BinanceWebSocketDataSource.new,
  );

  getIt.registerLazySingleton<BtcPriceRepository>(
    () => BtcPriceRepositoryImpl(getIt()),
  );

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      googleServerClientId: AppEnv.googleServerClientId,
    ),
  );

  getIt.registerLazySingleton<AuthSession>(
    () => AuthSession(
      authRepository: getIt(),
      accessConfig: getIt(),
    ),
  );

  getIt.registerLazySingleton<AuthRefreshNotifier>(
    () => AuthRefreshNotifier(getIt()),
  );

  getIt.registerLazySingleton<AppRouter>(
    () => AppRouter(
      authSession: getIt(),
      refreshNotifier: getIt(),
    ),
  );
}

Future<void> warmUpAuthSession() async {
  await getIt<AuthRepository>().waitForInitialAuthState();
}
