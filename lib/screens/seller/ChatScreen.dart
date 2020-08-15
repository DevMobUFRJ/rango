import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rango/models/message.dart';
import 'package:rango/models/seller.dart';
import 'package:rango/widgets/chat/Messages.dart';
import 'package:rango/widgets/chat/NewMessage.dart';

class ChatScreen extends StatefulWidget {
  final Seller seller;

  ChatScreen(this.seller);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> messages = [
    Message(sender: 'loja', text: 'Oi, tudo bem?'),
  ];

  void _addNewMessage(Message newMessage) {
    setState(() {
      messages.insert(0, newMessage);
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334);
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          widget.seller.name,
          maxLines: 1,
          style: GoogleFonts.montserrat(
            color: Theme.of(context).accentColor,
            fontSize: 35.nsp,
          ),
        ),
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Messages(messages),
            ),
            NewMessage(_addNewMessage),
          ],
        ),
      ),
    );
  }
}
