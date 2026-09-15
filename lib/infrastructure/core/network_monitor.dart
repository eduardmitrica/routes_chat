import 'package:connectivity_plus/connectivity_plus.dart';

/// Tells when the phone gets a connection back.
class NetworkMonitor {
  final Connectivity _connectivity;

  const NetworkMonitor(this._connectivity);

  /// Emits each time the phone goes from no connection to one.
  ///
  /// A network the phone joins may still not reach the internet, so this is a
  /// good moment to try again, not a promise that it will work.
  Stream<void> get reconnected {
    var online = true;
    return _connectivity.onConnectivityChanged
        .map(
          (results) =>
              results.any((result) => result != ConnectivityResult.none),
        )
        .where((nowOnline) {
          final back = nowOnline && !online;
          online = nowOnline;
          return back;
        });
  }
}
