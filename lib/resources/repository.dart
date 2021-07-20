import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rango/models/client.dart';
import 'package:rango/models/meals.dart';
import 'package:rango/models/order.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:rango/models/seller.dart';
import 'package:rango/utils/date_time.dart';
import 'package:rxdart/rxdart.dart';

class Repository {
  final sellersRef = FirebaseFirestore.instance.collection('sellers').withConverter<Seller>(
      fromFirestore: (snapshot, _) => Seller.fromJson(snapshot.data(), id: snapshot.id),
      toFirestore: (seller, _) => seller.toJson());
  final clientsRef = FirebaseFirestore.instance.collection('clients').withConverter<Client>(
      fromFirestore: (snapshot, _) => Client.fromJson(snapshot.data(), id: snapshot.id),
      toFirestore: (client, _) => client.toJson());
  final ordersRef = FirebaseFirestore.instance.collection('orders').withConverter<Order>(
      fromFirestore: (snapshot, _) => Order.fromJson(snapshot.data(), id: snapshot.id),
      toFirestore: (order, _) => order.toJson());
  CollectionReference<Meal> mealsRef(String sellerId) => sellersRef.doc(sellerId)
      .collection('meals').withConverter<Meal>(
      fromFirestore: (snapshot, _) => Meal.fromJson(snapshot.data(), id: snapshot.id),
      toFirestore: (meal, _) => meal.toJson());
  final geo = Geoflutterfire();
  final auth = FirebaseAuth.instance;

  User getCurrentUser() {
    return auth.currentUser;
  }

  Future<Position> getUserLocation() {
    return Geolocator.getCurrentPosition();
  }

  // Seller
  Future<void> createSeller(Seller seller) {
    return sellersRef.doc(seller.id).set(seller);
  }

  Stream<DocumentSnapshot<Seller>> getSeller(String uid) {
    return sellersRef.doc(uid).snapshots();
  }

  Future<DocumentSnapshot<Seller>> getSellerFuture(String uid) {
    return sellersRef.doc(uid).get();
  }

  Future<void> updateSeller(
      String uid, Map<String, dynamic> dataToUpdate) async {
    return sellersRef.doc(uid).update(dataToUpdate);
  }

  Stream<QuerySnapshot<Meal>> getSellerMeals(String sellerId) {
    return mealsRef(sellerId).snapshots();
  }

  Stream<DocumentSnapshot<Meal>> getMealFromSeller(
      String mealUid, String sellerId) {
    return mealsRef(sellerId).doc(mealUid).snapshots();
  }

  // Meals
  Future<String> createMeal(String sellerId, Map<String, dynamic> data) async {
    data['featured'] = false;
    var response = await sellersRef.doc(sellerId).collection('meals').add(data);
    return Future.value(response.id);
  }

  Future<void> updateMeal(
      String sellerId, String mealId, Map<String, dynamic> dataToUpdate) async {
    return sellersRef
        .doc(sellerId)
        .collection('meals')
        .doc(mealId)
        .update(dataToUpdate);
  }

  Future<void> deleteMeal(String sellerId, String mealId) async {
    try {
      await sellersRef
          .doc(sellerId)
          .update({'currentMeals.$mealId': FieldValue.delete()});
      await sellersRef.doc(sellerId).collection('meals').doc(mealId).delete();
    } catch (e) {
      throw e;
    }
  }

  Future<void> addMealToCurrent(mealId, sellerId) async {
    try {
      await sellersRef.doc(sellerId).update({
        'currentMeals.$mealId': {'featured': false}
      });
    } catch (e) {
      throw e;
    }
  }

  Future<void> removeMealFromCurrent(mealId, sellerId) async {
    try {
      await sellersRef
          .doc(sellerId)
          .update({'currentMeals.$mealId': FieldValue.delete()});
    } catch (e) {
      throw e;
    }
  }

