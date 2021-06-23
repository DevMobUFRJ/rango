import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rango/models/client.dart';
import 'package:rango/models/message.dart';
import 'package:rango/widgets/chat/Messages.dart';
import 'package:rango/widgets/chat/NewMessage.dart';

class ChatScreen extends StatefulWidget {
  final Client client;

  ChatScreen(this.client);

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
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          widget.client.name,
          maxLines: 1,
          style: GoogleFonts.montserrat(
            color: Theme.of(context).accentColor,
            fontSize: 42.nsp,
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
