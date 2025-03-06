import 'package:flutter/material.dart';
import 'screens/landing_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/gameplay_screen.dart';
import 'screens/highscore_screen.dart';
import 'screens/instruction_screen.dart';

void main() {
  runApp(MyApp());
}

/// The root widget of the app.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Letter Drawing App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
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
