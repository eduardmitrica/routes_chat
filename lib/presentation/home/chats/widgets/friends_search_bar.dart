import 'package:flutter/material.dart';

import '../friends_search_page/friends_search_page.dart';

class FriendsSearchBar extends StatelessWidget {
  const FriendsSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context)
          .pushNamed(FriendsSearchPage.friendsSearchPageRoute),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 60,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.deepPurpleAccent),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Padding(
          padding: EdgeInsets.only(left: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.search_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
