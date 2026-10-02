import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:letterchamp/services/settings_service.dart';
import 'package:letterchamp/services/sound_effects_manager.dart';
import 'package:letterchamp/theme/retro_theme.dart';
import 'package:letterchamp/theme/retro_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

/// A short introduction and the app's creator and music credits.
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  bool _loading = true;
  bool _swedish = false;

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final language = await SettingsService().getLanguage();
    if (!mounted) return;
    setState(() {
      _swedish = language == 'sv';
      _loading = false;
    });
  }

  void _goBack() {
    SoundEffectsManager().play(SoundEffect.click);
    Navigator.pop(context);
  }

  Future<void> _openGoodjob() async {
    bool opened = false;
    try {
      opened = await launchUrl(
        Uri.parse('https://goodjob.nu'),
        mode: LaunchMode.externalApplication,
      );
    } on PlatformException {
      // Let the player know if no browser can handle the link.
    }
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        retroSnackBar(
          _swedish
              ? 'Kunde inte öppna goodjob.nu'
              : 'Could not open goodjob.nu',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mainMenuText = _swedish ? 'Huvudmeny' : 'Main Menu';

    return Scaffold(
      body: RetroBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: RetroIconButton(
                    glyph: PixelGlyph.arrowLeft,
                    tooltip: mainMenuText,
                    onPressed: _goBack,
                  ),
                  centerTitle: true,
                  title: Text(
                    _swedish ? 'Om spelet' : 'About',
                    style: RetroText.style(16),
                  ),
                ),
                Expanded(
                  child:
                      _loading
                          ? const Center(child: RetroLoader())
                          : LayoutBuilder(
                            builder: (context, viewport) {
                              return SingleChildScrollView(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: viewport.maxHeight,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 24,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Letter Champ',
                                          style: RetroText.style(20),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 24),
                                        Text(
                                          _swedish
                                              ? 'Jag gjorde Letter Champ för min son, så att han kunde öva på att skriva bokstäver i rätt ordning och riktning.\n\nJag delar det i hopp om att fler barn får glädje av det.'
                                              : 'I made Letter Champ for my son to practice drawing letters in the right order and direction.\n\nI share it in the hope that it helps other children learn, too.',
                                          style: RetroText.style(
                                            12,
                                          ).copyWith(height: 1.7),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 24),
                                        TextButton(
                                          onPressed: _openGoodjob,
                                          style: TextButton.styleFrom(
                                            foregroundColor: RetroColors.mist,
                                            minimumSize: const Size(48, 48),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                            ),
                                          ),
                                          child: Text.rich(
                                            TextSpan(
                                              text:
                                                  _swedish
                                                      ? 'Skapad av '
                                                      : 'Made by ',
                                              children: const [
                                                TextSpan(
                                                  text: 'goodjob.nu',
                                                  style: TextStyle(
                                                    decoration:
                                                        TextDecoration
                                                            .underline,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            style: RetroText.style(
                                              12,
                                              color: RetroColors.mist,
                                              shadow: false,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        // Wording required by the music's license.
                                        Text(
                                          'Credit: https://www.FesliyanStudios.com Background Music',
                                          style: RetroText.style(
                                            10,
                                            color: RetroColors.mist,
                                            shadow: false,
                                          ).copyWith(height: 1.7),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 40),
                                        RetroButton(
                                          label: mainMenuText,
                                          onPressed: _goBack,
                                        ),
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
