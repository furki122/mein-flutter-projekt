import 'package:flutter/material.dart';
import 'second_screen.dart';
import 'search_user_screen.dart'; // Neuer Screen für Benutzersuche
import 'friend_requests_screen.dart'; // Neuer Screen für Freundschaftsanfragen

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Navigation zum SecondScreen
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SecondScreen(),
                  ),
                );
              },
              child: const Text('Zum Second Screen'),
            ),
            const SizedBox(height: 20), // Abstand zwischen den Buttons
            // Navigation zur Benutzersuche
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchUserScreen(),
                  ),
                );
              },
              child: const Text('Freunde suchen'),
            ),
            const SizedBox(height: 20), // Abstand zwischen den Buttons
            // Navigation zu Freundschaftsanfragen
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FriendRequestsScreen(),
                  ),
                );
              },
              child: const Text('Freundschaftsanfragen'),
            ),
          ],
        ),
      ),
    );
  }
}
