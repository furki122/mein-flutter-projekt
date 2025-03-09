import 'package:flutter/material.dart';
import 'chat_detail_screen.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key}); // Konstruktor als 'const'

  final List<Map<String, String>> chats = const [ // Liste als 'const'
    {'name': 'Alice', 'message': 'Hey, wie geht\'s?', 'time': '10:30'},
    {'name': 'Bob', 'message': 'Hast du das gesehen?', 'time': '09:45'},
    {'name': 'Charlie', 'message': 'Wann treffen wir uns?', 'time': 'Gestern'},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text(chat['name']![0]), // Anfangsbuchstabe des Namens
          ),
          title: Text(chat['name']!),
          subtitle: Text(chat['message']!),
          trailing: Text(chat['time']!),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatDetailScreen(chat['name']!),
              ),
            );
          },
        );
      },
    );
  }
}

