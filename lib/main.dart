import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/gameplay_screen.dart';
import 'screens/highscore_screen.dart';
import 'screens/instruction_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/settings_screen.dart';
import 'services/music_manager.dart';
import 'services/sound_effects_manager.dart';
import 'theme/retro_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // The fonts are bundled so letter metrics never change and fresh installs
  // work offline.
  GoogleFonts.config.allowRuntimeFetching = false;
  LicenseRegistry.addLicense(() async* {
    for (final String family in ['Poppins', 'PressStart2P']) {
      final String license = await rootBundle.loadString(
        'assets/fonts/$family-OFL.txt',
      );
      yield LicenseEntryWithLineBreaks([family], license);
    }
  });

  // Create the audio players up front so the first sound has no setup delay.
  MusicManager();
  SoundEffectsManager();

  runApp(const LetterChampApp());
}

class LetterChampApp extends StatelessWidget {
  const LetterChampApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Letter Champ',
      theme: retroThemeData(),
      initialRoute: '/',
      routes: {
        '/': (context) => const LandingScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/gameplay': (context) => const GameplayScreen(),
        '/highscore': (context) => const HighscoreScreen(),
        '/instructions': (context) => const InstructionScreen(),
      },
    );
  }
}
