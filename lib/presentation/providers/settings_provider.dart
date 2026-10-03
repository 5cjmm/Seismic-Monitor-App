import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider que administra las preferencias del usuario mostradas en la
/// pantalla "Ajustes" del mockup, persistidas con SharedPreferences.
class SettingsProvider extends ChangeNotifier {
  static const _keyUnit = 'unit_metric';
  static const _keyNotifications = 'notifications_enabled';
  static const _keyRefreshMinutes = 'refresh_minutes';
  static const _keyDarkTheme = 'dark_theme';
  static const _keyMinMagnitude = 'default_min_magnitude';

  bool metricUnits = true;
  bool notificationsEnabled = true;
  int refreshMinutes = 1;
  bool darkTheme = false;
  double defaultMinMagnitude = 3.0;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    metricUnits = prefs.getBool(_keyUnit) ?? true;
    notificationsEnabled = prefs.getBool(_keyNotifications) ?? true;
    refreshMinutes = prefs.getInt(_keyRefreshMinutes) ?? 1;
    darkTheme = prefs.getBool(_keyDarkTheme) ?? false;
    defaultMinMagnitude = prefs.getDouble(_keyMinMagnitude) ?? 3.0;
    notifyListeners();
  }

  Future<void> toggleUnits() async {
    metricUnits = !metricUnits;
    (await SharedPreferences.getInstance()).setBool(_keyUnit, metricUnits);
    notifyListeners();
  }

  Future<void> toggleNotifications() async {
    notificationsEnabled = !notificationsEnabled;
    (await SharedPreferences.getInstance())
        .setBool(_keyNotifications, notificationsEnabled);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    darkTheme = !darkTheme;
    (await SharedPreferences.getInstance()).setBool(_keyDarkTheme, darkTheme);
    notifyListeners();
  }

  Future<void> setRefreshMinutes(int minutes) async {
    refreshMinutes = minutes;
    (await SharedPreferences.getInstance())
        .setInt(_keyRefreshMinutes, minutes);
    notifyListeners();
  }

  Future<void> setDefaultMinMagnitude(double value) async {
    defaultMinMagnitude = value;
    (await SharedPreferences.getInstance())
        .setDouble(_keyMinMagnitude, value);
    notifyListeners();
  }
}
