import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatMessageDateTime extends StatelessWidget {
  const ChatMessageDateTime(
    this.data, {
    Key key,
  }) : super(key: key);

  final data;

  @override
  Widget build(BuildContext context) {
    Timestamp d = data['timestamp'];
    return Container(
      child: Text(
        DateFormat('dd MMM kk:mm')
            .format(DateTime.fromMillisecondsSinceEpoch(d.seconds * 1000)),
        style: TextStyle(
          fontSize: 12.0,
          fontStyle: FontStyle.italic,
          color: Colors.black38,
        ),
      ),
    );
  }
}
