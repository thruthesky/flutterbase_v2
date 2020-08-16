import 'package:flutter/material.dart';

class ChatMessageName extends StatelessWidget {
  const ChatMessageName({
    Key key,
    @required this.data,
  }) : super(key: key);

  final data;

  @override
  Widget build(BuildContext context) {
    return Text(
      data['displayName'] ?? '',
      style: TextStyle(color: Colors.black54),
    );
  }
}
