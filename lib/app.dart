import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/router/app_router.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/theme/app_theme.dart';

/// Root widget: MaterialApp.router with accessible theme and l10n.
class App extends ConsumerWidget {
  /// Creates the app.
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Nadie Fuera',
      theme: AppTheme.theme,
      routerConfig: router,
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
