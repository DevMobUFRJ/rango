import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rango/models/message.dart';
import 'package:rango/models/seller.dart';
import 'package:rango/resources/repository.dart';
import 'package:rango/widgets/chat/Messages.dart';
import 'package:rango/widgets/chat/NewMessage.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  final String sellerId;
  final String sellerName;

  ChatScreen(this.sellerId, this.sellerName, {Key key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  Seller _seller;
  CollectionReference chatReference;
  String userId;
  String docId;

  @override
  initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser.uid;
    docId = '${userId}_${widget.sellerId}';
    _getSeller(widget.sellerId);
    chatReference = db.collection('chat').doc(docId).collection('messages');
  }

  Future<void> _getSeller(String sellerId) async {
    DocumentSnapshot<Seller> sellerDoc =
        await Repository.instance.getSellerFuture(sellerId);
    setState(() => _seller = sellerDoc.data());
  }

  Future<void> _addNewMessage(Message newMessage) async {
    try {
      chatReference.add(newMessage.toJson());
      if (_seller.deviceToken != null &&
          _seller.notificationSettings != null &&
          _seller.notificationSettings.messages == true) {
        _sendNewMessageNotification();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 2),
          content: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Ocorreu um erro ao enviar a mensagem',
              textAlign: TextAlign.center,
            ),
          ),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      print(e);
    }
  }

  Future<void> _sendNewMessageNotification() async {
    try {
      var data = (<String, String>{
        'id': '1',
        'channelId': '2',
        'channelName': 'Chat',
        'channelDescription': 'Canal usado para notificações do chat',
        'status': 'done',
        'description':
            '${FirebaseAuth.instance.currentUser.displayName} te enviou uma mensagem no chat!',
        'payload':
            'chat/$userId/${FirebaseAuth.instance.currentUser.displayName}',
        'title': 'Você recebeu uma nova mensagem!',
      });
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Authorization': 'key=${const String.fromEnvironment('MESSAGING_KEY')}',
          'content-type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode(<String, dynamic>{
          'priority': 'high',
          'data': data,
          'to': _seller.deviceToken,
        }),
      );
    } catch (error) {
      print(error);
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
              child: Messages(chatReference),
            ),
            NewMessage(_addNewMessage),
          ],
        ),
      ),
    );
  }
}
