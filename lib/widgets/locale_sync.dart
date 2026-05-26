import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sweeper_l10n/sweeper_l10n.dart';
import 'package:sweeper_settings/sweeper_settings.dart';

/// Applies [SettingsCubit] language changes to Easy Localization.
class LocaleSync extends StatelessWidget {
  const LocaleSync({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsCubit, SettingsState>(
      listenWhen: (previous, current) =>
          current.isLoaded && previous.languageCode != current.languageCode,
      listener: (context, state) {
        context.setLocale(AppLocales.localeFor(state.languageCode));
      },
      child: child,
    );
  }
}
