import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:sweeper/core/utils/clock.dart';
import 'package:sweeper/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:sweeper/features/auth/data/repositories/noop_auth_repository.dart';
import 'package:sweeper/features/auth/domain/repositories/auth_repository.dart';
import 'package:sweeper/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:sweeper/features/game/data/datasources/binance_ws.dart';
import 'package:sweeper/features/game/data/repositories/btc_price_repository_impl.dart';
import 'package:sweeper/features/game/domain/repositories/btc_price_repository.dart';
import 'package:sweeper/features/game/presentation/cubit/game_cubit.dart';
import 'package:sweeper/features/settings/presentation/cubit/settings_cubit.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  getIt.registerLazySingleton<Clock>(SystemClock.new);

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

  getIt.registerFactory(
    () => GameCubit(
      btcPriceRepository: getIt(),
      clock: getIt(),
    ),
  );

  getIt.registerFactory(SettingsCubit.new);
  getIt.registerFactory(() => AuthCubit(getIt()));
}
