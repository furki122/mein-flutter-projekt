import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl_phone_field/intl_phone_field.dart'; // Bibliothek für Ländercode-Auswahl
import 'otp_screen.dart'; // Importiere die zweite Seite

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  _PhoneAuthScreenState createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _fullPhoneNumber; // Variable für die vollständige Telefonnummer

  void _sendVerificationCode() async {
    if (_fullPhoneNumber == null || _fullPhoneNumber!.isEmpty) {
      _showMessage("Bitte eine gültige Telefonnummer eingeben.");
      return;
    }

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: _fullPhoneNumber!,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          _showMessage("Automatisch eingeloggt!");
        },
        verificationFailed: (FirebaseAuthException e) {
          _showMessage("Verifizierung fehlgeschlagen: ${e.message}");
        },
        codeSent: (String verificationId, int? resendToken) {
          // Weiterleitung zur zweiten Seite
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpScreen(
                verificationId: verificationId,
              ),
            ),
          );
          _showMessage("Code wurde gesendet.");
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      _showMessage("Fehler: $e");
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Telefonnummer eingeben")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IntlPhoneField(
              decoration: const InputDecoration(
                labelText: "Telefonnummer",
                border: OutlineInputBorder(),
              ),
              initialCountryCode: 'DE', // Standardmäßig auf Deutschland setzen
              onChanged: (phone) {
                _fullPhoneNumber = phone.completeNumber; // Vollständige Nummer speichern
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendVerificationCode,
              child: const Text("Code senden"),
            ),
          ],
        ),
      ),
    );
  }
}
