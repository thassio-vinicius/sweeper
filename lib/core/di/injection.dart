import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:sweeper/core/router/app_router.dart';
import 'package:sweeper/core/router/auth_refresh_notifier.dart';
import 'package:sweeper_settings/sweeper_settings.dart';
import 'package:sweeper_auth/config/create_app_access_config.dart';
import 'package:sweeper_auth/config/app_access_config.dart';
import 'package:sweeper_auth/data/repositories/auth_repository_impl.dart';
import 'package:sweeper_auth/data/repositories/noop_auth_repository.dart';
import 'package:sweeper_auth/domain/repositories/auth_repository.dart';
import 'package:sweeper_auth/presentation/cubit/auth_cubit.dart';
import 'package:sweeper_auth/session/auth_session.dart';
import 'package:sweeper_core/clock.dart';
import 'package:sweeper_game/data/datasources/binance_ws.dart';
import 'package:sweeper_game/data/repositories/btc_price_repository_impl.dart';
import 'package:sweeper_game/domain/repositories/btc_price_repository.dart';
import 'package:sweeper_game/presentation/cubit/game_cubit.dart';
import 'package:sweeper_network/authenticated_http_client.dart';

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

  getIt.registerLazySingleton<AuthRepository>(() {
    if (Firebase.apps.isNotEmpty) {
      return AuthRepositoryImpl();
    }
    return NoOpAuthRepository();
  });

  getIt.registerLazySingleton<AuthSession>(
    () => AuthSession(
      authRepository: getIt(),
      accessConfig: getIt(),
    ),
  );

  getIt.registerLazySingleton<AuthenticatedHttpClient>(
    () => AuthenticatedHttpClient(getIt(), getIt()),
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

  getIt.registerFactory(
    () => GameCubit(
      btcPriceRepository: getIt(),
      clock: getIt(),
    ),
  );

  getIt.registerFactory(SettingsCubit.new);
  getIt.registerFactory(() => AuthCubit(getIt(), getIt()));
}
