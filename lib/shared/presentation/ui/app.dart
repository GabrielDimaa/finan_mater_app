import 'package:finan_master_app/features/config/presentation/notifiers/theme_mode_notifier.dart';
import 'package:finan_master_app/shared/presentation/ui/app_locale.dart';
import 'package:finan_master_app/shared/presentation/ui/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';

const String appName = 'Finan Master';

class App extends StatefulWidget {
  const App({super.key});

  static final ThemeModeNotifier themeNotifier = GetIt.I.get<ThemeModeNotifier>();

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final RouterConfig<Object> routerConfig = AppRouter.routerConfig();

  @override
  void initState() {
    super.initState();

    App.themeNotifier.find();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: App.themeNotifier,
      builder: (_, themeMode, __) {
        return MaterialApp.router(
          title: appName,
          debugShowCheckedModeBanner: false,
          routerConfig: routerConfig,
          themeMode: themeMode,
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Roboto',
            colorScheme: themeMode == ThemeMode.dark ? themeDark : themeLight,
            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                fixedSize: const Size.fromHeight(40),
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                fixedSize: const Size.fromHeight(40),
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                fixedSize: const Size.fromHeight(40),
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                fixedSize: const Size.fromHeight(40),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            dividerTheme: const DividerThemeData(
              space: 2,
            ),
            listTileTheme: const ListTileThemeData(
              contentPadding: EdgeInsets.only(left: 16, top: 8, right: 24, bottom: 8),
            ),
            inputDecorationTheme: const InputDecorationTheme(
              border: OutlineInputBorder(),
            ),
          ),
          locale: R.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        );
      }
    );
  }

  ColorScheme get themeLight => ColorScheme.fromSeed(seedColor: const Color(0xFF005BC0), brightness: Brightness.light);

  ColorScheme get themeDark => ColorScheme.fromSeed(seedColor: const Color(0xFF005BC0), brightness: Brightness.dark);
}
