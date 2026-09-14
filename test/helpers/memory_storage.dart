import 'package:hydrated_bloc/hydrated_bloc.dart';

/// Keeps hydrated bloc state in memory, as if on disk between launches.
class MemoryStorage implements Storage {
  final values = <String, dynamic>{};

  @override
  dynamic read(String key) => values[key];

  @override
  Future<void> write(String key, dynamic value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<void> clear() async => values.clear();

  @override
  Future<void> close() async {}
}
