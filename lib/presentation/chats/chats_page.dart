import 'package:flutter/material.dart';

class ChatsPage extends StatelessWidget {
  static const chatsPageRoute = '/home/chats';

  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chats'),),
      body: const Text('chats'),
    );
  }
}
