import 'package:dartz/dartz.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/core/failures.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/core/value_validators.dart';

class ParticipantsList extends ValueObject<KtList<Tuple2<UniqueId, UniqueId>>> {
  @override
  final Either<ValueFailure<KtList<Tuple2<UniqueId, UniqueId>>>, KtList<Tuple2<UniqueId, UniqueId>>> value;

  factory ParticipantsList(KtList<Tuple2<UniqueId, UniqueId>> ids) {
    return ParticipantsList._(validateParticipantsList(ids));
  }

  factory ParticipantsList.fromListOfMaps(List<Map<String,String>> participants) {
    final list = participants.map((participantMap) {
      final entry = participantMap.entries.first;
      return Tuple2(UniqueId.fromUniqueString(entry.key), UniqueId.fromUniqueString(entry.value));
    }).toImmutableList();
    return ParticipantsList(list);
  }

  const ParticipantsList._(this.value);
}
