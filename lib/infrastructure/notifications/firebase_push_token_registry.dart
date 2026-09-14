import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

import '../../domain/notifications/push_token_registry_interface.dart';
import '../../domain/shared/user/current_user_session_interface.dart';
import '../core/firestore_helpers.dart';

/// Stores each device's FCM token under `users/{uid}/fcmTokens/{token}`, where
/// the `notifyNewMessage` Cloud Function looks for the recipients of a message.
class FirebasePushTokenRegistry implements IPushTokenRegistry {
  final FirebaseMessaging _messaging;
  final FirebaseFirestore _firestore;
  final ICurrentUserSession _session;

  StreamSubscription<String>? _tokenRefresh;

  FirebasePushTokenRegistry(this._messaging, this._firestore, this._session);

  @override
  Future<void> register(String uid) async {
    try {
      final settings = await _messaging.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        return;
      }

      final token = await _messaging.getToken();
      if (token != null) {
        await _save(uid, token);
      }

      // FCM can rotate a token at any time. Keep storing the new one for as
      // long as this session lasts, and never for whoever signs in next.
      await _tokenRefresh?.cancel();
      _tokenRefresh = _messaging.onTokenRefresh
          .takeUntil(_session.ended)
          .listen((refreshed) => _save(uid, refreshed).catchError((_) {}));
    } on Exception catch (error) {
      debugPrint('Push token registration failed: $error');
    }
  }

  @override
  Future<void> unregister(String uid) async {
    try {
      await _tokenRefresh?.cancel();
      _tokenRefresh = null;

      final token = await _messaging.getToken();
      if (token != null) {
        await _firestore.pushTokenDocument(uid, token).delete();
      }
      // A new token is issued on the next registration, so a later user of this
      // device never receives notifications meant for this one.
      await _messaging.deleteToken();
    } on Exception catch (error) {
      debugPrint('Push token removal failed: $error');
    }
  }

  Future<void> _save(String uid, String token) =>
      _firestore.pushTokenDocument(uid, token).set({
        'platform': defaultTargetPlatform.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
}
