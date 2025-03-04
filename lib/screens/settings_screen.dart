import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService();

  // Default values in case the settings haven't been stored yet.
  String _selectedLanguage = 'en';
  String _selectedGameMode = 'random';
  String _selectedLetterOrder = 'alphabetic';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final language = await _settingsService.getLanguage();
    final gameMode = await _settingsService.getGameMode();
    final letterOrder = await _settingsService.getLetterOrder();

    setState(() {
      _selectedLanguage = language;
      _selectedGameMode = gameMode;
      _selectedLetterOrder = letterOrder;
      _isLoading = false;
    });
  }

  void _updateLanguage(String? newLanguage) async {
    if (newLanguage == null) return;
    await _settingsService.setLanguage(newLanguage);
    setState(() {
      _selectedLanguage = newLanguage;
    });
  }

  void _updateGameMode(String? newGameMode) async {
    if (newGameMode == null) return;
    await _settingsService.setGameMode(newGameMode);
    setState(() {
      _selectedGameMode = newGameMode;
    });
  }

  void _updateLetterOrder(String? newLetterOrder) async {
    if (newLetterOrder == null) return;
    await _settingsService.setLetterOrder(newLetterOrder);
    setState(() {
      _selectedLetterOrder = newLetterOrder;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Translated texts based on the selected language.
    final String settingsTitle =
    _selectedLanguage == 'sv' ? 'Inställningar' : 'Settings';
    final String languageLabel =
    _selectedLanguage == 'sv' ? 'Språk' : 'Language';
    final String gameModeLabel =
    _selectedLanguage == 'sv' ? 'Speltyp' : 'Game Mode';
    final String letterOrderLabel =
    _selectedLanguage == 'sv' ? 'Bokstavsordning' : 'Letter Order';

    final String englishText = _selectedLanguage == 'sv'
        ? 'Engelska'
        : 'English';
    final String swedishText = _selectedLanguage == 'sv'
        ? 'Svenska'
        : 'Swedish';
    final String uppercaseText = _selectedLanguage == 'sv'
        ? 'Endast versaler'
        : 'Only Uppercase';
    final String lowercaseText = _selectedLanguage == 'sv'
        ? 'Endast gemener'
        : 'Only Lowercase';
    final String randomText = _selectedLanguage == 'sv' ? 'Slumpmässigt' : 'Random';
    final String alphabeticText =
    _selectedLanguage == 'sv' ? 'Alfabetisk ordning' : 'Alphabetic Order';
    final String randomOrderText =
    _selectedLanguage == 'sv' ? 'Slumpmässig ordning' : 'Random Order';

    return Scaffold(
      appBar: AppBar(
        title: Text(settingsTitle),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Language Setting
            Text(languageLabel, style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            DropdownButton<String>(
              value: _selectedLanguage,
              items: [
                DropdownMenuItem(
                  value: 'en',
                  child: Text(englishText),
                ),
                DropdownMenuItem(
                  value: 'sv',
                  child: Text(swedishText),
                ),
              ],
              onChanged: _updateLanguage,
            ),
            SizedBox(height: 16),

            // Game Mode Setting
            Text(gameModeLabel, style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            DropdownButton<String>(
              value: _selectedGameMode,
              items: [
                DropdownMenuItem(
                  value: 'uppercase',
                  child: Text(uppercaseText),
                ),
                DropdownMenuItem(
                  value: 'lowercase',
                  child: Text(lowercaseText),
                ),
                DropdownMenuItem(
                  value: 'random',
                  child: Text(randomText),
                ),
              ],
              onChanged: _updateGameMode,
            ),
            SizedBox(height: 16),

            // Letter Order Setting
            Text(letterOrderLabel, style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            DropdownButton<String>(
              value: _selectedLetterOrder,
              items: [
                DropdownMenuItem(
                  value: 'alphabetic',
                  child: Text(alphabeticText),
                ),
                DropdownMenuItem(
                  value: 'random',
                  child: Text(randomOrderText),
                ),
              ],
              onChanged: _updateLetterOrder,
            ),
          ],
        ),
      ),
    );
  }
}
