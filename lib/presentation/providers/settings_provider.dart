import 'package:flutter/material.dart';
import '../../data/models/user_settings.dart';
import '../../data/repositories/settings_repository.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsRepository _repo;
  UserSettings _settings = const UserSettings();
  bool _isLoading = true;

  SettingsProvider({SettingsRepository? repo}) : _repo = repo ?? SettingsRepository() {
    _loadSettings();
  }

  UserSettings get settings => _settings;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _settings.isDarkMode;
  double get fontScale => _settings.fontScale;
  ScriptDisplayMode get scriptMode => _settings.scriptMode;
  int get dailyTargetVerses => _settings.dailyTargetVerses;
  bool get reminderEnabled => _settings.reminderEnabled;
  bool get showAmharicReference => _settings.showAmharicReference;
  bool get showEnglishReference => _settings.showEnglishReference;

  TimeOfDay get reminderTime => TimeOfDay(
        hour: _settings.reminderHour,
        minute: _settings.reminderMinute,
      );

  Future<void> _loadSettings() async {
    _settings = await _repo.getSettings();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool isDark) async {
    _settings = _settings.copyWith(isDarkMode: isDark);
    notifyListeners();
    await _repo.saveSettings(_settings);
  }

  Future<void> setFontScale(double scale) async {
    _settings = _settings.copyWith(fontScale: scale.clamp(0.85, 1.4));
    notifyListeners();
    await _repo.saveSettings(_settings);
  }

  Future<void> setScriptMode(ScriptDisplayMode mode) async {
    _settings = _settings.copyWith(scriptMode: mode);
    notifyListeners();
    await _repo.saveSettings(_settings);
  }

  Future<void> toggleAmharicReference(bool show) async {
    _settings = _settings.copyWith(showAmharicReference: show);
    notifyListeners();
    await _repo.saveSettings(_settings);
  }

  Future<void> toggleEnglishReference(bool show) async {
    _settings = _settings.copyWith(showEnglishReference: show);
    notifyListeners();
    await _repo.saveSettings(_settings);
  }

  Future<void> setDailyTarget(int target) async {
    _settings = _settings.copyWith(dailyTargetVerses: target);
    notifyListeners();
    await _repo.saveSettings(_settings);
  }

  Future<void> setReminder({required bool enabled, TimeOfDay? time}) async {
    _settings = _settings.copyWith(
      reminderEnabled: enabled,
      reminderHour: time?.hour ?? _settings.reminderHour,
      reminderMinute: time?.minute ?? _settings.reminderMinute,
    );
    notifyListeners();
    await _repo.saveSettings(_settings);
  }
}
