import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart' show Firestore, CollectionReference, DocumentReference, DocumentSnapshot, QuerySnapshot;

final _database = Firestore.instance;

class Bloc {
  final _seller = StreamController();

  CollectionReference get sellersCollection => _database.collection("sellers");
  CollectionReference get ordersCollection => _database.collection("orders");
  CollectionReference get clientsCollection => _database.collection("clients");

  DocumentReference sellerDocument (String sellerId) => sellersCollection.document(sellerId);
  Stream<DocumentSnapshot> seller (String sellerId) => sellerDocument(sellerId).snapshots();
  Stream<QuerySnapshot> sellerMeals (String sellerId) => sellerDocument(sellerId).collection("meals").getDocuments().asStream();

  dispose() {
    _seller.close();
  }
}

final bloc = Bloc();