// import 'package:chatApp/widgets/chat/message_bubble.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rango/models/message.dart';
import 'package:rango/widgets/chat/ChatBubble.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class Messages extends StatelessWidget {
  final List<Message> messages;

  Messages(this.messages);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      itemCount: messages.length,
      itemBuilder: (ctx, index) => ChatBubble(
        messages[index].text,
        messages[index].sender == 'loja' ? false : true,
        key: ValueKey(messages[index].hashCode),
      ),
    );
  }
}
