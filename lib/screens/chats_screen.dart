import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;

  const ChatScreen({Key? key, required this.chatId}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  Future<void> _sendMessage() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null || _messageController.text
        .trim()
        .isEmpty) {
      return;
    }

    try {
      // Nachricht in die messages-Unter-Sammlung speichern
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add({
        'text': _messageController.text.trim(),
        'senderId': currentUser.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Letzte Nachricht im Chat-Dokument aktualisieren
      await FirebaseFirestore.instance.collection('chats')
          .doc(widget.chatId)
          .update({
        'lastMessage': _messageController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _messageController.clear();
    } catch (e) {
      debugPrint('Fehler beim Senden der Nachricht: $e');
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('ChatScreen geöffnet mit Chat-ID: ${widget.chatId}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Keine Nachrichten.'));
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData =
                    messages[index].data() as Map<String, dynamic>;
                    final isCurrentUser =
                        messageData['senderId'] ==
                            FirebaseAuth.instance.currentUser?.uid;

                    return Align(
                      alignment: isCurrentUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isCurrentUser
                              ? Colors.blue[100]
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          messageData['text'] ?? '',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Nachricht eingeben...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}