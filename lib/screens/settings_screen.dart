import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
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

    final String englishText =
    _selectedLanguage == 'sv' ? 'Engelska' : 'English';
    final String swedishText =
    _selectedLanguage == 'sv' ? 'Svenska' : 'Swedish';
    final String uppercaseText =
    _selectedLanguage == 'sv' ? 'Endast versaler' : 'Only Uppercase';
    final String lowercaseText =
    _selectedLanguage == 'sv' ? 'Endast gemener' : 'Only Lowercase';
    final String randomText =
    _selectedLanguage == 'sv' ? 'Slumpmässigt' : 'Random';
    final String alphabeticText =
    _selectedLanguage == 'sv' ? 'Alfabetisk ordning' : 'Alphabetic Order';
    final String randomOrderText =
    _selectedLanguage == 'sv' ? 'Slumpmässig ordning' : 'Random Order';
    final String mainMenuText =
    _selectedLanguage == 'sv' ? 'Huvudmeny' : 'Main Menu';

    return Scaffold(
      // Use a Stack to incorporate the game-themed background image and overlay.
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
          // Semi-transparent dark overlay for a more dramatic look.
          Container(
            color: Color.fromRGBO(0, 0, 0, 0.4),
          ),
          // Main content.
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  // Custom transparent AppBar with back button and game font.
                  AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      iconSize: 36,
                      onPressed: () => Navigator.pop(context),
                      tooltip: mainMenuText,
                    ),
                    centerTitle: true,
                    title: Text(
                      settingsTitle,
                      style: GoogleFonts.pressStart2p(
                        textStyle: const TextStyle(
                          fontSize: 16,
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
                  // Expanded content that is centered vertically.
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Language Setting.
                          Text(
                            languageLabel,
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
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(255, 255, 255, 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: DropdownButton<String>(
                              value: _selectedLanguage,
                              dropdownColor: Colors.black,
                              isExpanded: true,
                              iconEnabledColor: Colors.white,
                              underline: Container(),
                              items: [
                                DropdownMenuItem(
                                  value: 'en',
                                  child: Text(
                                    englishText,
                                    style: GoogleFonts.pressStart2p(
                                      textStyle: const TextStyle(
                                        fontSize: 14,
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
                                DropdownMenuItem(
                                  value: 'sv',
                                  child: Text(
                                    swedishText,
                                    style: GoogleFonts.pressStart2p(
                                      textStyle: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,

                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: _updateLanguage,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Game Mode Setting.
                          Text(
                            gameModeLabel,
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
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(255, 255, 255, 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: DropdownButton<String>(
                              value: _selectedGameMode,
                              dropdownColor: Colors.black,
                              isExpanded: true,
                              iconEnabledColor: Colors.white,
                              underline: Container(),
                              items: [
                                DropdownMenuItem(
                                  value: 'uppercase',
                                  child: Text(
                                    uppercaseText,
                                    style: GoogleFonts.pressStart2p(
                                      textStyle: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'lowercase',
                                  child: Text(
                                    lowercaseText,
                                    style: GoogleFonts.pressStart2p(
                                      textStyle: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'random',
                                  child: Text(
                                    randomText,
                                    style: GoogleFonts.pressStart2p(
                                      textStyle: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: _updateGameMode,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Letter Order Setting.
                          Text(
                            letterOrderLabel,
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
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(255, 255, 255, 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: DropdownButton<String>(
                              value: _selectedLetterOrder,
                              dropdownColor: Colors.black,
                              isExpanded: true,
                              iconEnabledColor: Colors.white,
                              underline: Container(),
                              items: [
                                DropdownMenuItem(
                                  value: 'alphabetic',
                                  child: Text(
                                    alphabeticText,
                                    style: GoogleFonts.pressStart2p(
                                      textStyle: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'random',
                                  child: Text(
                                    randomOrderText,
                                    style: GoogleFonts.pressStart2p(
                                      textStyle: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: _updateLetterOrder,
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Main Menu Button.
                          Center(
                            child: ElevatedButton(
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
                                  constraints: const BoxConstraints(minWidth: 150, minHeight: 50),
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
                          ),
                          const SizedBox(height: 16),
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
