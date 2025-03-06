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
  int _highestStreak = 0; // New variable for highest streak.
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

  // Resets the high score in settings.
  Future<void> _resetHighScore() async {
    await settingsService.resetHighScore();
    final highScore = await settingsService.getHighScore();
    setState(() {
      _highScore = highScore;
    });
  }

  // Shows a confirmation dialog before resetting the high score.
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
        backgroundColor: Colors.grey.shade900,
        title: Text(
          confirmTitle,
          style: GoogleFonts.pressStart2p(
            textStyle: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
        content: Text(
          confirmContent,
          style: GoogleFonts.pressStart2p(
            textStyle: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              cancelText,
              style: GoogleFonts.pressStart2p(
                textStyle: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _resetHighScore();
            },
            child: Text(
              confirmText,
              style: GoogleFonts.pressStart2p(
                textStyle: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
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
    final String highScoreText = _language == "sv"
        ? "Högsta poäng"
        : "High Score";

    // Lift out the highest streak texts.
    final String streakLabelText = _language == "sv"
        ? "Flest i rad"
        : "Longest streak";
    final String streakValueText = _highestStreak.toString();

    final String resetText = _language == "sv" ? "Nollställ" : "Reset";
    final String mainMenuText =
    _language == "sv" ? "Huvudmeny" : "Main Menu";

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
                  // Custom transparent AppBar with game font and a back button.
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
                      style: GoogleFonts.pressStart2p(
                        textStyle: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Display high score.
                          Text(
                            highScoreText,
                            style: GoogleFonts.pressStart2p(
                              textStyle: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Text(
                            _highScore.toString(),
                            style: GoogleFonts.pressStart2p(
                              textStyle: const TextStyle(
                                fontSize: 28,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          //
                          const SizedBox(height: 20),
                          // Display highest streak in two rows.
                          Text(
                            streakLabelText,
                            style: GoogleFonts.pressStart2p(
                              textStyle: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Text(
                            streakValueText,
                            style: GoogleFonts.pressStart2p(
                              textStyle: const TextStyle(
                                fontSize: 28,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 36),
                          // Reset Button.
                          ElevatedButton(
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
                            onPressed: _confirmReset,
                            child: Ink(
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade300, // Use a solid, neutral background.
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Container(
                                constraints: const BoxConstraints(minWidth: 150, minHeight: 50),
                                alignment: Alignment.center,
                                child: Text(
                                  resetText,
                                  style: GoogleFonts.pressStart2p(
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87, // Use a subtler text color.
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Main Menu Button for clarity.
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                              WidgetStateProperty.all(Colors.transparent),
                              elevation: WidgetStateProperty.all(0),
                              padding:
                              WidgetStateProperty.all(EdgeInsets.zero),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
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
                                constraints: const BoxConstraints(
                                    minWidth: 150, minHeight: 50),
                                alignment: Alignment.center,
                                child: Text(
                                  mainMenuText,
                                  style: GoogleFonts.pressStart2p(
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
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
