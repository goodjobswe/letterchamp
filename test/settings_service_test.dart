import 'package:flutter_test/flutter_test.dart';
import 'package:letterchamp/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('first launch uses the expected game and audio defaults', () async {
    final settings = SettingsService();
    expect(await settings.getLanguage(), 'sv');
    expect(await settings.getGameMode(), 'random');
    expect(await settings.getLetterOrder(), 'random');
    expect(await settings.getMusicEnabled(), isTrue);
    expect(await settings.getSoundEffectsEnabled(), isTrue);
    expect(await settings.getNumbersEnabled(), isFalse);
    expect(await settings.getHighScore(), 0);
    expect(await settings.getHighestStreak(), 0);
  });

  test('settings and records survive creating a new service', () async {
    final settings = SettingsService();
    await settings.init();
    await settings.setLanguage('en');
    await settings.setGameMode('lowercase');
    await settings.setLetterOrder('alphabetic');
    await settings.setMusicEnabled(false);
    await settings.setSoundEffectsEnabled(false);
    await settings.setNumbersEnabled(true);
    await settings.setHighScore(125);
    await settings.setHighestStreak(8);
    final reloaded = SettingsService();
    expect(await reloaded.getLanguage(), 'en');
    expect(await reloaded.getGameMode(), 'lowercase');
    expect(await reloaded.getLetterOrder(), 'alphabetic');
    expect(await reloaded.getMusicEnabled(), isFalse);
    expect(await reloaded.getSoundEffectsEnabled(), isFalse);
    expect(await reloaded.getNumbersEnabled(), isTrue);
    expect(await reloaded.getHighScore(), 125);
    expect(await reloaded.getHighestStreak(), 8);
  });

  test('resetting records preserves player preferences', () async {
    final settings = SettingsService();
    await settings.setHighScore(125);
    await settings.setHighestStreak(8);
    await settings.setLanguage('en');
    await settings.setMusicEnabled(false);
    await settings.resetHighScore();
    await settings.resetHighestStreak();
    expect(await settings.getHighScore(), 0);
    expect(await settings.getHighestStreak(), 0);
    expect(await settings.getLanguage(), 'en');
    expect(await settings.getMusicEnabled(), isFalse);
  });
}
