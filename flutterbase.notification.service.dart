import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:englishfun_v2/flutterbase_v2/flutterbase.defines.dart';
import './flutterbase.controller.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

/// This class handles `Firebase Notification`
class FlutterbaseNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging();

  final FlutterbaseController _controller = Get.find();

  final FirebaseMessaging firebaseMessaging = new FirebaseMessaging();

  DocumentReference userInstance;

  Future<void> init() async {
    print("Flutterbase Notification Init()");

    await _initRequestPermission();

    /// subscribe to all topic
    await _fcm.subscribeToTopic(ALL_TOPIC);

    _initConfigureCallbackHandlers();

    _initUpdateUserToken();
  }

  /// Updates user token when app starts.
  _initUpdateUserToken() {
    firebaseMessaging.getToken().then((token) {
      print('token: $token');
      // userInstance.updateData({'pushToken': token});
    }).catchError((err) {
      print(err.message.toString());
    });
  }

  Future<void> _initRequestPermission() async {
    /// Ask permission to iOS user for Push Notification.
    if (Platform.isIOS) {
      _fcm.onIosSettingsRegistered.listen((event) {
        // fb.setUserToken();
        // You can update the user's token here.
      });
      await _fcm.requestNotificationPermissions(IosNotificationSettings());
    } else {
      /// For Android, no permission request is required. just get Push token.
      await firebaseMessaging.requestNotificationPermissions();
    }
  }

  _initConfigureCallbackHandlers() {
    /// Configure callback handlers for
    /// - foreground
    /// - background
    /// - exited
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('onMessage: $message');
        _displayAndNavigate(message, true);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('onLaunch: $message');
        _displayAndNavigate(message, false);
      },
      onResume: (Map<String, dynamic> message) async {
        print('onResume: $message');
        _displayAndNavigate(message, false);
      },
    );
  }

  /// Display notification & navigate
  ///
  /// Display & navigate
  ///
  /// 주의
  /// onMessage 콜백에서는 데이터가
  ///   {notification: {title: This is title., body: Notification test.}, data: {click_action: FLUTTER_NOTIFICATION_CLICK}}
  /// 와 같이 오는데,
  /// onResume & onLaunch 에서는 data 만 들어온다.
  void _displayAndNavigate(Map<String, dynamic> message, bool display) {
    var notification = message['notification'];

    /// iOS 에서는 title, body 가 `message['aps']['alert']` 에 들어온다.
    if (message['aps'] != null && message['aps']['alert'] != null) {
      notification = message['aps']['alert'];
    }
    // iOS 에서는 data 속성없이, 객체에 바로 저장된다.
    var data = message['data'] ?? message;

    // print('==> Got push data: $data');
    if (display) {
      // print('==> Display snackbar: notification: $notification')

      Get.snackbar(
        message['title'].toString(),
        message['body'].toString(),
        onTap: (ret) {
          // if (ret['postId'] != null) {
          //   Get.toNamed(Settings.postViewRoute, arguments: {'postId': ret['postId']});
          // }
        },
      );
    } else {
      if (data['postId'] != null) {
        // Get.toNamed(Settings.postViewRoute, arguments: {'postId': data['postId']});
      }
    }
  }

  showNotification(message) {
    Get.snackbar(message['title'].toString(), message['body'].toString());
  }
}
