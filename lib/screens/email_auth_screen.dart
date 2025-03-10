import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class EmailAuthScreen extends StatefulWidget {
  const EmailAuthScreen({super.key});

  @override
  _EmailAuthScreenState createState() => _EmailAuthScreenState();
}

class _EmailAuthScreenState extends State<EmailAuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  bool _isLoading = false;

  // Methode zur Anmeldung
  void _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      logger.i("Benutzer erfolgreich angemeldet");
    } catch (e) {
      logger.e("Fehler bei der Anmeldung: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fehler bei der Anmeldung: ${e.toString()}")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anmeldung'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Eingabefelder
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'E-Mail',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Passwort',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            // Ladeanzeige oder Schaltflächen
            if (_isLoading)
              const CircularProgressIndicator()
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: _login,
                    child: const Text('Anmelden'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text('Noch keinen Account? Registrieren'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
