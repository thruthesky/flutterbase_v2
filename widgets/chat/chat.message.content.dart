import '../../../defines.dart';
import 'package:flutter/material.dart';

class ChatMessageContent extends StatelessWidget {
  const ChatMessageContent({
    Key key,
    @required this.data,
  }) : super(key: key);

  final data;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 2, bottom: 2),
      padding: EdgeInsets.all(xs),
      child: Text(
        data['content'],
        style: TextStyle(
          color: Colors.black87,
        ),
      ),
      decoration: BoxDecoration(
          color: Colors.blue[100], borderRadius: BorderRadius.circular(8.0)),
    );
  }
}
