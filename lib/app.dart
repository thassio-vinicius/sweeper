import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sweeper/core/di/injection.dart';
import 'package:sweeper/core/router/app_router.dart';
import 'package:sweeper_auth/domain/repositories/auth_repository.dart';
import 'package:sweeper_auth/presentation/cubit/auth_cubit.dart';
import 'package:sweeper_auth/session/auth_session.dart';
import 'package:sweeper_game/presentation/cubit/game_cubit.dart';
import 'package:sweeper_l10n/sweeper_l10n.dart';
import 'package:sweeper_settings/sweeper_settings.dart';
import 'package:sweeper_theme/app_theme.dart';

class SweeperApp extends StatelessWidget {
  const SweeperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => GameCubit(
            btcPriceRepository: getIt(),
            clock: getIt(),
          ),
        ),
        BlocProvider(create: (_) => SettingsCubit()),
        BlocProvider(
          create: (_) => AuthCubit(getIt<AuthRepository>(), getIt<AuthSession>()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Reversed Minesweeper',
        theme: AppTheme.dark,
        routerConfig: getIt<AppRouter>().router,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }
}
