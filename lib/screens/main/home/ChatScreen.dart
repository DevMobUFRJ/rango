import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rango/models/message.dart';
import 'package:rango/widgets/chat/Messages.dart';
import 'package:rango/widgets/chat/NewMessage.dart';

class ChatScreen extends StatefulWidget {
  final String clientId;
  final String clientName;

  ChatScreen(
    this.clientId,
    this.clientName,
  );

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  CollectionReference chatReference;

  String userId;
  String docId;

  @override
  initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser.uid;
    docId = '${widget.clientId}_$userId';
    chatReference = db.collection('chat').doc(docId).collection('messages');
  }

  Future<void> _addNewMessage(Message newMessage) async {
    try {
      print(chatReference);
      chatReference.add(newMessage.toJson());
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          widget.clientName,
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
              child: Messages(chatReference),
            ),
            NewMessage(_addNewMessage),
          ],
        ),
      ),
    );
  }
}
