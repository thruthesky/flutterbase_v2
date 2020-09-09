import 'package:flutter/material.dart';
import '../../../defines.dart';
import './chat.message.content.dart';
import './chat.message.date_time.dart';
import './chat.message.name.dart';
import './chat.message.user_icon.dart';

class ChatMessageOthers extends StatelessWidget {
  ChatMessageOthers(this.data);
  final data;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: md),
                child: ChatMessageUserIcon(data: data),
              ),
              SizedBox(width: sm),
              Expanded(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ChatMessageName(data: data),
                          SizedBox(width: xs),
                          ChatMessageDateTime(data),
                        ],
                      ),
                      ChatMessageContent(data: data),
                      SizedBox(height: xs),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.red,
          ),
          flex: 1,
        )
      ],
    );
  }
}
