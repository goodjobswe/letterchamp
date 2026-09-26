import 'package:shared_preferences/shared_preferences.dart';

/// Saved settings and records, kept on the device with SharedPreferences.
///
/// Game modes are 'uppercase', 'lowercase' or 'random' (both cases mixed);
/// letter orders are 'alphabetic' or 'random'; languages are 'en' or 'sv'.
class SettingsService {
  static const String _languageKey = 'language';
  static const String _gameModeKey = 'gameMode';
  static const String _letterOrderKey = 'letterOrder';
  static const String _highScoreKey = 'highScore';
  static const String _highestStreakKey = 'highestStreak';
  static const String _musicEnabledKey = 'musicEnabled';
  static const String _soundEffectsEnabledKey = 'soundEffectsEnabled';
  static const String _numbersEnabledKey = 'numbersEnabled';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async =>
      _prefs ??= await SharedPreferences.getInstance();

  /// Opens the store ahead of the first read. Every read and write opens it
  /// on demand, so calling this is optional.
  Future<void> init() async {
    await _preferences;
  }

  Future<String> getLanguage() async =>
      (await _preferences).getString(_languageKey) ?? 'en';

  Future<void> setLanguage(String language) async {
    await (await _preferences).setString(_languageKey, language);
  }

  Future<String> getGameMode() async =>
      (await _preferences).getString(_gameModeKey) ?? 'random';

  Future<void> setGameMode(String gameMode) async {
    await (await _preferences).setString(_gameModeKey, gameMode);
  }

  Future<String> getLetterOrder() async =>
      (await _preferences).getString(_letterOrderKey) ?? 'random';

  Future<void> setLetterOrder(String letterOrder) async {
    await (await _preferences).setString(_letterOrderKey, letterOrder);
  }

  Future<int> getHighScore() async =>
      (await _preferences).getInt(_highScoreKey) ?? 0;

  Future<void> setHighScore(int highScore) async {
    await (await _preferences).setInt(_highScoreKey, highScore);
  }

  Future<void> resetHighScore() => setHighScore(0);

  Future<int> getHighestStreak() async =>
      (await _preferences).getInt(_highestStreakKey) ?? 0;

  Future<void> setHighestStreak(int streak) async {
    await (await _preferences).setInt(_highestStreakKey, streak);
  }

  Future<void> resetHighestStreak() => setHighestStreak(0);

  Future<bool> getMusicEnabled() async =>
      (await _preferences).getBool(_musicEnabledKey) ?? true;

  Future<void> setMusicEnabled(bool enabled) async {
    await (await _preferences).setBool(_musicEnabledKey, enabled);
  }

  Future<bool> getSoundEffectsEnabled() async =>
      (await _preferences).getBool(_soundEffectsEnabledKey) ?? true;

  Future<void> setSoundEffectsEnabled(bool enabled) async {
    await (await _preferences).setBool(_soundEffectsEnabledKey, enabled);
  }

  Future<bool> getNumbersEnabled() async =>
      (await _preferences).getBool(_numbersEnabledKey) ?? false;

  Future<void> setNumbersEnabled(bool enabled) async {
    await (await _preferences).setBool(_numbersEnabledKey, enabled);
  }
}
