import 'package:flutter/material.dart';

class HighscoreScreen extends StatelessWidget {
  const HighscoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('High Scores'),
      ),
      body: Center(
        child: Text(
          'High Scores Screen',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
