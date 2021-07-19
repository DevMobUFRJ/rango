import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rango/models/client.dart';
import 'package:rango/models/meals.dart';
import 'package:rango/models/order.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:rango/resources/rangeChangeNotifier.dart';
import 'dart:io';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

const weekdayMap = {
  1: 'monday',
  2: 'tuesday',
  3: 'wednesday',
  4: 'thursday',
  5: 'friday',
  6: 'saturday',
  7: 'sunday'
};

class Repository {
  final sellersRef = FirebaseFirestore.instance.collection('sellers');
  final chatRef = FirebaseFirestore.instance.collection('chat');
  final clientsRef =
      FirebaseFirestore.instance.collection('clients').withConverter<Client>(
            fromFirestore: (snapshot, _) =>
                Client.fromJson(snapshot.data(), id: snapshot.id),
            toFirestore: (client, _) => client.toJson(),
          );
  final ordersRef = FirebaseFirestore.instance.collection('orders');
  final geo = Geoflutterfire();
  final auth = FirebaseAuth.instance;
  final currentUser = FirebaseAuth.instance.currentUser;

  Stream<DocumentSnapshot> getSeller(String uid) {
    return sellersRef.doc(uid).snapshots();
  }

  Stream<DocumentSnapshot> getMealFromSeller(String mealUid, String sellerUid) {
    return sellersRef
        .doc(sellerUid)
        .collection("meals")
        .doc(mealUid)
        .snapshots();
  }

  Future<DocumentSnapshot> getSellerFuture(String uid) {
    return sellersRef.doc(uid).get();
  }

  User getCurrentUser() {
    return auth.currentUser;
  }

  Stream<DocumentSnapshot> getClientStream(String uid) {
    return clientsRef.doc(uid).snapshots();
  }

  Stream<QuerySnapshot> getSellerCurrentMeals(String uid) {
    return sellersRef.doc(uid).collection('currentMeals').snapshots();
  }

  Stream<QuerySnapshot> getFavoriteSellers(List<String> favorites) {
    // Essa query whereIn tem o limite de 10 items
    return sellersRef
        .where(FieldPath.documentId, whereIn: favorites)
        .snapshots();
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

  Future<Client> getUserData() async {
    DocumentSnapshot<Client> clientDocSnapshot =
        await clientsRef.doc(currentUser.uid).get();
    Client client = clientDocSnapshot.data();
    return client;
  }

  Future<void> addOrder(Order order) async {
    try {
      var mealDoc = await sellersRef
          .doc(order.sellerId)
          .collection('meals')
          .doc(order.mealId)
          .get(GetOptions(source: Source.server));
      Meal meal = Meal.fromJson(mealDoc.data());
      if (meal.quantity < order.quantity) {
        throw ('Não há quentinhas suficientes para o seu pedido. Quantidade disponível: ${meal.quantity}.');
      }
      return ordersRef.add(order.toJson());
    } on PlatformException catch (e) {
      throw e;
    } catch (e) {
      throw ("Serviço indisponível, tente novamente mais tarde.");
    }
  }

  Future<void> cancelOrder(String orderUid) async {
    return ordersRef
        .doc(orderUid)
        .update({'status': 'canceled', 'canceledAt': Timestamp.now()});
  }

  Stream<QuerySnapshot> getOrdersFromClient(String clientId, {int limit}) {
    if (limit != null && limit > 0) {
      return ordersRef
          .where('clientId', isEqualTo: clientId)
          .orderBy('requestedAt', descending: true)
          .limit(limit)
          .snapshots();
    }
    return ordersRef
        .where('clientId', isEqualTo: clientId)
        .orderBy('requestedAt', descending: true)
        .snapshots();
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

    var queryRef = sellersRef.where("active");
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

  Stream<List<QuerySnapshot>> getCurrentMealsStream(
      List<DocumentSnapshot> sellerList,
      {bool queryByFeatured = false,
      int limit = -1}) {
    List<Stream<QuerySnapshot>> streams = [];

    for (var i = 0; i < sellerList.length; i++) {
      var seller = sellerList[i];
      var queryRef = seller.reference.collection("currentMeals").where("name");
      if (queryByFeatured == true)
        queryRef = queryRef.where("featured", isEqualTo: true);
      if (limit != -1) queryRef = queryRef.limit(limit);

      streams.add(queryRef.snapshots());
    }

    return CombineLatestStream.list<QuerySnapshot>(streams).asBroadcastStream();
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
