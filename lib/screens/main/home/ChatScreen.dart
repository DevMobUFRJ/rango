import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rango/models/client.dart';
import 'package:rango/models/message.dart';
import 'package:rango/resources/repository.dart';
import 'package:rango/screens/main/home/ClientProfile.dart';
import 'package:rango/widgets/chat/Messages.dart';
import 'package:http/http.dart' as http;
import 'package:rango/widgets/chat/NewMessage.dart';

class ChatScreen extends StatefulWidget {
  final String clientId;
  final String clientName;

  ChatScreen(this.clientId, this.clientName, {Key key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  DocumentReference chatReference;
  CollectionReference messagesReference;
  Client _client;
  String userId;
  String docId;

  @override
  initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser.uid;
    docId = '${widget.clientId}_$userId';
    _getClient();
    chatReference = db.collection('chat').doc(docId);
    messagesReference = chatReference.collection('messages');
  }

  Future<void> _getClient() async {
    var clientDoc = await Repository.instance.getClient(widget.clientId);
    setState(() => _client = clientDoc.data());
  }

  Future<void> _addNewMessage(Message newMessage) async {
    try {
      await messagesReference.add(newMessage.toJson());
      Map<String, dynamic> dataToUpdate = {};
      dataToUpdate['lastMessageSentAt'] = newMessage.sentAt;
      dataToUpdate['lastMessageSent'] = newMessage.text;
      await chatReference.update(dataToUpdate);
      if (_client.deviceToken != null &&
          _client.clientNotificationSettings != null &&
          _client.clientNotificationSettings.messages == true) {
        _sendNewMessageNotification();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).errorColor,
          content: AutoSizeText(
            'Erro ao enviar mensagem',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(),
          ),
          duration: Duration(seconds: 2),
        ),
      );
      print(e);
    }
  }

  Future<void> _sendNewMessageNotification() async {
    var name = FirebaseAuth.instance.currentUser.displayName;
    if (name == '') {
      name = 'Um vendedor';
    }
    try {
      var data = (<String, String>{
        'id': '2',
        'channelId': '2',
        'channelName': 'Chat',
        'channelDescription': 'Canal usado para notificações do chat',
        'status': 'done',
        'description': '$name te enviou uma mensagem no chat.',
        'payload': 'chat/$userId/$name',
        'title': 'Você recebeu uma nova mensagem!',
      });
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Authorization':
              'key=${const String.fromEnvironment('MESSAGING_KEY')}',
          'content-type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode(<String, dynamic>{
          'priority': 'high',
          'data': data,
          'to': _client.deviceToken,
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
        title: GestureDetector(
          onTap: () => pushNewScreen(
            context,
            screen: ClientProfile(_client.id),
            withNavBar: false,
          ),
          child: AutoSizeText(
            widget.clientName,
            maxLines: 1,
            style: GoogleFonts.montserrat(
              color: Theme.of(context).accentColor,
              fontSize: 42.nsp,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Messages(messagesReference),
            ),
            NewMessage(_addNewMessage),
          ],
        ),
      ),
    );
  }
}
