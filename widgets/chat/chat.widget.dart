import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:englishfun_v2/defines.dart';
import 'package:englishfun_v2/flutterbase_v2/widgets/chat/chat.input_box.dart';
import 'package:englishfun_v2/services/routes.dart';
import 'package:englishfun_v2/services/texts.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import '../../flutterbase.controller.dart';
import 'chat.message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatWidget extends StatefulWidget {
  @override
  _ChatWidgetState createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  ///
  final FlutterbaseController firebaseController = Get.find();

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
        "‘’“” `1234567890-=~!@#\$%^&*()_+qwertyuiop[]\\QWERTYUIOP{}|asdfghjkl;\ASDFGHJKL:\"zxcvbnm,./ZXCVBNM<>?";

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
          title: Text(Tx.chatAlertTitle),
          content: Text(Tx.chatAlertEnglishOnly),
          actions: [
            PlatformButton(
              child: Text(Tx.ok),
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

      sendNotification('Chat Room', content);
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

  Future<void> sendNotification(subject, title) async {
    print('SendNotification');
    final postUrl = 'https://fcm.googleapis.com/fcm/send';

    String toParams = "/topics/" + chatroomTopic;

    final data = jsonEncode({
      "notification": {"body": subject, "title": title},
      "priority": "high",
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "id": "1",
        "status": "done",
        "sound": 'default',
        "senderID": firebaseController.user.uid,
      },
      "to": "$toParams"
    });

    final headers = {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader:
          "key=AAAA043HfBE:APA91bH1a54jNrzpOiT3UPEkFUSCRr7V_CAnaHy39syAWQ4JqVzbPH3nfu12odfmSFTWAUG4VObV-LoQrSjfHnQU-3yPpaImMKFq59G15QMf8WIB0t_83C1w2wdzF98VbZmIX4Gw7IiN"
    };

    var dio = Dio();

    print('try sending notification');
    try {
      var response = await dio.post(
        postUrl,
        data: data,
        options: Options(
          headers: headers,
        ),
      );
      if (response.statusCode == 200) {
        // on success do
        print("notification success");
      } else {
        // on failure do
        print("notification failure");
      }
      return response.data;
    } catch (e) {
      print('Dio error in sendNotification');
      print(e);
    }

    // final response = await http.post(postUrl,
    //     body: json.encode(data),
    //     encoding: Encoding.getByName('utf-8'),
    //     headers: headers);
  }
}
