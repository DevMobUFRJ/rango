import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rango/models/order.dart';

class Repository {
  final sellersRef = Firestore.instance.collection('sellers');
  final ordersRef = Firestore.instance.collection('orders');

  Future<DocumentSnapshot> getSeller(String uid) async {
    return sellersRef.document(uid).get();
  }

  Stream<DocumentSnapshot> getSellerAsStream(String uid) {
    return sellersRef.document(uid).snapshots();
  }

  Future<QuerySnapshot> getSellerCurrentMeals(String uid) async {
    return sellersRef.document(uid).collection('currentMeals').getDocuments();
  }

  Stream<QuerySnapshot> getSellerCurrentMealsAsStream(String uid) {
    return sellersRef.document(uid).collection('currentMeals').snapshots();
  }

  Future<DocumentReference> addOrder(Order order) {
    return ordersRef.add(order.toJson());
  }

  static Repository get instance => Repository(); // TODO Necessario?
}