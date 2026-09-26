import 'package:flutter/material.dart';
import 'package:letterchamp/services/settings_service.dart';
import 'package:letterchamp/services/sound_effects_manager.dart';
import 'package:letterchamp/theme/retro_theme.dart';
import 'package:letterchamp/theme/retro_widgets.dart';

class HighscoreScreen extends StatefulWidget {
  const HighscoreScreen({super.key});

  @override
  HighscoreScreenState createState() => HighscoreScreenState();
}

class HighscoreScreenState extends State<HighscoreScreen> {
  String _language = "en"; // default language
  int _highScore = 0;
  int _highestStreak = 0;
  bool _isLoading = true;
  bool _soundEffectsEnabled = false;
  final SettingsService settingsService = SettingsService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Load language, high score, and highest streak.
  Future<void> _loadData() async {
    await settingsService.init();
    final language = await settingsService.getLanguage();
    final highScore = await settingsService.getHighScore();
    final highestStreak = await settingsService.getHighestStreak();
    final soundEffectsEnabled = await settingsService.getSoundEffectsEnabled();
    if (!mounted) return;
    setState(() {
      _language = language;
      _highScore = highScore;
      _highestStreak = highestStreak;
      _isLoading = false;
      _soundEffectsEnabled = soundEffectsEnabled;
    });
  }

  // Resets the high score (and streak) in settings.
  Future<void> _resetHighScore() async {
    await settingsService.resetHighScore();
    await settingsService.resetHighestStreak();
    final highScore = await settingsService.getHighScore();
    final highestStreak = await settingsService.getHighestStreak();
    setState(() {
      _highScore = highScore;
      _highestStreak = highestStreak;
    });
  }

  // Shows a confirmation dialog before resetting the high score and streak.
  void _confirmReset() {
    final confirmTitle = _language == "sv" ? "Bekräfta" : "Confirm";
    final confirmContent =
        _language == "sv"
            ? "Är du säker på att du vill nollställa högsta poäng och flest rätt i rad?"
            : "Are you sure you want to reset the high score and streak?";
    final cancelText = _language == "sv" ? "Avbryt" : "Cancel";
    final confirmText = _language == "sv" ? "Ja" : "Yes";

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: RetroColors.ink,
            shape: RetroBox.dialogShape,
            title: Text(confirmTitle, style: _headerTextStyle(18)),
            content: Text(confirmContent, style: _headerTextStyle(16)),
            actions: [
              TextButton(
                onPressed: () {
                  if (_soundEffectsEnabled) {
                    SoundEffectsManager().playEffect('audio/cancel.wav');
                  }
                  Navigator.of(context).pop();
                },
                child: Text(cancelText, style: _headerTextStyle(12)),
              ),
              TextButton(
                onPressed: () async {
                  if (_soundEffectsEnabled) {
                    SoundEffectsManager().playEffect('audio/button_click.wav');
                  }
                  Navigator.of(context).pop();
                  await _resetHighScore();
                },
                child: Text(confirmText, style: _headerTextStyle(12)),
              ),
            ],
          ),
    );
  }

  TextStyle _headerTextStyle(double size) {
    return RetroText.style(size);
  }

  // Common button decoration for consistency.
  Widget _buildMenuButton(String text, VoidCallback onPressed) {
    return RetroButton(label: text, onPressed: onPressed);
  }

  // Button style for the reset button.
  Widget _buildResetButton(String text, VoidCallback onPressed) {
    return RetroButton(label: text, onPressed: onPressed, primary: false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: RetroBackground(child: Center(child: RetroLoader())),
      );
    }

    final String titleText = _language == "sv" ? "Högsta poäng" : "High Scores";
    final String highScoreLabel =
        _language == "sv" ? "Högsta poäng" : "High Score";
    final String streakLabel =
        _language == "sv" ? "Flest rätt i rad" : "Longest Streak";
    final String mainMenuText = _language == "sv" ? "Huvudmeny" : "Main Menu";
    final String resetText = _language == "sv" ? "Nollställ" : "Reset";

    return Scaffold(
      body: RetroBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                // Transparent AppBar with back button.
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: RetroIconButton(
                    glyph: PixelGlyph.arrowLeft,
                    onPressed: () {
                      if (_soundEffectsEnabled) {
                        SoundEffectsManager().playEffect(
                          'audio/button_click.wav',
                        );
                      }
                      Navigator.pop(context);
                    },
                    tooltip: _language == "sv" ? "Huvudmeny" : "Main Menu",
                  ),
                  centerTitle: true,
                  title: Text(titleText, style: _headerTextStyle(16)),
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
                            // High Score display.
                            Text(highScoreLabel, style: _headerTextStyle(20)),
                            Text(
                              _highScore.toString(),
                              style: _headerTextStyle(28),
                            ),
                            const SizedBox(height: 20),
                            // Highest Streak display.
                            Text(streakLabel, style: _headerTextStyle(20)),
                            Text(
                              _highestStreak.toString(),
                              style: _headerTextStyle(28),
                            ),
                            const SizedBox(height: 36),
                            // Main Menu Button.
                            _buildMenuButton(mainMenuText, () {
                              if (_soundEffectsEnabled) {
                                SoundEffectsManager().playEffect(
                                  'audio/button_click.wav',
                                );
                              }
                              Navigator.pop(context);
                            }),
                            const SizedBox(height: 15),
                            // Reset Button.
                            _buildResetButton(resetText, () {
                              if (_soundEffectsEnabled) {
                                SoundEffectsManager().playEffect(
                                  'audio/button_click.wav',
                                );
                              }
                              _confirmReset();
                            }),
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
