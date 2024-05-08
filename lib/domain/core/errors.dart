import 'package:routes_chat/domain/core/failures.dart';

class UnauthenticatedUser extends Error {}

class UnexpectedValueError extends Error {
  final ValueFailure _valueFailure;

  UnexpectedValueError(this._valueFailure);

  @override
  String toString() {
    const explanation = 'Encountered a failure at an unrecoverable point. Terminating...';
    return Error.safeToString('$explanation Failure was: $_valueFailure');
  }
}