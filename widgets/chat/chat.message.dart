import 'package:flutter/material.dart';
import 'package:get/get.dart';

import './chat.message.others.dart';
import '../../flutterbase.controller.dart';

class ChatMessage extends StatelessWidget {
  ChatMessage(
    this.data, {
    Key key,
  }) : super(key: key);

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
