import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rango/models/message.dart';

class NewMessage extends StatefulWidget {
  final Function addNewMessage;
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
      sentAt: new Timestamp.fromDate(new DateTime.now()),
    ));
    setState(
      () => {
        _enteredMessage = '',
        _controller.clear(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                textCapitalization: TextCapitalization.sentences,
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
