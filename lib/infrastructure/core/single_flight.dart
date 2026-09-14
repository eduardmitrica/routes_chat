/// Runs [task] for [key], unless a run for [key] is already in [running], in
/// which case that run's future is returned, so concurrent callers share one
/// run. The entry is removed once the run finishes, so a later call runs
/// [task] again.
Future<void> singleFlight(
  Map<String, Future<void>> running,
  String key,
  Future<void> Function() task,
) {
  final inFlight = running[key];
  if (inFlight != null) {
    return inFlight;
  }
  late final Future<void> run;
  run = task().whenComplete(() {
    // A block body on purpose. An arrow function would return what `remove`
    // returns, which is this very future, and whenComplete waits for a future
    // its callback returns: the run would never finish.
    if (identical(running[key], run)) {
      running.remove(key);
    }
  });
  return running[key] = run;
}
