import 'package:flutter/material.dart';
import 'package:letterchamp/services/settings_service.dart';
import 'package:letterchamp/services/audio_manager.dart';
import 'package:letterchamp/services/sound_effects_manager.dart';
import 'package:letterchamp/theme/retro_theme.dart';
import 'package:letterchamp/theme/retro_widgets.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  LandingScreenState createState() => LandingScreenState();
}

class LandingScreenState extends State<LandingScreen> {
  String _language = "en";
  bool _isLoading = true;
  bool _soundEffectsEnabled = false;
  final SettingsService settingsService = SettingsService();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await settingsService.init();
    final language = await settingsService.getLanguage();
    if (!mounted) return;
    setState(() {
      _language = language;
      _isLoading = false;
    });

    final musicEnabled = await settingsService.getMusicEnabled();
    if (musicEnabled) {
      AudioManager().play();
    } else {
      AudioManager().stop();
    }

    final soundEffectsEnabled = await settingsService.getSoundEffectsEnabled();
    _soundEffectsEnabled = soundEffectsEnabled;
  }

  // Combined helper for both primary and secondary game buttons.
  // A shared minimum width keeps the menu buttons the same size.
  Widget _buildGameButton(
    BuildContext context,
    String text,
    String route, {
    bool primary = true,
    bool reloadOnReturn = false,
  }) {
    return RetroButton(
      label: text,
      primary: primary,
      minWidth: 260,
      onPressed: () {
        if (_soundEffectsEnabled) {
          SoundEffectsManager().playEffect('audio/button_click.wav');
        }
        if (reloadOnReturn) {
          Navigator.pushNamed(context, route).then((_) => _loadSettings());
        } else {
          Navigator.pushNamed(context, route);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: RetroLoader()));
    }

    final welcomeTitle = "Letter Champ";
    final welcomeText =
        _language == "sv"
            ? "Hej! Är du redo att klara alla bokstäver?"
            : "Hey! Are you ready to master all the letters?";
    final startDrawingText = _language == "sv" ? "Spela nu" : "Play Now";
    final settingsText = _language == "sv" ? "Inställningar" : "Settings";
    final highScoresText = _language == "sv" ? "Högsta poäng" : "High Scores";
    final instructionsText = _language == "sv" ? "Så spelar du" : "How to Play";

    return Scaffold(
      body: RetroBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: <Widget>[
                // Transparent AppBar that only carries the centered title.
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  centerTitle: true,
                  title: Text(welcomeTitle, style: RetroText.style(20)),
                ),
                Expanded(
                  // Fill the space below the title so the character floats
                  // between the greeting and the buttons, and only scroll on
                  // screens too short to hold everything.
                  child: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints viewport) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: viewport.maxHeight,
                          ),
                          child: IntrinsicHeight(
                            child: Column(
                              children: <Widget>[
                                Text(
                                  welcomeText,
                                  style: RetroText.style(18),
                                  textAlign: TextAlign.center,
                                ),
                                const Spacer(),
                                Image.asset(
                                  'assets/images/game_character.png',
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.contain,
                                ),
                                const Spacer(),
                                _buildGameButton(
                                  context,
                                  startDrawingText,
                                  '/gameplay',
                                ),
                                const SizedBox(height: 15),
                                _buildGameButton(
                                  context,
                                  highScoresText,
                                  '/highscore',
                                  primary: false,
                                  reloadOnReturn: true,
                                ),
                                const SizedBox(height: 15),
                                _buildGameButton(
                                  context,
                                  instructionsText,
                                  '/instructions',
                                  primary: false,
                                  reloadOnReturn: true,
                                ),
                                const SizedBox(height: 15),
                                _buildGameButton(
                                  context,
                                  settingsText,
                                  '/settings',
                                  primary: false,
                                  reloadOnReturn: true,
                                ),
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
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
