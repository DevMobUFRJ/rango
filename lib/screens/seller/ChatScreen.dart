import 'package:flutter/material.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.seller.name,
          style: GoogleFonts.montserrat(color: Theme.of(context).accentColor),
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
