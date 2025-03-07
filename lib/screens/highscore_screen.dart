import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/settings_service.dart';

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
    setState(() {
      _language = language;
      _highScore = highScore;
      _highestStreak = highestStreak;
      _isLoading = false;
    });
  }

  // Resets the high score (and streak) in settings.
  Future<void> _resetHighScore() async {
    await settingsService.resetHighScore();
    final highScore = await settingsService.getHighScore();
    setState(() {
      _highScore = highScore;
    });
  }

  // Shows a confirmation dialog before resetting the high score and streak.
  void _confirmReset() {
    final confirmTitle = _language == "sv" ? "Bekräfta" : "Confirm";
    final confirmContent = _language == "sv"
        ? "Är du säker på att du vill nollställa högsta poäng och flest i rad?"
        : "Are you sure you want to reset the high score and streak?";
    final cancelText = _language == "sv" ? "Avbryt" : "Cancel";
    final confirmText = _language == "sv" ? "Ja" : "Yes";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Colors.white),
        ),
        title: Text(
          confirmTitle,
          style: _headerTextStyle(18),
        ),
        content: Text(
          confirmContent,
          style: _headerTextStyle(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              cancelText,
              style: _headerTextStyle(12),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _resetHighScore();
            },
            child: Text(
              confirmText,
              style: _headerTextStyle(12),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _headerTextStyle(double size) {
    return GoogleFonts.pressStart2p(
      textStyle: TextStyle(
        color: Colors.white,
        fontSize: size,
        shadows: const [
          Shadow(
            blurRadius: 10,
            color: Colors.black,
            offset: Offset(2, 2),
          ),
        ],
      ),
    );
  }

  // Common button decoration for consistency.
  Widget _buildMenuButton(String text, VoidCallback onPressed) {
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
      onPressed: onPressed,
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xfff45d27), Color(0xfff5851f)],
          ),
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

  // Button style for the reset button.
  Widget _buildResetButton(String text, VoidCallback onPressed) {
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
      onPressed: onPressed,
      child: Ink(
        decoration: BoxDecoration(
          color: const Color(0xFF2E2B2F),
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
            const Center(child: CircularProgressIndicator()),
          ],
        ),
      );
    }

    final String titleText =
    _language == "sv" ? "Högsta poäng" : "High Scores";
    final String highScoreLabel = _language == "sv" ? "Högsta poäng" : "High Score";
    final String streakLabel = _language == "sv" ? "Flest i rad" : "Longest streak";
    final String mainMenuText = _language == "sv" ? "Huvudmeny" : "Main Menu";
    final String resetText = _language == "sv" ? "Nollställ" : "Reset";

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
          // Main content.
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  // Transparent AppBar with back button.
                  AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      iconSize: 36,
                      onPressed: () => Navigator.pop(context),
                      tooltip: _language == "sv" ? "Huvudmeny" : "Main Menu",
                    ),
                    centerTitle: true,
                    title: Text(
                      titleText,
                      style: _headerTextStyle(16),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // High Score display.
                          Text(
                            highScoreLabel,
                            style: _headerTextStyle(20),
                          ),
                          Text(
                            _highScore.toString(),
                            style: _headerTextStyle(28),
                          ),
                          const SizedBox(height: 20),
                          // Highest Streak display.
                          Text(
                            streakLabel,
                            style: _headerTextStyle(20),
                          ),
                          Text(
                            _highestStreak.toString(),
                            style: _headerTextStyle(28),
                          ),
                          const SizedBox(height: 36),
                          // Main Menu Button.
                          _buildMenuButton(mainMenuText, () => Navigator.pop(context)),
                          const SizedBox(height: 15),
                          // Reset Button.
                          _buildResetButton(resetText, _confirmReset),
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
