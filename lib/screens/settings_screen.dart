import 'package:flutter/material.dart';
import 'package:letterchamp/services/music_manager.dart';
import 'package:letterchamp/services/settings_service.dart';
import 'package:letterchamp/services/sound_effects_manager.dart';
import 'package:letterchamp/theme/retro_theme.dart';
import 'package:letterchamp/theme/retro_widgets.dart';

/// Language, which letters to practice, their order, sound and numbers.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService();

  bool _loading = true;
  String _language = 'en';
  String _gameMode = 'random';
  String _letterOrder = 'alphabetic';
  bool _musicEnabled = true;
  bool _soundEffectsEnabled = true;
  bool _numbersEnabled = false;

  bool get _swedish => _language == 'sv';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final String language = await _settingsService.getLanguage();
    final String gameMode = await _settingsService.getGameMode();
    final String letterOrder = await _settingsService.getLetterOrder();
    final bool musicEnabled = await _settingsService.getMusicEnabled();
    final bool soundEffectsEnabled =
        await _settingsService.getSoundEffectsEnabled();
    final bool numbersEnabled = await _settingsService.getNumbersEnabled();
    if (!mounted) return;
    setState(() {
      _language = language;
      _gameMode = gameMode;
      _letterOrder = letterOrder;
      _musicEnabled = musicEnabled;
      _soundEffectsEnabled = soundEffectsEnabled;
      _numbersEnabled = numbersEnabled;
      _loading = false;
    });
  }

  Future<void> _updateLanguage(String? language) async {
    if (language == null) return;
    await _settingsService.setLanguage(language);
    if (!mounted) return;
    setState(() => _language = language);
  }

  Future<void> _updateGameMode(String? gameMode) async {
    if (gameMode == null) return;
    await _settingsService.setGameMode(gameMode);
    if (!mounted) return;
    setState(() => _gameMode = gameMode);
  }

  Future<void> _updateLetterOrder(String? letterOrder) async {
    if (letterOrder == null) return;
    await _settingsService.setLetterOrder(letterOrder);
    if (!mounted) return;
    setState(() => _letterOrder = letterOrder);
  }

  Future<void> _updateMusicEnabled(bool enabled) async {
    await _settingsService.setMusicEnabled(enabled);
    if (enabled) {
      MusicManager().play();
    } else {
      MusicManager().stop();
    }
    if (!mounted) return;
    setState(() => _musicEnabled = enabled);
  }

  Future<void> _updateSoundEffectsEnabled(bool enabled) async {
    await _settingsService.setSoundEffectsEnabled(enabled);
    SoundEffectsManager().enabled = enabled;
    if (!mounted) return;
    setState(() => _soundEffectsEnabled = enabled);
  }

  Future<void> _updateNumbersEnabled(bool enabled) async {
    await _settingsService.setNumbersEnabled(enabled);
    if (!mounted) return;
    setState(() => _numbersEnabled = enabled);
  }

  TextStyle get _labelStyle => RetroText.style(18);

  /// A setting shown as a switch with its label on the left.
  Widget _toggleRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: _labelStyle),
        RetroToggle(value: value, onChanged: onChanged),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final String mainMenuText = _swedish ? 'Huvudmeny' : 'Main Menu';

    return Scaffold(
      body: RetroBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: RetroIconButton(
                    glyph: PixelGlyph.arrowLeft,
                    tooltip: mainMenuText,
                    onPressed: () {
                      SoundEffectsManager().play(SoundEffect.click);
                      Navigator.pop(context);
                    },
                  ),
                  centerTitle: true,
                  title: Text(
                    _swedish ? 'Inställningar' : 'Settings',
                    style: RetroText.style(16),
                  ),
                ),
                Expanded(
                  child:
                      _loading
                          ? const Center(child: RetroLoader())
                          : SingleChildScrollView(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                // Everything the status bar, toolbar and
                                // system navigation leave over, so nothing
                                // scrolls unless the content is taller than
                                // the screen.
                                minHeight:
                                    MediaQuery.of(context).size.height -
                                    kToolbarHeight -
                                    MediaQuery.of(context).padding.vertical,
                              ),
                              child: IntrinsicHeight(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      _swedish ? 'Språk' : 'Language',
                                      style: _labelStyle,
                                    ),
                                    const SizedBox(height: 8),
                                    RetroChoice<String>(
                                      value: _language,
                                      // Language names stay in their own
                                      // language so anyone can find theirs.
                                      options: const [
                                        RetroOption('en', 'English'),
                                        RetroOption('sv', 'Svenska'),
                                      ],
                                      onChanged: _updateLanguage,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _swedish ? 'Bokstäver' : 'Letters',
                                      style: _labelStyle,
                                    ),
                                    const SizedBox(height: 8),
                                    RetroChoice<String>(
                                      value: _gameMode,
                                      options: [
                                        RetroOption(
                                          'uppercase',
                                          _swedish
                                              ? 'Bara stora'
                                              : 'Uppercase only',
                                        ),
                                        RetroOption(
                                          'lowercase',
                                          _swedish
                                              ? 'Bara små'
                                              : 'Lowercase only',
                                        ),
                                        RetroOption(
                                          'random',
                                          _swedish ? 'Stora och små' : 'Both',
                                        ),
                                      ],
                                      onChanged: _updateGameMode,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _swedish
                                          ? 'Bokstavsordning'
                                          : 'Letter Order',
                                      style: _labelStyle,
                                    ),
                                    const SizedBox(height: 8),
                                    RetroChoice<String>(
                                      value: _letterOrder,
                                      options: [
                                        // The pixel font has no room for a
                                        // full-height Ö, so not "A till Ö".
                                        RetroOption(
                                          'alphabetic',
                                          _swedish ? 'Alfabetisk' : 'A to Z',
                                        ),
                                        RetroOption(
                                          'random',
                                          _swedish ? 'Slumpmässig' : 'Shuffled',
                                        ),
                                      ],
                                      onChanged: _updateLetterOrder,
                                    ),
                                    const SizedBox(height: 32),
                                    _toggleRow(
                                      _swedish ? 'Musik' : 'Music',
                                      _musicEnabled,
                                      _updateMusicEnabled,
                                    ),
                                    const SizedBox(height: 16),
                                    _toggleRow(
                                      _swedish
                                          ? 'Ljudeffekter'
                                          : 'Sound Effects',
                                      _soundEffectsEnabled,
                                      _updateSoundEffectsEnabled,
                                    ),
                                    const SizedBox(height: 16),
                                    _toggleRow(
                                      _swedish ? 'Siffror' : 'Numbers',
                                      _numbersEnabled,
                                      _updateNumbersEnabled,
                                    ),
                                    const SizedBox(height: 32),
                                    Center(
                                      child: RetroButton(
                                        label: mainMenuText,
                                        onPressed: () {
                                          SoundEffectsManager().play(
                                            SoundEffect.click,
                                          );
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    // Wording required by the music's license.
                                    Text(
                                      'Credit: https://www.FesliyanStudios.com Background Music',
                                      style: RetroText.style(
                                        10,
                                        color: RetroColors.mist,
                                        shadow: false,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              ),
                            ),
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
