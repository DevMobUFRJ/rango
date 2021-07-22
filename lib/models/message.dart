import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String text;
  String sender;
  Timestamp sentAt;

  Message({
    this.text,
    this.sender,
    this.sentAt,
  });

  Message.fromJson(Map<String, dynamic> json)
      : text = json['message'],
        sender = json['sentBy'],
        sentAt = json['sentAt'];

  Map<String, dynamic> toJson() => {
        'message': text,
        'sentBy': sender,
        'sentAt': sentAt,
      };
}
