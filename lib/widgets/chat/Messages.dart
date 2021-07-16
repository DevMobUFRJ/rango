import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:rango/models/message.dart';
import 'package:rango/widgets/chat/ChatBubble.dart';

class Messages extends StatelessWidget {
  final CollectionReference<Object> chatReference;

  Messages(this.chatReference);

  @override
  Widget build(BuildContext context) {
    return PaginateFirestore(
      query: chatReference.orderBy('sentAt', descending: true),
      itemBuilderType: PaginateBuilderType.listView,
      emptyDisplay: Container(),
      initialLoader: Center(
        child: Container(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(
            color: Theme.of(context).accentColor,
          ),
        ),
      ),
      itemsPerPage: 10,
      reverse: true,
      isLive: true,
      itemBuilder: (index, ctx, snapshot) {
        Message message = Message.fromJson(snapshot.data());
        return ChatBubble(
          message.text,
          message.sender == "seller" ? true : false,
        );
      },
    );
  }
}
