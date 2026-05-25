import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sweeper/core/di/injection.dart';
import 'package:sweeper/core/l10n/app_localizations.dart';
import 'package:sweeper/core/router/app_router.dart';
import 'package:sweeper/core/theme/app_theme.dart';
import 'package:sweeper/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:sweeper/features/game/presentation/cubit/game_cubit.dart';
import 'package:sweeper/features/settings/presentation/cubit/settings_cubit.dart';

class SweeperApp extends StatelessWidget {
  SweeperApp({super.key});

  final _router = getIt<AppRouter>().router;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<GameCubit>()),
        BlocProvider(create: (_) => getIt<SettingsCubit>()),
        BlocProvider(create: (_) => getIt<AuthCubit>()),
      ],
      child: MaterialApp.router(
        title: 'Reversed Minesweeper',
        theme: AppTheme.dark,
        routerConfig: _router,
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
