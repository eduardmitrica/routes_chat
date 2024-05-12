import 'package:flutter/material.dart';
import 'package:routes_chat/presentation/home/chats/widgets/chats_page_body.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
      ),
      body: const ChatsPageBody()
    );
  }
}
