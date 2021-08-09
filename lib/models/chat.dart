import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rango/models/message.dart';

class Chat {
  List<Message> messages;
  String id;
  String clientName;
  String clientId;
  String sellerName;
  String sellerId;
  String lastMessageSent;
  Timestamp lastMessageSentAt;

  Chat({
    @required this.messages,
    @required this.id,
    @required this.clientId,
    @required this.clientName,
    @required this.sellerId,
    @required this.sellerName,
    @required this.lastMessageSent,
    @required this.lastMessageSentAt,
  });

  Chat.fromJson(Map<String, dynamic> json, {String id})
      : id = id,
        clientId = json['clientId'],
        clientName = json['clientName'],
        sellerId = json['sellerId'],
        sellerName = json['sellerName'],
        lastMessageSent = json['lastMessageSent'],
        lastMessageSentAt = json['lastMessageSentAt'],
        messages = json['messages'];

  Map<String, dynamic> toJson() => {
        'clientId': clientId,
        'clientName': clientName,
        'sellerId': sellerId,
        'sellerName': sellerName,
        'lastMessageSent': lastMessageSent,
        'lastMessageSentAt': lastMessageSentAt,
        'messages': messages,
      };
}
