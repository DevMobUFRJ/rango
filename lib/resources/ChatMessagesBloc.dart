import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rango/resources/repository.dart';
import 'package:rxdart/rxdart.dart';

class ChatMessagesBloc {
  List<DocumentSnapshot> documentList;

  BehaviorSubject<List<DocumentSnapshot>> messagesController;

  ChatMessagesBloc() {
    messagesController = BehaviorSubject<List<DocumentSnapshot>>();
  }

  Stream<List<DocumentSnapshot>> get messagesStream =>
      messagesController.stream;

  Future fetchFirstList(String docId) async {
    try {
      var snapShot = Repository.instance.getLastChatMessages(docId);
      snapShot.map
      messagesController.sink.add(documentList);
    } on SocketException {
      messagesController.sink.addError(SocketException("Sem conexão"));
    } catch (e) {
      print(e);
      messagesController.sink.addError(e);
    }
  }

  fetchNextMessages(String docId) async {
    try {
      List<DocumentSnapshot> newDocumentList = await Repository.instance
          .getNextTenChatMessages(docId, documentList[documentList.length - 1]);
      documentList.addAll(newDocumentList);
      messagesController.sink.add(documentList);
    } on SocketException {
      messagesController.sink.addError(SocketException("Sem conexão"));
    } catch (error) {
      messagesController.sink.addError(error);
    }
  }

  void dispose() {
    messagesController.close();
  }
}
