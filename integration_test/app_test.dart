// E2E тесты для Flutter Counter App с переключением тёмной темы.
// Тесты запускаются на iOS и Android через `flutter test integration_test/`.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_test_app/main.dart';
import 'package:flutter_test_app/settings_screen.dart';
import 'package:flutter_test_app/theme_notifier.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// Вспомогательная функция для создания приложения с начальными настройками.
  Future<Widget> buildTestApp({bool isDark = false}) async {
    SharedPreferences.setMockInitialValues(
      <String, Object>{'theme_mode_is_dark': isDark},
    );
    final prefs = await SharedPreferences.getInstance();
    final themeNotifier = ThemeNotifier(prefs: prefs);
    return MyApp(themeNotifier: themeNotifier);
  }

  // ---------------------------------------------------------------------------
  // SC-041 / SC-042: Наличие и расположение кнопок Increment и Reset
  // ---------------------------------------------------------------------------
  testWidgets('SC-041/042: Кнопки Increment и Reset присутствуют на главном экране',
      (WidgetTester tester) async {
    await tester.pumpWidget(await buildTestApp());
    await tester.pumpAndSettle();

    // Проверяем наличие обеих FAB-кнопок
    final resetButton = find.byKey(const Key('reset_button'));
    final incrementButton = find.byKey(const Key('increment_button'));

    expect(resetButton, findsOneWidget);
    expect(incrementButton, findsOneWidget);

    // Проверяем начальное значение счётчика
    final counterText = find.byKey(const Key('counter_text'));
    expect(counterText, findsOneWidget);

    final textWidget = tester.widget<Text>(counterText);
    expect(textWidget.data, '0');

    // Проверяем наличие кнопки Settings в AppBar
    expect(find.byKey(const Key('settings_button')), findsOneWidget);
  });

  // ---------------------------------------------------------------------------
  // SC-043 / SC-046: Инкремент счётчика кнопкой "+"
  // ---------------------------------------------------------------------------
  testWidgets('SC-043/046: Инкремент счётчика кнопкой "+"',
      (WidgetTester tester) async {
    await tester.pumpWidget(await buildTestApp());
    await tester.pumpAndSettle();

    // Нажимаем кнопку "+"
    await tester.tap(find.byKey(const Key('increment_button')));
    await tester.pumpAndSettle();

    // Проверяем, что счётчик = 1
    final counterText = tester.widget<Text>(find.byKey(const Key('counter_text')));
    expect(counterText.data, '1');
  });

  // ---------------------------------------------------------------------------
  // SC-044 / SC-047: Сброс счётчика кнопкой Reset после инкремента
  // ---------------------------------------------------------------------------
  testWidgets('SC-044/047: Сброс счётчика кнопкой Reset после инкремента',
      (WidgetTester tester) async {
    await tester.pumpWidget(await buildTestApp());
    await tester.pumpAndSettle();

    // Инкрементируем 3 раза
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byKey(const Key('increment_button')));
      await tester.pumpAndSettle();
    }

    // Проверяем счётчик = 3
    var counterText = tester.widget<Text>(find.byKey(const Key('counter_text')));
    expect(counterText.data, '3');

    // Нажимаем Reset
    await tester.tap(find.byKey(const Key('reset_button')));
    await tester.pumpAndSettle();

    // Проверяем счётчик = 0
    counterText = tester.widget<Text>(find.byKey(const Key('counter_text')));
    expect(counterText.data, '0');
  });

  // ---------------------------------------------------------------------------
  // SC-045: Нажатие Reset при нулевом значении счётчика
  // ---------------------------------------------------------------------------
  testWidgets('SC-045: Reset при нулевом счётчике не вызывает ошибок',
      (WidgetTester tester) async {
    await tester.pumpWidget(await buildTestApp());
    await tester.pumpAndSettle();

    // Счётчик = 0
    var counterText = tester.widget<Text>(find.byKey(const Key('counter_text')));
    expect(counterText.data, '0');

    // Нажимаем Reset при нулевом значении
    await tester.tap(find.byKey(const Key('reset_button')));
    await tester.pumpAndSettle();

    // Счётчик по-прежнему = 0, приложение не упало
    counterText = tester.widget<Text>(find.byKey(const Key('counter_text')));
    expect(counterText.data, '0');
  });

  // ---------------------------------------------------------------------------
  // SC-048: Быстрое чередование нажатий Increment и Reset (стресс-тест)
  // ---------------------------------------------------------------------------
  testWidgets('SC-048: Быстрое чередование Increment и Reset',
      (WidgetTester tester) async {
    await tester.pumpWidget(await buildTestApp());
    await tester.pumpAndSettle();

    // 10 циклов: increment → reset
    for (var i = 0; i < 10; i++) {
      await tester.tap(find.byKey(const Key('increment_button')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('reset_button')));
      await tester.pump();
    }

    // Финальный reset для гарантии
    await tester.tap(find.byKey(const Key('reset_button')));
    await tester.pumpAndSettle();

    // Счётчик должен быть 0
    final counterText = tester.widget<Text>(find.byKey(const Key('counter_text')));
    expect(counterText.data, '0');
  });

  // ---------------------------------------------------------------------------
  // SC-074 / SC-075: Сохранение тёмной темы (проверка переключения и персистенции)
  // ---------------------------------------------------------------------------
  testWidgets('SC-074/075: Тёмная тема сохраняется после переключения',
      (WidgetTester tester) async {
    await tester.pumpWidget(await buildTestApp());
    await tester.pumpAndSettle();

    // Переходим в Settings
    await tester.tap(find.byKey(const Key('settings_button')));
    await tester.pumpAndSettle();

    // Проверяем, что мы на экране Settings
    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    // Проверяем начальное состояние — светлая тема (иконка light_mode)
    expect(find.byIcon(Icons.light_mode), findsOneWidget);

    // Включаем тёмную тему
    await tester.tap(find.byKey(const Key('dark_mode_toggle')));
    await tester.pumpAndSettle();

    // Проверяем, что тёмная тема активна (иконка dark_mode)
    expect(find.byIcon(Icons.dark_mode), findsOneWidget);
    expect(find.text('Switch to light mode'), findsOneWidget);
  });

  // ---------------------------------------------------------------------------
  // SC-076: Поворот экрана на экране Settings (Android)
  // ---------------------------------------------------------------------------
  testWidgets('SC-076: Поворот экрана сохраняет состояние темы',
      (WidgetTester tester) async {
    await tester.pumpWidget(await buildTestApp());
    await tester.pumpAndSettle();

    // Переходим в Settings
    await tester.tap(find.byKey(const Key('settings_button')));
    await tester.pumpAndSettle();

    // Включаем тёмную тему
    await tester.tap(find.byKey(const Key('dark_mode_toggle')));
    await tester.pumpAndSettle();

    // Проверяем, что тёмная тема активна
    expect(find.byIcon(Icons.dark_mode), findsOneWidget);

    // Поворачиваем экран в landscape
    await tester.binding.setSurfaceSize(const Size(800, 400));
    await tester.pumpAndSettle();

    // Проверяем, что тёмная тема сохранилась после поворота
    expect(find.text('Dark Mode'), findsOneWidget);
    expect(find.byIcon(Icons.dark_mode), findsOneWidget);

    // Выключаем тёмную тему в landscape
    await tester.tap(find.byKey(const Key('dark_mode_toggle')));
    await tester.pumpAndSettle();

    // Проверяем переключение на светлую тему
    expect(find.byIcon(Icons.light_mode), findsOneWidget);

    // Возвращаем portrait
    await tester.binding.setSurfaceSize(const Size(400, 800));
    await tester.pumpAndSettle();

    // Проверяем, что светлая тема сохранилась
    expect(find.byIcon(Icons.light_mode), findsOneWidget);
  });

  // ---------------------------------------------------------------------------
  // SC-077: Навигация назад с экрана Settings сохраняет тему и счётчик
  // ---------------------------------------------------------------------------
  testWidgets('SC-077: Возврат с Settings сохраняет тему и счётчик',
      (WidgetTester tester) async {
    await tester.pumpWidget(await buildTestApp());
    await tester.pumpAndSettle();

    // Инкрементируем счётчик 3 раза
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byKey(const Key('increment_button')));
      await tester.pumpAndSettle();
    }

    // Проверяем счётчик = 3
    var counterText = tester.widget<Text>(find.byKey(const Key('counter_text')));
    expect(counterText.data, '3');

    // Переходим в Settings
    await tester.tap(find.byKey(const Key('settings_button')));
    await tester.pumpAndSettle();

    // Включаем тёмную тему
    await tester.tap(find.byKey(const Key('dark_mode_toggle')));
    await tester.pumpAndSettle();

    // Возвращаемся назад (Navigator.pop)
    final backButton = find.byType(BackButton);
    if (backButton.evaluate().isNotEmpty) {
      await tester.tap(backButton);
    } else {
      // Используем системную навигацию назад
      final NavigatorState navigator = tester.state(find.byType(Navigator).last);
      navigator.pop();
    }
    await tester.pumpAndSettle();

    // Проверяем, что мы вернулись на главный экран
    expect(find.byKey(const Key('counter_text')), findsOneWidget);

    // Проверяем, что счётчик сохранился = 3
    counterText = tester.widget<Text>(find.byKey(const Key('counter_text')));
    expect(counterText.data, '3');

    // Проверяем, что тёмная тема применена (MaterialApp использует darkTheme)
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, ThemeMode.dark);
  });

  // ---------------------------------------------------------------------------
  // SC-011/012/013/014: Запуск приложения — проверка начального состояния
  // ---------------------------------------------------------------------------
  testWidgets('SC-011-014: Приложение запускается с корректным начальным состоянием',
      (WidgetTester tester) async {
    await tester.pumpWidget(await buildTestApp());
    await tester.pumpAndSettle();

    // Проверяем заголовок AppBar
    expect(find.text('Flutter Demo Home Page'), findsOneWidget);

    // Проверяем начальное значение счётчика
    final counterText = tester.widget<Text>(find.byKey(const Key('counter_text')));
    expect(counterText.data, '0');

    // Проверяем текст подсказки
    expect(find.text('You have pushed the button this many times:'), findsOneWidget);

    // Проверяем наличие всех интерактивных элементов
    expect(find.byKey(const Key('settings_button')), findsOneWidget);
    expect(find.byKey(const Key('reset_button')), findsOneWidget);
    expect(find.byKey(const Key('increment_button')), findsOneWidget);
  });

  // ---------------------------------------------------------------------------
  // SC-015: Приложение запускается в сохранённой тёмной теме
  // ---------------------------------------------------------------------------
  testWidgets('SC-015: Приложение стартует в тёмной теме при сохранённом preference',
      (WidgetTester tester) async {
    // Запускаем с isDark = true (сохранённое предпочтение)
    await tester.pumpWidget(await buildTestApp(isDark: true));
    await tester.pumpAndSettle();

    // Проверяем, что MaterialApp использует тёмную тему
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, ThemeMode.dark);

    // Переходим в Settings и проверяем состояние переключателя
    await tester.tap(find.byKey(const Key('settings_button')));
    await tester.pumpAndSettle();

    // Проверяем, что иконка dark_mode отображается
    expect(find.byIcon(Icons.dark_mode), findsOneWidget);
    expect(find.text('Switch to light mode'), findsOneWidget);
  });
}
