import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mesh_market/core/config.dart';
import 'package:mesh_market/i18n/strings.g.dart';
import 'package:mesh_market/state/app_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('loads saved locale before the app starts', () async {
    SharedPreferences.setMockInitialValues({
      'app_config': jsonEncode({'localeCode': 'ru'}),
    });
    LocaleSettings.setLocaleRawSync('en');

    final config = await loadInitialConfig();

    expect(config.localeCode, 'ru');
    expect(LocaleSettings.currentLocale, AppLocale.ru);
  });

  test('migrates legacy daily schedule window', () {
    final config = AppConfig.fromJson({
      'syncNow': false,
      'scheduleEnabled': true,
      'scheduleStart': 23 * 60 + 30,
      'scheduleEnd': 30,
    });

    expect(config.scheduleTimes, [23 * 60 + 30]);
    expect(config.scheduleWindowMinutes, 60);
  });
}
