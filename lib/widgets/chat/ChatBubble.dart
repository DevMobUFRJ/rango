import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final Key key;

  ChatBubble(
    this.message,
    this.isMe, {
    this.key,
  });

  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFF9B152);
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        Container(
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.45),
          decoration: BoxDecoration(
            color: isMe ? Theme.of(context).accentColor : yellow,
            borderRadius: BorderRadius.only(
              topLeft: !isMe ? Radius.circular(0) : Radius.circular(8),
              topRight: Radius.circular(8),
              bottomLeft: Radius.circular(8),
              bottomRight: isMe ? Radius.circular(0) : Radius.circular(8),
            ),
          ),
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          margin: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
