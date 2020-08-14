import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatInputBox extends StatefulWidget {
  ChatInputBox({
    @required this.controller,
    @required this.onPressed,
  });

  final TextEditingController controller;
  final Function onPressed;

  @override
  _ChatInputBoxState createState() => _ChatInputBoxState();
}

class _ChatInputBoxState extends State<ChatInputBox> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          Padding(padding: EdgeInsets.only(left: 8.0)),
          // Edit text
          Flexible(
            child: TextField(
              inputFormatters: [
                new FilteringTextInputFormatter.allow(RegExp(
                    // "[!-~]"
                    "[ A-Za-z0-9`~!@#\$%^&*()\\-=+{}\\[\\];:\'\"|\\\\,<.>/?]"))
              ],
              style: TextStyle(fontSize: 16.0),
              controller: widget.controller,
              decoration: InputDecoration.collapsed(
                hintText: 'Type your message...',
              ),
              onChanged: (value) {
                // Regex.Replace(
                //     value,
                //     "[ A-Za-z0-9`~!@#\$%^&*()\\-=+{}\\[\\];:\'\"|\\\\,<.>/?]",
                //     '');
                // String newValue = value.replaceAllMapped(
                //     RegExp(
                //         "[ A-Za-z0-9`~!@#\$%^&*()\\-=+{}\\[\\];:\'\"|\\\\,<.>/?]"),
                //     (match) {
                //   print(match.group(0));
                //   return '"${match.group(0)}"';
                // });

                // print(value);
                // print(newValue);
              },
            ),
          ),

          // Button send message
          IconButton(
              padding: EdgeInsets.all(12.0),
              icon: Icon(Icons.send),
              onPressed: widget
                  .onPressed // () => onSendMessage(textEditingController.text, 0),
              ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: new BoxDecoration(
        border: new Border(top: new BorderSide(width: 0.5)),
        color: Colors.white,
      ),
    );
  }
}
