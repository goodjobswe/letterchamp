import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class HighscoreScreen extends StatefulWidget {
  const HighscoreScreen({super.key});

  @override
  _HighscoreScreenState createState() => _HighscoreScreenState();
}

class _HighscoreScreenState extends State<HighscoreScreen> {
  String _language = "en"; // default language
  int _highScore = 0;
  bool _isLoading = true;
  final SettingsService _settingsService = SettingsService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Load both language and high score.
  Future<void> _loadData() async {
    final language = await _settingsService.getLanguage();
    final highScore = await _settingsService.getHighScore();
    setState(() {
      _language = language;
      _highScore = highScore;
      _isLoading = false;
    });
  }

  // Resets the high score in settings.
  Future<void> _resetHighScore() async {
    await _settingsService.resetHighScore();
    final highScore = await _settingsService.getHighScore();
    setState(() {
      _highScore = highScore;
    });
  }

  // Shows a confirmation dialog before resetting the high score.
  void _confirmReset() {
    final confirmTitle = _language == "sv" ? "Bekräfta" : "Confirm";
    final confirmContent = _language == "sv"
        ? "Är du säker på att du vill nollställa högsta poängen?"
        : "Are you sure you want to reset the high score?";
    final cancelText = _language == "sv" ? "Avbryt" : "Cancel";
    final confirmText = _language == "sv" ? "Ja" : "Yes";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(confirmTitle),
        content: Text(confirmContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _resetHighScore();
            },
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Loading"),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final String titleText =
    _language == "sv" ? "Högsta poäng" : "High Scores";
    final String highScoreText = _language == "sv"
        ? "Högsta poäng: $_highScore"
        : "High Score: $_highScore";
    final String resetText = _language == "sv" ? "Nollställ" : "Reset";

    return Scaffold(
      appBar: AppBar(
        title: Text(titleText),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              highScoreText,
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _confirmReset,
              child: Text(resetText),
            ),
          ],
        ),
      ),
    );
  }
}
