import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:letterchamp/services/settings_service.dart';
import 'package:letterchamp/services/audio_manager.dart';
import 'package:letterchamp/services/sound_effects_manager.dart';

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

  // Helper: Button text style without shadow.
  TextStyle _buttonTextStyle(Color color) {
    return GoogleFonts.pressStart2p(
      textStyle: TextStyle(fontSize: 16, color: color),
    );
  }

  // Combined helper for both primary and secondary game buttons.
  Widget _buildGameButton(
      BuildContext context, String text, String route,
      {bool primary = true, bool reloadOnReturn = false}) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.transparent),
        elevation: WidgetStateProperty.all(0),
        padding: WidgetStateProperty.all(EdgeInsets.zero),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      onPressed: () {
        if (_soundEffectsEnabled) {
          SoundEffectsManager().playEffect('audio/button_click.wav');
        }
        if (reloadOnReturn) {
          Navigator.pushNamed(context, route)
              .then((_) => _loadSettings());
        } else {
          Navigator.pushNamed(context, route);
        }
      },
      child: Ink(
        decoration: BoxDecoration(
          gradient: primary
              ? const LinearGradient(
            colors: [Color(0xfff45d27), Color(0xfff5851f)],
          )
              : null,
          color: primary ? null : const Color(0xFF2E2B2F),
          borderRadius: BorderRadius.circular(20),
          boxShadow: primary
              ? const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 5,
              offset: Offset(3, 3),
            ),
          ]
              : null,
        ),
        child: Container(
          constraints: const BoxConstraints(minWidth: 150, minHeight: 50),
          alignment: Alignment.center,
          child: Text(
            text,
            style: _buttonTextStyle(
                primary ? Colors.white : Colors.grey.shade300),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Loading")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final welcomeTitle = "Letter Champ";
    final welcomeText = _language == "sv"
        ? "Hej! Är du redo att bemästra alla bokstäver?"
        : "Hey! Are you ready to master all the letters?";
    final startDrawingText = _language == "sv" ? "Spela Nu" : "Play Now";
    final settingsText = _language == "sv" ? "Inställningar" : "Settings";
    final highScoresText = _language == "sv" ? "Högsta Poäng" : "High Scores";
    final instructionsText =
    _language == "sv" ? "Instruktioner" : "Instructions";

    return Scaffold(
      body: Stack(
        children: [
          // Background image.
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/game_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Dark overlay.
          Container(
            color: Color.fromRGBO(0, 0, 0, 0.4),
          ),
          // Content.
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                  ),
                  child: Column(
                    children: [
                      // Custom transparent AppBar.
                      AppBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        centerTitle: true,
                        title: Text(
                          welcomeTitle,
                          style: GoogleFonts.pressStart2p(
                            textStyle: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 10,
                                  color: Colors.black,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Main content.
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            // Welcome text.
                            Text(
                              welcomeText,
                              style: GoogleFonts.pressStart2p(
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 10,
                                      color: Colors.black,
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                ),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            // Game character image.
                            Image.asset(
                              'assets/images/game_character.png',
                              width: 200,
                              height: 200,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 30),
                            // Primary game button.
                            _buildGameButton(context, startDrawingText, '/gameplay'),
                            const SizedBox(height: 15),
                            // Secondary buttons.
                            _buildGameButton(context, highScoresText, '/highscore',
                                primary: false, reloadOnReturn: true),
                            const SizedBox(height: 15),
                            _buildGameButton(context, instructionsText, '/instructions',
                                primary: false, reloadOnReturn: true),
                            const SizedBox(height: 15),
                            _buildGameButton(context, settingsText, '/settings',
                                primary: false, reloadOnReturn: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
