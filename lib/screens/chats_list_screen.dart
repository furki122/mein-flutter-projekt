import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chats_screen.dart';

class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({Key? key}) : super(key: key);

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, Map<String, String>> _userCache = {}; // Cache für Benutzerinformationen (username & email)

  // Methode zum Abrufen der Chats
  Future<List<QueryDocumentSnapshot>> _fetchChats() async {
    try {
      final snapshot = await _firestore.collection('chats').get();
      debugPrint('Chats abgerufen: ${snapshot.docs.length}');
      return snapshot.docs;
    } catch (e) {
      debugPrint('Fehler beim Abrufen der Chats: $e');
      throw Exception('Fehler beim Abrufen der Chats');
    }
  }

  // Methode zum Abrufen eines Benutzers mit Caching
  Future<Map<String, String>> _getUser(String userId) async {
    if (_userCache.containsKey(userId)) {
      return _userCache[userId]!;
    }

    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final username = userDoc['username'] ?? 'Unbekannt';
        final email = userDoc['email'] ?? 'Keine E-Mail';
        _userCache[userId] = {'username': username, 'email': email};
        return _userCache[userId]!;
      } else {
        return {'username': 'Unbekannt', 'email': 'Keine E-Mail'};
      }
    } catch (e) {
      debugPrint('Fehler beim Abrufen der Benutzerdaten für $userId: $e');
      return {'username': 'Fehler', 'email': 'Fehler'};
    }
  }

  // Methode zum Abrufen der Benutzerdaten für mehrere Benutzer
  Future<List<Map<String, String>>> _fetchUsers(List<dynamic> userIds) async {
    final List<Map<String, String>> users = [];
    final List<String> uncachedIds = [];

    for (var userId in userIds) {
      if (_userCache.containsKey(userId)) {
        users.add(_userCache[userId]!);
      } else {
        uncachedIds.add(userId);
        users.add({'username': 'Lädt...', 'email': ''}); // Platzhalter
      }
    }

    if (uncachedIds.isNotEmpty) {
      try {
        final snapshot = await _firestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: uncachedIds)
            .get();

        for (var doc in snapshot.docs) {
          final username = doc['username'] ?? 'Unbekannt';
          final email = doc['email'] ?? 'Keine E-Mail';
          _userCache[doc.id] = {'username': username, 'email': email};

          // Benutzerinfo an der richtigen Stelle aktualisieren
          final index = userIds.indexOf(doc.id);
          if (index != -1) {
            users[index] = {'username': username, 'email': email};
          }
        }
      } catch (e) {
        debugPrint('Fehler beim Abrufen der Benutzerdaten: $e');
      }
    }

    return users;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
      ),
      body: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: _fetchChats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Fehler beim Laden der Chats: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 100, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    'Keine Chats verfügbar',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final chats = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {}); // Aktualisiert die Liste der Chats
            },
            child: ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chatData = chats[index].data() as Map<String, dynamic>;
                final chatId = chats[index].id;

                final userIds = chatData['users'] ?? [];

                if (userIds is! List || userIds.isEmpty) {
                  return ListTile(
                    title: Text(chatData['lastMessage'] ?? 'Kein Text verfügbar'),
                    subtitle: const Text('Benutzer: Unbekannt'),
                  );
                }

                return Dismissible(
                  key: Key(chatId),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    final confirm = await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Chat löschen'),
                          content: const Text('Möchten Sie diesen Chat wirklich löschen?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Abbrechen'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Löschen'),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirm == true) {
                      try {
                        await _firestore.collection('chats').doc(chatId).delete();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Chat erfolgreich gelöscht')),
                        );
                        setState(() {
                          chats.removeAt(index); // Nur den betroffenen Chat entfernen
                        });
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Fehler beim Löschen: $e')),
                        );
                      }
                    }

                    return false; // Verhindert das automatische Entfernen aus der Liste
                  },
                  child: FutureBuilder<List<Map<String, String>>>(
                    future: _fetchUsers(userIds),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState == ConnectionState.waiting) {
                        return const ListTile(
                          title: Text('Lädt...'),
                          subtitle: Text('Benutzer: ...'),
                          trailing: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      } else if (userSnapshot.hasError) {
                        return ListTile(
                          title: Text(chatData['lastMessage'] ?? 'Kein Text verfügbar'),
                          subtitle: const Text('Fehler beim Laden der Benutzerdaten'),
                        );
                      }

                      final users = userSnapshot.data ?? [{'username': 'Unbekannt', 'email': ''}];
                      final usernames = users.map((u) => u['username']).join(', ');
                      final emails = users.map((u) => u['email']).join(', ');

                      return ListTile(
                        title: Text(chatData['lastMessage'] ?? 'Kein Text verfügbar'),
                        subtitle: Text('Benutzer: $usernames\nE-Mail: $emails'),
                        onTap: () {
                          debugPrint('Chat angeklickt: $chatId');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(chatId: chatId),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
