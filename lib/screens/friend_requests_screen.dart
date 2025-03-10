import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendRequestsScreen extends StatelessWidget {
  const FriendRequestsScreen({super.key});

  // Freundschaftsanfrage akzeptieren und Chat erstellen
  Future<void> acceptFriendRequest(String requesterId) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    try {
      // Freund hinzufügen und Anfrage entfernen
      await FirebaseFirestore.instance.collection('users').doc(currentUserId).update({
        'friends': FieldValue.arrayUnion([requesterId]),
        'requests': FieldValue.arrayRemove([requesterId]),
      });

      await FirebaseFirestore.instance.collection('users').doc(requesterId).update({
        'friends': FieldValue.arrayUnion([currentUserId]),
      });

      // Chat erstellen
      await _createChatBetweenUsers(currentUserId, requesterId);
    } catch (e) {
      debugPrint('Fehler beim Akzeptieren der Freundschaftsanfrage: $e');
    }
  }

  // Freundschaftsanfrage ablehnen
  Future<void> declineFriendRequest(String requesterId) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    try {
      await FirebaseFirestore.instance.collection('users').doc(currentUserId).update({
        'requests': FieldValue.arrayRemove([requesterId]),
      });
    } catch (e) {
      debugPrint('Fehler beim Ablehnen der Freundschaftsanfrage: $e');
    }
  }

  // Chat zwischen zwei Benutzern erstellen
  Future<void> _createChatBetweenUsers(String userId1, String userId2) async {
    try {
      // Überprüfen, ob ein Chat bereits existiert
      final chatQuery = await FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: userId1)
          .get();

      // Filtere die Liste der Dokumente
      final filteredChats = chatQuery.docs.where((doc) {
        final participants = doc['participants'];
        return participants is List && participants.contains(userId2);
      }).toList();

      if (filteredChats.isEmpty) {
        // Neuen Chat erstellen
        await FirebaseFirestore.instance.collection('chats').add({
          'participants': [userId1, userId2],
          'createdAt': FieldValue.serverTimestamp(),
          'lastMessage': '',
        });
      }
    } catch (e) {
      debugPrint('Fehler beim Erstellen des Chats: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Freundschaftsanfragen'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(currentUserId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Fehler beim Laden der Daten: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final requests = userData['requests'] as List<dynamic>? ?? [];

          if (requests.isEmpty) {
            return const Center(
              child: Text('Keine Freundschaftsanfragen.'),
            );
          }

          // Lade alle Anfragen gleichzeitig
          return FutureBuilder<List<DocumentSnapshot>>(
            future: Future.wait(requests.map((id) => FirebaseFirestore.instance.collection('users').doc(id).get())),
            builder: (context, futureSnapshot) {
              if (!futureSnapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final requestDocs = futureSnapshot.data!;
              return ListView.builder(
                itemCount: requestDocs.length,
                itemBuilder: (context, index) {
                  final requesterData = requestDocs[index].data() as Map<String, dynamic>;
                  return ListTile(
                    leading: requesterData['profilePicture'] != null
                        ? CircleAvatar(
                      backgroundImage: NetworkImage(requesterData['profilePicture']),
                    )
                        : const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text(requesterData['username'] ?? 'Unbekannt'),
                    subtitle: Text(requesterData['email'] ?? 'Keine E-Mail'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () async {
                            final currentContext = context; // Kontext speichern
                            await acceptFriendRequest(requestDocs[index].id);

                            // Überprüfen, ob das Widget noch aktiv ist
                            if (currentContext.mounted) {
                              ScaffoldMessenger.of(currentContext).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Freundschaftsanfrage von ${requesterData['username']} akzeptiert.',
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () async {
                            final currentContext = context; // Kontext speichern
                            await declineFriendRequest(requestDocs[index].id);

                            // Überprüfen, ob das Widget noch aktiv ist
                            if (currentContext.mounted) {
                              ScaffoldMessenger.of(currentContext).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Freundschaftsanfrage von ${requesterData['username']} abgelehnt.',
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
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
