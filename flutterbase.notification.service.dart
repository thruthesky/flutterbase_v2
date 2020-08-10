import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fchat/flutterbase_v2/flutterbase.controller.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

/// This class handles `Firebase Notification`
class FlutterbaseAuthService {
  final FlutterbaseController _controller = Get.find();

  final FirebaseMessaging firebaseMessaging = new FirebaseMessaging();

  void registerNotification() {
    firebaseMessaging.requestNotificationPermissions();

    firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
      print('onMessage: $message');
      showNotification(message['notification']);
      return;
    }, onResume: (Map<String, dynamic> message) {
      print('onResume: $message');
      return;
    }, onLaunch: (Map<String, dynamic> message) {
      print('onLaunch: $message');
      return;
    });

    firebaseMessaging.getToken().then((token) {
      print('token: $token');
      Firestore.instance
          .collection('users')
          .document(_controller.user.uid)
          .updateData({'pushToken': token});
    }).catchError((err) {
      Get.snackbar('', err.message.toString());
    });
  }

  showNotification(message) {
    Get.snackbar(message['title'].toString(), message['body'].toString());
  }
}
