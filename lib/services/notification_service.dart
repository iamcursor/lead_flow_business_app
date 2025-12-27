import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// FCM Service
/// Handles Firebase Cloud Messaging token generation and management
class NotificationService {


  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true
    );
    if(settings.authorizationStatus == AuthorizationStatus.authorized){
      print('user granted permission');

    }
    else if(settings.authorizationStatus == AuthorizationStatus.provisional){
      print('user granted provisions permissions');
    }
    else
      {

        print('user denied permission');
      }
  }

  /// Get FCM token
  /// Returns the FCM token string
  Future<String?> getFcmToken() async {
    try {
      String? token = await messaging.getToken();
      debugPrint('FCM Token: $token');
      return token;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }
  void isTokenRefresh() async {
    messaging.onTokenRefresh.listen((event){
      event.toString();
    }

    );
  }

}



