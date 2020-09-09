import '../../../widgets/commons/common.image.dart';
import 'package:flutter/material.dart';

class ChatMessageUserIcon extends StatelessWidget {
  const ChatMessageUserIcon({
    Key key,
    @required this.data,
  }) : super(key: key);

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: CommonImage(
        data['photoUrl'],
        defaultChild: Image.asset(
          'assets/images/anonymous.jpg',
          width: 36,
          height: 36,
        ),
        width: 36,
        height: 36,
      ),
    );
  }
}
