import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SearchUserScreen extends StatelessWidget {
  const SearchUserScreen({super.key});

  // Benutzerliste anzeigen
  Future<List<DocumentSnapshot>> _fetchUsers() async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('users').get();
      return querySnapshot.docs.where((doc) => doc.id != currentUserId).toList();
    } catch (e) {
      debugPrint('Fehler beim Abrufen der Benutzer: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Benutzer suchen'),
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Fehler beim Laden der Benutzer: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final users = snapshot.data!;
          if (users.isEmpty) {
            return const Center(
              child: Text('Keine Benutzer gefunden.'),
            );
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index].data() as Map<String, dynamic>;
              return ListTile(
                leading: userData['profilePicture'] != null
                    ? CircleAvatar(
                  backgroundImage: NetworkImage(userData['profilePicture']),
                )
                    : const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text(userData['username'] ?? 'Unbekannt'),
                subtitle: Text(userData['email'] ?? 'Keine E-Mail'),
                onTap: () {
                  // Profilseite öffnen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserProfileScreen(userId: users[index].id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class UserProfileScreen extends StatelessWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  Future<Map<String, dynamic>?> _fetchUserProfile() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      return docSnapshot.data();
    } catch (e) {
      debugPrint('Fehler beim Abrufen des Benutzerprofils: $e');
      return null;
    }
  }

  Future<void> _sendFriendRequest(String targetUserId) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    try {
      await FirebaseFirestore.instance.collection('users').doc(targetUserId).update({
        'requests': FieldValue.arrayUnion([currentUserId]),
      });
      debugPrint('Freundschaftsanfrage gesendet.');
    } catch (e) {
      debugPrint('Fehler beim Senden der Freundschaftsanfrage: $e');
    }
  }

  Future<void> _startChat(String targetUserId) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    try {
      // Chat erstellen oder vorhandenen Chat finden
      final chatQuery = await FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: currentUserId)
          .get();

      // Prüfen, ob ein Chat mit dem Zielbenutzer existiert
      final filteredChats = chatQuery.docs.where((doc) {
        final participants = doc['participants'] as List<dynamic>;
        return participants.contains(targetUserId);
      }).toList();

      if (filteredChats.isEmpty) {
        // Neuen Chat erstellen
        await FirebaseFirestore.instance.collection('chats').add({
          'participants': [currentUserId, targetUserId],
          'createdAt': FieldValue.serverTimestamp(),
          'lastMessage': '',
        });
        debugPrint('Neuer Chat erstellt.');
      } else {
        debugPrint('Chat existiert bereits.');
      }
    } catch (e) {
      debugPrint('Fehler beim Starten des Chats: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Benutzerprofil'),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Fehler beim Laden des Profils: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final userData = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: userData['profilePicture'] != null
                      ? NetworkImage(userData['profilePicture'])
                      : null,
                  child: userData['profilePicture'] == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  userData['username'] ?? 'Unbekannt',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  userData['email'] ?? 'Keine E-Mail',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () async {
                    await _sendFriendRequest(userId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Freundschaftsanfrage gesendet.')),
                    );
                  },
                  icon: const Icon(Icons.person_add),
                  label: const Text('Freundschaftsanfrage senden'),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    await _startChat(userId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Chat gestartet.')),
                    );
                  },
                  icon: const Icon(Icons.message),
                  label: const Text('Nachricht senden'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
