import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

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
          constraints: BoxConstraints(maxWidth: 0.6.wp),
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
          margin: EdgeInsets.symmetric(vertical: 3, horizontal: 8),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                message,
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 28.nsp,
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
