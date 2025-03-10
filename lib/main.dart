import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

// Import der Screens
import 'screens/email_auth_screen.dart';
import 'screens/register_screen.dart'; // Import des Registrierungsscreens
import 'screens/chats_list_screen.dart'; // Angepasster Chat-Listen-Screen
import 'screens/status_screen.dart';
import 'screens/calls_screen.dart';
import 'screens/search_user_screen.dart';
import 'screens/friend_requests_screen.dart';

// Logger-Instanz
final logger = Logger();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    runApp(const MyApp());
  } catch (e) {
    logger.e("Fehler bei der Firebase-Initialisierung: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeepTalk',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const AuthWrapper(),
      routes: {
        '/register': (context) => const RegisterScreen(), // Route für Registrierung
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          logger.e("Fehler in AuthWrapper: ${snapshot.error}");
          return const Scaffold(
            body: Center(child: Text("Ein Fehler ist aufgetreten.")),
          );
        } else if (snapshot.hasData) {
          return const MainScreen();
        } else {
          return const EmailAuthScreen(); // Standard: Login-Screen
        }
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Liste der Bildschirme für die Tabs
  final List<Widget> _screens = [
    const ChatsListScreen(), // Angepasst: Chat-Listen-Screen
    const StatusScreen(),
    const CallsScreen(),
    const SearchUserScreen(),
    const FriendRequestsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DeepTalk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Status',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.call),
            label: 'Anrufe',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Freunde suchen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Anfragen',
          ),
        ],
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
