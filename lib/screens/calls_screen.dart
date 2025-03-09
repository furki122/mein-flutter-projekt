import 'package:flutter/material.dart';

class CallsScreen extends StatelessWidget {
  const CallsScreen({super.key}); // Konstruktor als 'const'

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Calls Screen',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
