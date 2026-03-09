import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_test_app/main.dart';
import 'package:flutter_test_app/settings_screen.dart';
import 'package:flutter_test_app/theme_notifier.dart';

Future<Widget> buildTestApp({bool isDark = false}) async {
  SharedPreferences.setMockInitialValues(
    <String, Object>{'theme_mode_is_dark': isDark},
  );
  final prefs = await SharedPreferences.getInstance();
  final themeNotifier = ThemeNotifier(prefs: prefs);
  return MyApp(themeNotifier: themeNotifier);
}

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(await buildTestApp());

    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('Counter resets to zero', (WidgetTester tester) async {
    await tester.pumpWidget(await buildTestApp());

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('3'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();

    expect(find.text('0'), findsOneWidget);
    expect(find.text('3'), findsNothing);
  });

  testWidgets('Settings icon navigates to SettingsScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(await buildTestApp());

    expect(find.byIcon(Icons.settings), findsOneWidget);

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Dark Mode'), findsOneWidget);
  });

  testWidgets('Dark mode toggle switches theme', (WidgetTester tester) async {
    await tester.pumpWidget(await buildTestApp());

    // Navigate to settings
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    // Verify dark mode is off (light_mode icon visible)
    expect(find.byIcon(Icons.light_mode), findsOneWidget);

    // Toggle dark mode on
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    // Verify dark mode is now on (dark_mode icon visible)
    expect(find.byIcon(Icons.dark_mode), findsOneWidget);
  });

  testWidgets('App starts in dark mode when preference is saved',
      (WidgetTester tester) async {
    await tester.pumpWidget(await buildTestApp(isDark: true));

    // Navigate to settings
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    // Verify dark mode icon is shown
    expect(find.byIcon(Icons.dark_mode), findsOneWidget);
  });
}
