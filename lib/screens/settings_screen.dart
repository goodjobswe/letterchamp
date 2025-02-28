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
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Language Setting
            Text('Language', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            DropdownButton<String>(
              value: _selectedLanguage,
              items: [
                DropdownMenuItem(
                  value: 'en',
                  child: Text('English'),
                ),
                DropdownMenuItem(
                  value: 'sv',
                  child: Text('Swedish'),
                ),
              ],
              onChanged: _updateLanguage,
            ),
            SizedBox(height: 16),

            // Game Mode Setting
            Text('Game Mode', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            DropdownButton<String>(
              value: _selectedGameMode,
              items: [
                DropdownMenuItem(
                  value: 'uppercase',
                  child: Text('Only Uppercase'),
                ),
                DropdownMenuItem(
                  value: 'lowercase',
                  child: Text('Only Lowercase'),
                ),
                DropdownMenuItem(
                  value: 'random',
                  child: Text('Random'),
                ),
              ],
              onChanged: _updateGameMode,
            ),
            SizedBox(height: 16),

            // Letter Order Setting
            Text('Letter Order', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            DropdownButton<String>(
              value: _selectedLetterOrder,
              items: [
                DropdownMenuItem(
                  value: 'alphabetic',
                  child: Text('Alphabetic Order'),
                ),
                DropdownMenuItem(
                  value: 'random',
                  child: Text('Random Order'),
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
