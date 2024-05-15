import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/material.dart';
import 'package:routes_chat/domain/shared/user/user.dart';

class ChatPage extends StatelessWidget {
  static const chatPageRoute = '/home/chats/chat';

  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = ModalRoute.of(context)!.settings.arguments as User;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded)),
        title: Text(
          user.username.getOrCrash(),
          style: const TextStyle(color: Colors.deepPurpleAccent),
        ),
        actions: [
          CircleAvatar(
            foregroundImage: NetworkImage(user.imageUrl.getOrCrash()),
          ),
        ],
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.end,children: [
        MessageBar(
          messageBarColor: Colors.deepPurpleAccent,
          messageBarHintText: 'Start typing...',
          onSend: (value) {
          },
        ),
      ],),
    );
  }
}
