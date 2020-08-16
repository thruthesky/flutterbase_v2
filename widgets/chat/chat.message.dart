import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:englishfun_v2/defines.dart';
import 'package:englishfun_v2/flutterbase_v2/widgets/chat/chat.message.others.dart';
import 'package:englishfun_v2/widgets/commons/common.image.dart';
import '../../flutterbase.controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatMessage extends StatelessWidget {
  ChatMessage(this.data);

  final Map<String, dynamic> data;
  final FlutterbaseController _controller = Get.find();
  @override
  Widget build(BuildContext context) {
    if (data['uid'] == _controller.user.uid) {
      // Right (my message)
      return Row(
        children: <Widget>[
          Container(
            child: Text(
              data['content'],
            ),
            padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
            width: 200.0,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8.0)),
            margin: EdgeInsets.only(bottom: 10.0, right: 10.0),
          )
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      return ChatMessageOthers(data);
    }
  }
}