  Future<void> toggleMealFeatured(String mealId, Seller seller) async {
    try {
      await sellersRef.doc(seller.id).update({
        'currentMeals.$mealId.featured': !seller.currentMeals[mealId].featured
      });
    } catch (e) {
      throw e;
    }
  }

  // Orders
  CombineLatestStream<dynamic, List<QueryDocumentSnapshot<Order>>> getOpenOrdersFromSeller(String sellerId) {
    // Retorna os pedidos em aberto do dia anterior também, caso haja um pedido perto de meia noite
    var yesterday = ordersRef
        .where('sellerId', isEqualTo: sellerId)
        .where('requestedAt', isGreaterThanOrEqualTo: startOfDay().subtract(Duration(days: 1)))
        .where('requestedAt', isLessThanOrEqualTo: endOfDay().subtract(Duration(days: 1)))
        .where('status', whereIn: ['requested', 'reserved'])
        .orderBy('requestedAt')
        .snapshots();

    var today = ordersRef
        .where('sellerId', isEqualTo: sellerId)
        .where('requestedAt', isGreaterThanOrEqualTo: startOfDay())
        .where('requestedAt', isLessThanOrEqualTo: endOfDay())
        .where('status', whereIn: ['requested', 'reserved'])
        .orderBy('requestedAt')
        .snapshots();

    var combined = CombineLatestStream.combine2<
        QuerySnapshot<Order>,
        QuerySnapshot<Order>,
        List<QueryDocumentSnapshot<Order>>
    >(yesterday, today, (a, b) {
      return a.docs + b.docs;
    });

    return combined;
  }

  Stream<QuerySnapshot<Order>> getClosedOrdersFromSeller(String sellerId) {
    return ordersRef
        .where('sellerId', isEqualTo: sellerId)
        .where('requestedAt', isGreaterThanOrEqualTo: startOfDay())
        .where('requestedAt', isLessThanOrEqualTo: endOfDay())
        .where('status', isEqualTo: 'sold')
        .orderBy('requestedAt', descending: true)
        .snapshots();
  }

  Future<void> reserveOrderTransaction(Order order) async {
    try {
      return await FirebaseFirestore.instance
          .runTransaction((transaction) async {
        DocumentReference<Meal> mealRef =
            mealsRef(order.sellerId).doc(order.mealId);
        DocumentReference<Order> orderRef = ordersRef.doc(order.id);

        DocumentSnapshot<Meal> snapshot = await transaction.get<Meal>(mealRef);
        int quantity = snapshot.data().quantity;

        if (quantity - order.quantity >= 0) {
          transaction.update(mealRef, {'quantity': quantity - order.quantity});
          transaction.update(
              orderRef, {'status': 'reserved', 'reservedAt': Timestamp.now()});
        } else {
          switch (quantity) {
            case 0:
              throw ("Você não possui mais quentinhas dessa. Cancele o pedido ou aumente o número de quentinhas, caso tenha mais.");
              break;
            case 1:
              throw ("Você só possui $quantity unidade dessa quentinha disponível. Cancele o pedido ou aumente o número de quentinhas, caso tenha mais.");
              break;
            default:
              throw ("Você só possui $quantity unidades dessa quentinha disponíveis. Cancele o pedido ou aumente o número de quentinhas, caso tenha mais.");
          }
        }
      });
    } catch (e) {
      throw e;
    }
  }

  Future<void> undoReserveOrderTransaction(Order order) async {
    try {
      return await FirebaseFirestore.instance
          .runTransaction((transaction) async {
        DocumentReference<Meal> mealRef =
            mealsRef(order.sellerId).doc(order.mealId);
        DocumentReference<Order> orderRef = ordersRef.doc(order.id);

        DocumentSnapshot<Meal> snapshot = await transaction.get<Meal>(mealRef);
        int quantity = snapshot.data().quantity;

        transaction.update(mealRef, {'quantity': quantity + order.quantity});
        transaction
            .update(orderRef, {'status': 'requested', 'reservedAt': null});
      });
    } catch (e) {
      throw e;
    }
  }

