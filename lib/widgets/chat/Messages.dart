import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rango/models/message.dart';
import 'package:rango/widgets/chat/ChatBubble.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Messages extends StatelessWidget {
  final CollectionReference<Object> chatReference;
  final ScrollController controller;

  Messages(this.chatReference, this.controller);

  @override
  Widget build(BuildContext context) {
    return chatReference == null
        ? Container()
        : StreamBuilder(
            stream:
                chatReference.orderBy('sentAt', descending: true).snapshots(),
            builder: (ctx, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData ||
                  snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Container(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                );
              }
              return ListView.builder(
                reverse: true,
                itemCount: snapshot.data.docs.length,
                controller: controller,
                itemBuilder: (ctxListView, index) {
                  Message message =
                      Message.fromJson(snapshot.data.docs[index].data());
                  return ChatBubble(
                    message.text,
                    message.sender == "client" ? true : false,
                  );
                },
              );
            },
          );
  }
}
