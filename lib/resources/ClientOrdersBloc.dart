import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rango/resources/repository.dart';
import 'package:rxdart/rxdart.dart';

class ClientOrdersBloc {
  List<DocumentSnapshot> documentList;

  BehaviorSubject<List<DocumentSnapshot>> ordersController;

  ClientOrdersBloc() {
    ordersController = BehaviorSubject<List<DocumentSnapshot>>();
  }

  Stream<List<DocumentSnapshot>> get ordersStream => ordersController.stream;

  final ordersRef = FirebaseFirestore.instance.collection('orders');

  Future fetchFirstList(String clientId) async {
    try {
      documentList =
          await Repository.instance.getFirstOrdersFromClient(clientId);
      ordersController.sink.add(documentList);
    } on SocketException {
      ordersController.sink.addError(SocketException("Sem conexão"));
    } catch (e) {
      print(e);
      ordersController.sink.addError(e);
    }
  }

  fetchNextOrders(String clientId) async {
    try {
      List<DocumentSnapshot> newDocumentList = await Repository.instance
          .getNextTenOrdersFromClient(
              clientId, documentList[documentList.length - 1]);
      documentList.addAll(newDocumentList);
      ordersController.sink.add(documentList);
    } on SocketException {
      ordersController.sink.addError(SocketException("Sem conexão"));
    } catch (error) {
      ordersController.sink.addError(error);
    }
  }

  void dispose() {
    ordersController.close();
  }
}
