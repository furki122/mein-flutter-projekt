import 'package:flutter/material.dart';

class SecondScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Zweite Seite'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Zurück zur Startseite
            Navigator.pop(context);
          },
          child: Text('Zurück zur Startseite'),
        ),
      ),
    );
  }
}
