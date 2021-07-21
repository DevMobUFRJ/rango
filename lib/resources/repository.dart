import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:rango/models/client.dart';
import 'package:rango/models/meals.dart';
import 'package:rango/models/order.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:rango/models/seller.dart';
import 'package:rango/resources/rangeChangeNotifier.dart';
import 'package:rango/utils/constants.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class Repository {
  final cleanSellersRef = FirebaseFirestore.instance.collection('sellers');
  final sellersRef = FirebaseFirestore.instance.collection('sellers').withConverter<Seller>(
    fromFirestore: (snapshot, _) => Seller.fromJson(snapshot.data(), id: snapshot.id),
    toFirestore: (seller, _) => seller.toJson(),
  );
  final clientsRef = FirebaseFirestore.instance.collection('clients').withConverter<Client>(
    fromFirestore: (snapshot, _) => Client.fromJson(snapshot.data(), id: snapshot.id),
    toFirestore: (client, _) => client.toJson(),
  );
  final ordersRef = FirebaseFirestore.instance.collection('orders').withConverter<Order>(
    fromFirestore: (snapshot, _) => Order.fromJson(snapshot.data(), id: snapshot.id),
    toFirestore: (order, _) => order.toJson(),
  );
  CollectionReference<Meal> mealsRef(String sellerId) => sellersRef.doc(sellerId).collection('meals').withConverter<Meal>(
    fromFirestore: (snapshot, _) => Meal.fromJson(snapshot.data(), id: snapshot.id),
    toFirestore: (meal, _) => meal.toJson(),
  );
  final chatRef = FirebaseFirestore.instance.collection('chat');
  final geo = Geoflutterfire();
  final auth = FirebaseAuth.instance;
  final currentUser = FirebaseAuth.instance.currentUser;

  User getCurrentUser() {
    return auth.currentUser;
  }

  // Seller
  Stream<DocumentSnapshot<Seller>> getSeller(String uid) {
    return sellersRef.doc(uid).snapshots();
  }

  Future<DocumentSnapshot<Seller>> getSellerFuture(String uid) {
    return sellersRef.doc(uid).get();
  }

  Stream<QuerySnapshot<Seller>> getFavoriteSellers(List<String> favorites) {
    // Essa query whereIn tem o limite de 10 items
    return sellersRef
        .where(FieldPath.documentId, whereIn: favorites)
        .snapshots();
  }

  // Client
  Stream<DocumentSnapshot<Client>> getClientStream(String uid) {
    return clientsRef.doc(uid).snapshots();
  }

  Future<void> updateClient(
      String uid, Map<String, dynamic> dataToUpdate) async {
    return clientsRef.doc(uid).update(dataToUpdate);
  }

  Future<void> addSellerToClientFavorites(String clientId, String sellerId) {
    return clientsRef.doc(clientId).update({
      'favoriteSellers': FieldValue.arrayUnion([sellerId])
    });
  }

  Future<void> removeSellerFromClientFavorites(
      String clientId, String sellerId) {
    return clientsRef.doc(clientId).update({
      'favoriteSellers': FieldValue.arrayRemove([sellerId])
    });
  }

  // Orders
  Future<void> addOrderTransaction(Order order) async {
    try {
      return await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentReference<Meal> mealRef = mealsRef(order.sellerId).doc(order.mealId);
        DocumentSnapshot<Meal> snapshot = await transaction.get<Meal>(mealRef);

        int quantity = snapshot.data().quantity;
        if (quantity < order.quantity) {
          throw ('Não há quentinhas suficientes para o seu pedido. Quantidade disponível: $quantity');
        } else {
          await ordersRef.add(order);
        }
      });
    } catch (e) {
      throw e;
    }
  }

  Future<void> cancelOrderTransaction(Order order) async {
    try {
      return await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentReference<Order> orderRef = ordersRef.doc(order.id);

        if (order.status == 'reserved') {
          DocumentReference<Meal> mealRef = mealsRef(order.sellerId).doc(order.mealId);
          DocumentSnapshot<Meal> snapshot = await transaction.get<Meal>(mealRef);
          int quantity = snapshot.data().quantity;
          transaction.update(mealRef, {'quantity': quantity + order.quantity});
        }
        transaction.update(
          orderRef,
          {'status': 'canceled', 'canceledAt': Timestamp.now()}
        );
      });
    } catch (e) {
      throw e;
    }
  }

  Stream<QuerySnapshot> getOrdersFromClient(String clientId, {int limit}) {
    if (limit != null && limit > 0) {
      return ordersRef
          .where('clientId', isEqualTo: clientId)
          .where('status', isEqualTo: 'sold')
          .orderBy('requestedAt', descending: true)
          .limit(limit)
          .snapshots();
    }
    return ordersRef
        .where('clientId', isEqualTo: clientId)
        .where('status', isEqualTo: 'sold')
        .orderBy('requestedAt', descending: true)
        .snapshots();
  }

  // Meals
  Stream<DocumentSnapshot<Meal>> getMealFromSeller(String mealUid, String sellerUid) {
    return mealsRef(sellerUid).doc(mealUid).snapshots();
  }

  Future<Position> getUserLocation() {
    // Stream para pegar a localização da pessoa
    return Geolocator.getCurrentPosition();
  }

  bool isInTimeRange(DocumentSnapshot seller, String weekday, int time) {
    var sellerData = seller.data() as Map<String, dynamic>;
    return sellerData["shift"][weekday]["openingTime"] <= time &&
        sellerData["shift"][weekday]["closingTime"] >= time;
  }

  Stream<List<DocumentSnapshot>> filterTimeRange(
      Stream<List<DocumentSnapshot>> stream) {
    DateTime currentTime = DateTime.now();
    int formattedTime =
        int.parse(currentTime.hour.toString() + currentTime.minute.toString());
    String weekday = weekdayMap[currentTime.weekday];
    return stream.map((documents) => documents
        .where((seller) => isInTimeRange(seller, weekday, formattedTime))
        .map((i) => i)
        .toList());
  }

  Stream<List<DocumentSnapshot>> getNearbySellersStream(
      Position userLocation, double radius,
      {bool queryByActive = false, bool queryByTime = false}) {
    // Stream para pegar os vendedores próximos
    GeoFirePoint center = geo.point(
        latitude: userLocation.latitude, longitude: userLocation.longitude);

    DateTime currentTime = DateTime.now();
    String weekday = weekdayMap[currentTime.weekday];

    var queryRef = cleanSellersRef.where("active");
    if (queryByActive) queryRef = queryRef.where("active", isEqualTo: true);
    if (queryByTime)
      queryRef = queryRef.where("shift.$weekday.open", isEqualTo: true);

    if (queryByTime) {
      return filterTimeRange(geo.collection(collectionRef: queryRef).within(
          center: center, radius: radius, field: "location", strictMode: true));
    } else {
      return geo.collection(collectionRef: queryRef).within(
          center: center, radius: radius, field: "location", strictMode: true);
    }
  }

  Future<double> getSellerRange() async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getDouble('seller_range') == null) {
      return Future.value(10.0);
    }
    return Future.value(prefs.getDouble('seller_range'));
  }

  setSellerRange(double range) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('seller_range', range);
  }

  Future<bool> showFillPerfil() async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('fillPerfil') == null) {
      return Future.value(true);
    }
    return Future.value(prefs.getBool('fillPerfil'));
  }

  dontShowFillPerfill() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('fillPerfil', false);
  }

  setInternetConnection(bool hasInternet, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("hasInternet", hasInternet);
    Provider.of<RangeChangeNotifier>(context, listen: false).triggerRefresh();
  }

  Future<bool> getInternetConnection() async {
    var prefs = await SharedPreferences.getInstance();
    var hasInternet = prefs.getBool('hasInternet');
    if (hasInternet == null) {
      return false;
    }
    return hasInternet;
  }

  Future<bool> checkInternetConnection(BuildContext context) async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setInternetConnection(true, context);
        return true;
      } else
        return false;
    } on SocketException catch (_) {
      setInternetConnection(false, context);
      return true;
    }
  }

  static Repository get instance => Repository();
}