  Future<void> sellOrder(String orderUid) async {
    try {
      ordersRef
          .doc(orderUid)
          .update({'status': 'sold', 'soldAt': Timestamp.now()});
    } catch (e) {
      throw e;
    }
  }

  Future<void> undoSellOrder(String orderUid) async {
    try {
      ordersRef.doc(orderUid).update({'status': 'reserved', 'soldAt': null});
    } catch (e) {
      throw e;
    }
  }

  Future<void> openStore(String sellerId) async {
    try {
      DocumentReference<Seller> sellerRef = sellersRef.doc(sellerId);
      Map<String, dynamic> dataToUpdate = {};
      dataToUpdate['active'] = true;
      sellerRef.update(dataToUpdate);
    } catch (e) {
      throw e;
    }
  }

  Future<void> closeStore(String sellerId) async {
    try {
      DocumentReference<Seller> sellerRef = sellersRef.doc(sellerId);
      Map<String, dynamic> dataToUpdate = {};
      dataToUpdate['active'] = false;
      sellerRef.update(dataToUpdate);
    } catch (e) {
      throw e;
    }
  }

  Future<void> cancelOrder(Order order) async {
    try {
      return await FirebaseFirestore.instance
          .runTransaction((transaction) async {
        DocumentReference<Order> orderRef = ordersRef.doc(order.id);

        if (order.status == 'reserved') {
          DocumentReference<Meal> mealRef =
              mealsRef(order.sellerId).doc(order.mealId);
          DocumentSnapshot<Meal> snapshot =
              await transaction.get<Meal>(mealRef);
          int quantity = snapshot.data().quantity;

          transaction.update(mealRef, {'quantity': quantity + order.quantity});
        }

        transaction.update(
            orderRef, {'status': 'canceled', 'canceledAt': Timestamp.now()});
      });
    } catch (e) {
      throw e;
    }
  }

  Stream<QuerySnapshot<Order>> getSoldOrdersFromSeller(String sellerId, {int lastDays}) {
    if (lastDays != null && lastDays > 0) {
      return ordersRef
          .where('sellerId', isEqualTo: sellerId)
          .where('status', isEqualTo: 'sold')
          .where('requestedAt', isGreaterThanOrEqualTo: DateTime.now().subtract(Duration(days: lastDays)))
          .orderBy('requestedAt')
          .snapshots();
    }
    return ordersRef
        .where('sellerId', isEqualTo: sellerId)
        .where('status', isEqualTo: 'sold')
        .orderBy('requestedAt')
        .snapshots();
  }

  Stream<QuerySnapshot<Order>> getSoldOrdersFromClient(String sellerId, String clientId, {int lastDays}) {
    if (lastDays != null && lastDays > 0) {
      return ordersRef
          .where('sellerId', isEqualTo: sellerId)
          .where('clientId', isEqualTo: clientId)
          .where('status', isEqualTo: 'sold')
          .where('requestedAt', isGreaterThanOrEqualTo: DateTime.now().subtract(Duration(days: lastDays)))
          .snapshots();
    }
    return ordersRef
        .where('sellerId', isEqualTo: sellerId)
        .where('clientId', isEqualTo: clientId)
        .where('status', isEqualTo: 'sold')
        .snapshots();
  }

  Stream<QuerySnapshot<Order>> getLastWeekOrders(String sellerId) {
    return ordersRef
        .where('sellerId', isEqualTo: sellerId)
        .where('status', isEqualTo: 'sold')
        .where('requestedAt', isGreaterThanOrEqualTo: DateTime.now().subtract(Duration(days: 7)))
        .snapshots();
  }

  // Client
  Future<DocumentSnapshot<Client>> getClient(String uid) async {
    return clientsRef.doc(uid).get();
  }

  Stream<DocumentSnapshot<Client>> getClientStream(String uid) {
    return clientsRef.doc(uid).snapshots();
  }

  static Repository get instance => Repository();
}
