import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _languageKey = 'language';
  static const String _gameModeKey = 'gameMode';
  static const String _letterOrderKey = 'letterOrder';
  static const String _highScoreKey = 'highScore';
  static const String _highestStreakKey = 'highestStreak'; // New key for streak

  // New keys for audio settings.
  static const String _musicEnabledKey = 'musicEnabled';
  static const String _soundEffectsEnabledKey = 'soundEffectsEnabled';

  SharedPreferences? _prefs;

  /// Initializes the SharedPreferences instance.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Retrieves the language setting. Defaults to 'sv' (Swedish).
  Future<String> getLanguage() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getString(_languageKey) ?? 'sv';
  }

  /// Sets the language setting.
  Future<void> setLanguage(String language) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString(_languageKey, language);
  }

  /// Retrieves the game mode. Defaults to 'random'.
  Future<String> getGameMode() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getString(_gameModeKey) ?? 'random';
  }

  /// Sets the game mode.
  Future<void> setGameMode(String gameMode) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString(_gameModeKey, gameMode);
  }

  /// Retrieves the letter order. Defaults to 'random'.
  Future<String> getLetterOrder() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getString(_letterOrderKey) ?? 'random';
  }

  /// Sets the letter order.
  Future<void> setLetterOrder(String letterOrder) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString(_letterOrderKey, letterOrder);
  }

  /// Retrieves the high score. Defaults to 0.
  Future<int> getHighScore() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getInt(_highScoreKey) ?? 0;
  }

  /// Sets the high score.
  Future<void> setHighScore(int highScore) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setInt(_highScoreKey, highScore);
  }

  /// Resets the high score to 0.
  Future<void> resetHighScore() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setInt(_highScoreKey, 0);
  }

  /// Retrieves the highest streak. Defaults to 0.
  Future<int> getHighestStreak() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getInt(_highestStreakKey) ?? 0;
  }

  /// Sets the highest streak.
  Future<void> setHighestStreak(int streak) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setInt(_highestStreakKey, streak);
  }

  /// Resets the highest streak to 0.
  Future<void> resetHighestStreak() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setInt(_highestStreakKey, 0);
  }

  /// Retrieves whether music is enabled. Defaults to true.
  Future<bool> getMusicEnabled() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getBool(_musicEnabledKey) ?? true;
  }

  /// Sets whether music is enabled.
  Future<void> setMusicEnabled(bool enabled) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setBool(_musicEnabledKey, enabled);
  }

  /// Retrieves whether sound effects are enabled. Defaults to true.
  Future<bool> getSoundEffectsEnabled() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getBool(_soundEffectsEnabledKey) ?? true;
  }

  /// Sets whether sound effects are enabled.
  Future<void> setSoundEffectsEnabled(bool enabled) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setBool(_soundEffectsEnabledKey, enabled);
  }
}
