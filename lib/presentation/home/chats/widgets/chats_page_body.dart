import 'package:flutter/material.dart';

import 'friends_search_bar.dart';

class ChatsPageBody extends StatelessWidget {
  const ChatsPageBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: [
          FriendsSearchBar(),
          SizedBox(height: 20,),
          Center(child: Text('No chats so far'),),
        ],
      ),
    );
  }
}
