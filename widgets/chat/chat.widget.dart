import 'dart:async';

import 'package:englishfun_v2/flutterbase_v2/flutterbase.notification.service.dart';
import 'package:englishfun_v2/flutterbase_v2/widgets/chat/chat.input_box.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:englishfun_v2/services/routes.dart';
import '../../flutterbase.controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'chat.message.dart';

class ChatWidget extends StatefulWidget {
  @override
  _ChatWidgetState createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  ///
  final FlutterbaseController firebaseController = Get.find();

  FlutterbaseNotificationService fns = FlutterbaseNotificationService();

  ///
  CollectionReference chatRoom = Firestore.instance.collection('chatRoom');

  ///
  final TextEditingController textEditingController =
      new TextEditingController();

  ///
  final ScrollController listScrollController = new ScrollController();

  ///
  Map<String, dynamic> args = Get.arguments;

  var messages = [];

  @override
  void initState() {
    super.initState();
    if (firebaseController.notLoggedIn) {
      Timer(Duration(seconds: 1), () {
        Get.snackbar('Must Login first', 'Please Login to chat.');
      });
    }

    initChatRoom();
  }

  initChatRoom() async {
    /// Get the last 30 messagese from chat room.
    QuerySnapshot chats = await chatRoom
        .orderBy('timestamp', descending: true)
        .limit(30)
        .getDocuments();

    ///
    final docs = chats.documents;

    /// Save last 30 into variable.
    if (docs.length > 0) {
      docs.forEach(
        (doc) {
          var data = doc.data;
          data['id'] = doc.documentID;
          messages.add(data);
        },
      );
      setState(() {});
    }

    /// listen for a new message.
    chatRoom.orderBy('timestamp', descending: true).limit(1).snapshots().listen(
          (data) => data.documents.forEach(
            (doc) {
              var data = doc.data;
              data['id'] = doc.documentID;

              /// Don't add the last message twice.
              /// This is for
              ///   - when the chat messages are loaded for the first time
              ///   - and when user types a new message.
              if (data['id'] != messages[0]['id']) {
                messages.insert(0, data);
              }
              // messages.add(doc.data);
              setState(() {});
            },
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        key: ValueKey('chatWidgetColumn'),
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemBuilder: (context, index) => ChatMessage(messages[index]),
              itemCount: messages.length,
              reverse: true,
              controller: listScrollController,
            ),
          ),
          ChatInputBox(
            controller: textEditingController,
            onPressed: onSendMessage,
          )
        ],
      ),
    );
  }

  bool englishOnly(String content) {
    // print('englishOnly');
    String allowed =
        "‘’“” `1234567890-=~!@#\$%^&*()_+qwertyuiop[]\\QWERTYUIOP{}|asdfghjkl;\ASDFGHJKL:\"'zxcvbnm,./ZXCVBNM<>?";

    List<String> chars = content.split('');
    for (String char in chars) {
      if (allowed.indexOf(char) > -1) {
        /// fine
      } else {
        // print('char: $char');
        return false;
      }
    }
    return true;
  }

  void onSendMessage() async {
    if (firebaseController.notLoggedIn) {
      return alertLogin();
    }

    String content = textEditingController.text;

    if (!englishOnly(content.trim())) {
      Get.dialog(
        PlatformAlertDialog(
          title: Text('chatAlertTitle'.tr),
          content: Text('chatAlertEnglishOnly'.tr),
          actions: [
            PlatformButton(
              /// @TODO: uncomment line #153 then remove line #154.
              // child: Text('ok'.tr),
              child: Text('Ok'), 
              onPressed: () => Get.back(),
            )
          ],
        ),
      );
      return;
    }

    if (content.trim() != '') {
      textEditingController.clear();
      var data = {
        'uid': firebaseController.user.uid,

        /// displayName can be null. Especially when user set privacy on Apple sign in.
        'displayName': firebaseController.user.displayName ??
            firebaseController.user.email.split('@').first,
        'photoUrl': firebaseController.user.photoUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'content': content,
      };
      // print('add: $data');
      chatRoom.add(data);
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);

      fns.sendNotification('Chat Room', content);
    } else {
      Get.snackbar('Nothing to send', '');
    }
  }

  alertLogin() {
    Get.dialog(PlatformAlertDialog(
      title: Text('로그인'),
      content: Text('영어 채팅을 하기 위해서는 로그인을 해야 합니다. 로그인을 하시겠습니까?'),
      actions: [
        PlatformButton(
          onPressed: () {
            print('yes');
            Get.back();
            Get.toNamed(Routes.login);
          },
          child: Text('Yes'),
        ),
        PlatformButton(
          onPressed: () {
            print('No');
            Get.back();
          },
          child: Text('No'),
        ),
      ],
    ));
    return;
  }
}
