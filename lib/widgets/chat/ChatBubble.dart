import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    ScreenUtil.init(context, width: 750, height: 1334);
    const yellow = Color(0xFFF9B152);
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        Container(
          constraints: BoxConstraints(maxWidth: 0.45.wp),
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
              AutoSizeText(
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
