import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rango/models/message.dart';

class NewMessage extends StatefulWidget {
  Function addNewMessage;

  NewMessage(this.addNewMessage);

  @override
  _NewMessageState createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  var _enteredMessage = '';
  final _controller = new TextEditingController();

  void _sendMessage() async {
    widget.addNewMessage(Message(
      text: _controller.text.trim(),
      sender: 'client',
    ));
    setState(() => {_enteredMessage = '', _controller.clear()});
    // final user = await FirebaseAuth.instance.currentUser();
    // final userData =
    //     await Firestore.instance.collection('users').document(user.uid).get();
    // Firestore.instance.collection('chat').add({
    //   'text': _enteredMessage,
    //   'createdAt': Timestamp.now(),
    //   'userId': user.uid,
    //   'username': userData['username'],
    //   'userImage': userData['image_url'],
    // });
    // setState(() => _enteredMessage = '');
    // _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334);
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(8),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            flex: 4,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              child: TextField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Digite aqui...',
                  border: InputBorder.none,
                ),
                onChanged: (value) => setState(() => _enteredMessage = value),
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: Container(
              width: 45,
              height: 45,
              child: IconButton(
                color: Theme.of(context).accentColor,
                icon: Icon(Icons.send, size: 58.nsp),
                onPressed: _enteredMessage.trim().isEmpty ? null : _sendMessage,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
