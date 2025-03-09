import 'package:flutter/material.dart';

class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key}); // Konstruktor als 'const'

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Status Screen',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
