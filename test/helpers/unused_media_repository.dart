import 'package:routes_chat/domain/chats/messages/media_repository_interface.dart';

/// A media repository for tests that neither pick nor show photos.
class UnusedMediaRepository implements IMediaRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
