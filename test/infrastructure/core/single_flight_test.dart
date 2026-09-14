import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/infrastructure/core/single_flight.dart';

/// Long enough for any run here, short enough that a run that never finishes
/// fails the test instead of hanging it.
const _patience = Duration(seconds: 2);

void main() {
  late Map<String, Future<void>> running;
  late int runs;

  setUp(() {
    running = {};
    runs = 0;
  });

  Future<void> task() async {
    runs++;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }

  test('a run finishes, and a later call runs the task again', () async {
    // Regression: the entry used to be removed in an arrow function passed to
    // whenComplete. `remove` returned the run's own future, whenComplete waited
    // for it, and every message sent after a key reset hung.
    await singleFlight(running, 'chat', task).timeout(_patience);
    await singleFlight(running, 'chat', task).timeout(_patience);

    expect(runs, 2);
    expect(running, isEmpty);
  });

  test('concurrent calls for the same key share one run', () async {
    final first = singleFlight(running, 'chat', task);
    final second = singleFlight(running, 'chat', task);

    await Future.wait([first, second]).timeout(_patience);

    expect(runs, 1);
    expect(running, isEmpty);
  });

  test('calls for different keys run separately', () async {
    await Future.wait([
      singleFlight(running, 'one', task),
      singleFlight(running, 'two', task),
    ]).timeout(_patience);

    expect(runs, 2);
  });

  test('a failed run is reported, and the next call runs again', () async {
    await expectLater(
      singleFlight(running, 'chat', () async {
        runs++;
        throw StateError('offline');
      }).timeout(_patience),
      throwsStateError,
    );

    await singleFlight(running, 'chat', task).timeout(_patience);

    expect(runs, 2);
    expect(running, isEmpty);
  });
}
