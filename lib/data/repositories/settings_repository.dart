import '../models/user_settings.dart';
import '../../core/database/database_helper.dart';

class SettingsRepository {
  final DatabaseHelper _db;

  SettingsRepository({DatabaseHelper? db}) : _db = db ?? DatabaseHelper.instance;

  Future<UserSettings> getSettings() => _db.getUserSettings();

  Future<void> saveSettings(UserSettings settings) => _db.saveUserSettings(settings);
}
