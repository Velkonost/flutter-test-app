import 'package:flutter/material.dart';

import 'theme_notifier.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = ThemeNotifierProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          Semantics(
            label: 'Dark mode toggle',
            child: SwitchListTile(
              secondary: Icon(
                themeNotifier.isDarkMode
                    ? Icons.dark_mode
                    : Icons.light_mode,
              ),
              title: const Text('Dark Mode'),
              subtitle: Text(
                themeNotifier.isDarkMode
                    ? 'Switch to light mode'
                    : 'Switch to dark mode',
              ),
              value: themeNotifier.isDarkMode,
              onChanged: (bool value) {
                themeNotifier.toggleTheme(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}
