import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/settings_service.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  LandingScreenState createState() => LandingScreenState();
}

class LandingScreenState extends State<LandingScreen> {
  String _language = "en";
  bool _isLoading = true;
  final SettingsService settingsService = SettingsService();

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    await settingsService.init();
    final language = await settingsService.getLanguage();

    setState(() {
      _language = language;
      _isLoading = false;
    });
  }

  Widget _buildGameButton(BuildContext context, String text, String route) {
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
      onPressed: () => Navigator.pushNamed(context, route),
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xfff45d27), Color(0xfff5851f)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 5,
              offset: Offset(3, 3),
            ),
          ],
        ),
        child: Container(
          constraints: const BoxConstraints(minWidth: 150, minHeight: 50),
          alignment: Alignment.center,
          child: Text(
            text,
            style: GoogleFonts.pressStart2p(
              textStyle: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameButtonSecondary(BuildContext context, String text, String route) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.transparent),
        elevation: WidgetStateProperty.all(0),
        padding: WidgetStateProperty.all(EdgeInsets.zero),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            //side: BorderSide(color: Colors.grey.shade400, width: 2),
          ),
        ),
      ),
      onPressed: () {
        Navigator.pushNamed(context, route).then((_) {
          _loadLanguage();
        });
      },
      child: Ink(
        decoration: BoxDecoration(
          color: Color(0xFF2E2B2F), // Use a solid, neutral background.
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          constraints: const BoxConstraints(minWidth: 150, minHeight: 50),
          alignment: Alignment.center,
          child: Text(
            text,
            style: GoogleFonts.pressStart2p(
              textStyle: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade300,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Loading"),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final welcomeTitle = _language == "sv" ? "Letter Champ" : "Letter Champ";
    final welcomeText = _language == "sv"
        ? "Hej! Är du redo att bemästra alla bokstäver?"
        : "Hey! Are you ready to master all the letters?";
    final startDrawingText =
    _language == "sv" ? "Spela Nu" : "Play Now";
    final settingsText =
    _language == "sv" ? "Inställningar" : "Settings";
    final highScoresText =
    _language == "sv" ? "Högsta Poäng" : "High Scores";
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                  Expanded(
                    child: Center(
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
                          // Buttons.
                          _buildGameButton(context, startDrawingText, '/gameplay'),
                          const SizedBox(height: 15),
                          _buildGameButtonSecondary(context, highScoresText, '/highscore'),
                          const SizedBox(height: 15),
                          _buildGameButtonSecondary(context, instructionsText, '/instructions'),
                          const SizedBox(height: 15),
                          _buildGameButtonSecondary(context, settingsText, '/settings'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
