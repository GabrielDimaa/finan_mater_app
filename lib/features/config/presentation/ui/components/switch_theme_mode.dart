import 'package:finan_master_app/shared/presentation/ui/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SwitchThemeMode extends StatelessWidget {
  const SwitchThemeMode({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: App.themeNotifier,
      builder: (_, theme, __) {
        return SwitchListTile(
          controlAffinity: ListTileControlAffinity.trailing,
          secondary: const Icon(Icons.brightness_6_outlined),
          title: Text(AppLocalizations.of(context)!.theme),
          value: theme == ThemeMode.dark,
          thumbIcon: MaterialStateProperty.resolveWith((Set states) => states.contains(MaterialState.selected) ? const Icon(Icons.dark_mode, color: Colors.white) : const Icon(Icons.light_mode, color: Colors.white)),
          thumbColor: MaterialStateProperty.resolveWith((Set states) => states.contains(MaterialState.selected) ? Colors.indigo[900] : Colors.amber[900]),
          trackOutlineColor: MaterialStateProperty.resolveWith((Set states) => Colors.grey),
          trackColor: MaterialStateProperty.resolveWith((Set states) => states.contains(MaterialState.selected) ? Colors.indigo[900]?.withOpacity(0.3) : Colors.amber[900]?.withOpacity(0.3)),
          onChanged: (bool value) => App.themeNotifier.changeAndSave(value ? ThemeMode.dark : ThemeMode.light),
        );
      },
    );
  }
}
