import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _languageKey = 'language';
  static const String _gameModeKey = 'gameMode';
  static const String _letterOrderKey = 'letterOrder';
  static const String _highScoreKey = 'highScore';

  // Retrieves the language setting. Defaults to 'en' (English).
  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'en';
  }

  // Sets the language setting.
  Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }

  // Retrieves the game mode. Defaults to 'random'.
  Future<String> getGameMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_gameModeKey) ?? 'random';
  }

  // Sets the game mode.
  Future<void> setGameMode(String gameMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_gameModeKey, gameMode);
  }

  // Retrieves the letter order. Defaults to 'alphabetic'.
  Future<String> getLetterOrder() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_letterOrderKey) ?? 'alphabetic';
  }

  // Sets the letter order.
  Future<void> setLetterOrder(String letterOrder) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_letterOrderKey, letterOrder);
  }

  // Retrieves the high score. Defaults to 0.
  Future<int> getHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_highScoreKey) ?? 0;
  }

  // Resets the high score to 0.
  Future<void> resetHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_highScoreKey, 0);
  }

  // Sets the high score.
  Future<void> setHighScore(int highScore) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_highScoreKey, highScore);
  }

}
