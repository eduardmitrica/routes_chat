import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routes_chat/application/friend_requests/friend_request_actor/friend_request_actor_bloc.dart';
import 'package:routes_chat/presentation/search/widgets/search_page_body.dart';

class SearchPage extends StatelessWidget {
  static const searchPageRoute = '/home/search';

  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: BlocProvider.of<FriendRequestActorBloc>(context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Discover'),
        ),
        body: SearchPageBody(),
      ),
    );
  }
}
