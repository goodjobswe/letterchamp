import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/landing_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/gameplay_screen.dart';
import 'screens/highscore_screen.dart';
import 'screens/instruction_screen.dart';
import 'services/audio_manager.dart';
import 'services/sound_effects_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Keep letter metrics consistent and make fresh installs work offline.
  GoogleFonts.config.allowRuntimeFetching = false;
  LicenseRegistry.addLicense(() async* {
    for (final family in ['Poppins', 'PressStart2P']) {
      final license = await rootBundle.loadString(
        'assets/fonts/$family-OFL.txt',
      );
      yield LicenseEntryWithLineBreaks([family], license);
    }
  });
  // Initialize the AudioManager and SoundEffectsManager singleton
  AudioManager();
  SoundEffectsManager();
  // Run the app
  runApp(MyApp());
}

/// The root widget of the app.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Letter Champ',
      theme: ThemeData(primarySwatch: Colors.blue),
      // Define the initial route and map the named routes.
      initialRoute: '/',
      routes: {
        '/': (context) => LandingScreen(),
        '/settings': (context) => SettingsScreen(),
        '/gameplay': (context) => GameplayScreen(),
        '/highscore': (context) => HighscoreScreen(),
        '/instructions': (context) => InstructionScreen(),
      },
    );
  }
}
