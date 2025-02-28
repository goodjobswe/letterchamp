import 'package:flutter/material.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome to the Letter Drawing App!',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Navigate to the gameplay screen.
                Navigator.pushNamed(context, '/gameplay');
              },
              child: Text('Start Drawing'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Navigate to the settings screen.
                Navigator.pushNamed(context, '/settings');
              },
              child: Text('Settings'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Navigate to the highscore screen.
                Navigator.pushNamed(context, '/highscore');
              },
              child: Text('High Scores'),
            ),
          ],
        ),
      ),
    );
  }
}
