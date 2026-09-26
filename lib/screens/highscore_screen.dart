import 'package:flutter/material.dart';
import 'package:letterchamp/services/settings_service.dart';
import 'package:letterchamp/services/sound_effects_manager.dart';
import 'package:letterchamp/theme/retro_theme.dart';
import 'package:letterchamp/theme/retro_widgets.dart';

/// Shows the best score and the longest streak, with a way to reset both.
class HighscoreScreen extends StatefulWidget {
  const HighscoreScreen({super.key});

  @override
  State<HighscoreScreen> createState() => _HighscoreScreenState();
}

class _HighscoreScreenState extends State<HighscoreScreen> {
  final SettingsService _settingsService = SettingsService();

  bool _loading = true;
  String _language = 'en';
  int _highScore = 0;
  int _longestStreak = 0;

  bool get _swedish => _language == 'sv';

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final String language = await _settingsService.getLanguage();
    final int highScore = await _settingsService.getHighScore();
    final int longestStreak = await _settingsService.getHighestStreak();
    SoundEffectsManager().enabled =
        await _settingsService.getSoundEffectsEnabled();
    if (!mounted) return;
    setState(() {
      _language = language;
      _highScore = highScore;
      _longestStreak = longestStreak;
      _loading = false;
    });
  }

  Future<void> _resetRecords() async {
    await _settingsService.resetHighScore();
    await _settingsService.resetHighestStreak();
    if (!mounted) return;
    setState(() {
      _highScore = 0;
      _longestStreak = 0;
    });
  }

  void _confirmReset() {
    showDialog<void>(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            backgroundColor: RetroColors.ink,
            shape: RetroBox.dialogShape,
            title: Text(
              _swedish ? 'Bekräfta' : 'Confirm',
              style: RetroText.style(18),
            ),
            content: Text(
              _swedish
                  ? 'Är du säker på att du vill nollställa högsta poäng och flest rätt i rad?'
                  : 'Are you sure you want to reset the high score and streak?',
              style: RetroText.style(16),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  SoundEffectsManager().play(SoundEffect.cancel);
                  Navigator.of(context).pop();
                },
                child: Text(
                  _swedish ? 'Avbryt' : 'Cancel',
                  style: RetroText.style(12),
                ),
              ),
              TextButton(
                onPressed: () {
                  SoundEffectsManager().play(SoundEffect.click);
                  Navigator.of(context).pop();
                  _resetRecords();
                },
                child: Text(
                  _swedish ? 'Ja' : 'Yes',
                  style: RetroText.style(12),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: RetroBackground(child: Center(child: RetroLoader())),
      );
    }

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
                    _swedish ? 'Högsta poäng' : 'High Scores',
                    style: RetroText.style(16),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        // Everything the status bar, toolbar and system
                        // navigation leave over, so nothing scrolls unless
                        // the content is taller than the screen.
                        minHeight:
                            MediaQuery.of(context).size.height -
                            kToolbarHeight -
                            MediaQuery.of(context).padding.vertical,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _swedish ? 'Högsta poäng' : 'High Score',
                              style: RetroText.style(20),
                            ),
                            Text('$_highScore', style: RetroText.style(28)),
                            const SizedBox(height: 20),
                            Text(
                              _swedish ? 'Flest rätt i rad' : 'Longest Streak',
                              style: RetroText.style(20),
                            ),
                            Text('$_longestStreak', style: RetroText.style(28)),
                            const SizedBox(height: 36),
                            RetroButton(
                              label: mainMenuText,
                              onPressed: () {
                                SoundEffectsManager().play(SoundEffect.click);
                                Navigator.pop(context);
                              },
                            ),
                            const SizedBox(height: 15),
                            RetroButton(
                              label: _swedish ? 'Nollställ' : 'Reset',
                              primary: false,
                              onPressed: () {
                                SoundEffectsManager().play(SoundEffect.click);
                                _confirmReset();
                              },
                            ),
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
