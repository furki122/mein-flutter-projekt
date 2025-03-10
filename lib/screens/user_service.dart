import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  Future<void> addUserToFirestore(String username, String email, String name, String profilePicture) async {
    try {
      // Zugriff auf die Firestore-Sammlung "users"
      CollectionReference users = FirebaseFirestore.instance.collection('users');

      // Benutzer-Daten hinzufügen
      await users.add({
        'username': username,
        'email': email,
        'name': name,
        'profilePicture': profilePicture,
        'createdAt': FieldValue.serverTimestamp(), // Automatisch generierter Zeitstempel
      });

      print('Benutzer erfolgreich hinzugefügt!');
    } catch (e) {
      print('Fehler beim Hinzufügen des Benutzers: $e');
    }
  }
}
