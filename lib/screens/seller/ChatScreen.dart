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
  final String sellerId;
  final String sellerName;

  ChatScreen(this.sellerId, this.sellerName, {Key key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  CollectionReference chatReference;
  ScrollController controller = ScrollController();
  String userId;
  String docId;

  @override
  initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser.uid;
    docId = '${userId}_${widget.sellerId}';
    chatReference = db.collection('chat').doc(docId).collection('messages');
    controller.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {}
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
          widget.sellerName,
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
              child: Messages(chatReference, controller),
            ),
            NewMessage(_addNewMessage),
          ],
        ),
      ),
    );
  }
}
