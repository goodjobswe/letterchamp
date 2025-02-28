import 'package:flutter/material.dart';

class GameplayScreen extends StatelessWidget {
  const GameplayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gameplay'),
      ),
      body: Center(
        child: Text(
          'Gameplay Screen',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
