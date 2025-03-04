import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  String _language = "en"; // default language
  bool _isLoading = true;
  // Settings service.
  final SettingsService _settingsService = SettingsService();

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final language = await _settingsService.getLanguage();

    setState(() {
      _language = language;
      _isLoading = false;
    });
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

    // Set the text based on the language setting.
    final welcomeTitle = _language == "sv" ? "Välkommen" : "Welcome";
    final welcomeText = _language == "sv"
        ? "Välkommen till Letter Drawing App!"
        : "Welcome to the Letter Drawing App!";
    final startDrawingText = _language == "sv" ? "Börja rita" : "Start Drawing";
    final settingsText = _language == "sv" ? "Inställningar" : "Settings";
    final highScoresText = _language == "sv" ? "Högsta poäng" : "High Scores";

    return Scaffold(
      appBar: AppBar(
        title: Text(welcomeTitle),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              welcomeText,
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/gameplay');
              },
              child: Text(startDrawingText),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
              child: Text(settingsText),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/highscore');
              },
              child: Text(highScoresText),
            ),
          ],
        ),
      ),
    );
  }
}
