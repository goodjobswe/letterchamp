import 'package:flutter/material.dart';
import 'package:letterchamp/services/music_manager.dart';
import 'package:letterchamp/services/settings_service.dart';
import 'package:letterchamp/services/sound_effects_manager.dart';
import 'package:letterchamp/theme/retro_theme.dart';
import 'package:letterchamp/theme/retro_widgets.dart';

/// The main menu.
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final SettingsService _settingsService = SettingsService();

  bool _loading = true;
  String _language = 'en';

  @override
  void initState() {
    super.initState();
    _applySettings();
  }

  /// Reads the saved settings and starts or stops the music to match. Runs
  /// again whenever another screen returns here, since Settings may have
  /// changed them.
  Future<void> _applySettings() async {
    final String language = await _settingsService.getLanguage();
    final bool musicEnabled = await _settingsService.getMusicEnabled();
    SoundEffectsManager().enabled =
        await _settingsService.getSoundEffectsEnabled();
    if (musicEnabled) {
      MusicManager().play();
    } else {
      MusicManager().stop();
    }
    if (!mounted) return;
    setState(() {
      _language = language;
      _loading = false;
    });
  }

  /// A menu button that opens [route]. All menu buttons share one minimum
  /// width so they line up.
  Widget _menuButton(String label, String route, {bool primary = false}) {
    return RetroButton(
      label: label,
      primary: primary,
      minWidth: 260,
      onPressed: () {
        SoundEffectsManager().play(SoundEffect.click);
        Navigator.pushNamed(context, route).then((_) => _applySettings());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: RetroLoader()));
    }

    final bool swedish = _language == 'sv';
    final String greeting =
        swedish
            ? 'Hej! Är du redo att klara alla bokstäver?'
            : 'Hey! Are you ready to master all the letters?';

    return Scaffold(
      body: RetroBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: <Widget>[
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  centerTitle: true,
                  title: Text('Letter Champ', style: RetroText.style(20)),
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
                                  greeting,
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
                                _menuButton(
                                  swedish ? 'Spela nu' : 'Play Now',
                                  '/gameplay',
                                  primary: true,
                                ),
                                const SizedBox(height: 15),
                                _menuButton(
                                  swedish ? 'Högsta poäng' : 'High Scores',
                                  '/highscore',
                                ),
                                const SizedBox(height: 15),
                                _menuButton(
                                  swedish ? 'Så spelar du' : 'How to Play',
                                  '/instructions',
                                ),
                                const SizedBox(height: 15),
                                _menuButton(
                                  swedish ? 'Inställningar' : 'Settings',
                                  '/settings',
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
