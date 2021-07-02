import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rango/models/client.dart';
import 'package:rango/models/meals.dart';
import 'package:rango/models/order.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
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
  final sellersRef = Firestore.instance.collection('sellers');
  final clientsRef = Firestore.instance.collection('clients');
  final ordersRef = Firestore.instance.collection('orders');
  final geo = Geoflutterfire();
  final auth = FirebaseAuth.instance;

  Stream<DocumentSnapshot> getSeller(String uid) {
    return sellersRef.document(uid).snapshots();
  }

  Stream<DocumentSnapshot> getMealFromSeller(String mealUid, String sellerUid) {
    return sellersRef.document(sellerUid).collection("meals").document(mealUid).snapshots();
  }

  Future<DocumentSnapshot> getSellerFuture(String uid) {
    return sellersRef.document(uid).get();
  }

  Future<FirebaseUser> getCurrentUser() {
    return auth.currentUser();
  }

  Stream<DocumentSnapshot> getClientStream(String uid) {
    return clientsRef.document(uid).snapshots();
  }

  Stream<QuerySnapshot> getSellerMeals(String uid) {
    return sellersRef.document(uid).collection('meals').snapshots();
  }

  Stream<QuerySnapshot> getFavoriteSellers(List<String> favorites) {
    // Essa query whereIn tem o limite de 10 items
    return sellersRef.where(FieldPath.documentId, whereIn: favorites).snapshots();
  }

  Future<void> addSellerToClientFavorites(String clientId, String sellerId) {
    return clientsRef.document(clientId).updateData({'favoriteSellers': FieldValue.arrayUnion([sellerId])});
  }

  Future<void> removeSellerFromClientFavorites(String clientId, String sellerId) {
    return clientsRef.document(clientId).updateData({'favoriteSellers': FieldValue.arrayRemove([sellerId])});
  }

  Future<DocumentReference> addOrder(Order order) async {
    var mealDoc = await sellersRef.document(order.sellerId).collection('meals').document(order.mealId).get();
    Meal meal = Meal.fromJson(mealDoc.data);
    if (meal.quantity < order.quantity) {
      throw('Não há quentinhas suficientes para o seu pedido. Quantidade disponível: ${meal.quantity}.');
    }
    return ordersRef.add(order.toJson());
  }

  Future<void> cancelOrder(String orderUid) async {
    return ordersRef.document(orderUid).updateData(
        {
          'status': 'canceled',
          'canceledAt': Timestamp.now()
        });
  }

  Stream<QuerySnapshot> getOrdersFromClient(String clientId, {int limit}) {
    if (limit != null && limit > 0) {
      return ordersRef.where('clientId', isEqualTo: clientId).orderBy('requestedAt', descending: true).limit(limit).snapshots();
    }
    return ordersRef.where('clientId', isEqualTo: clientId).orderBy('requestedAt', descending: true).snapshots();
  }

  Stream<QuerySnapshot> getOrdersFromSeller(String sellerId, {int limit}) {
    if (limit != null && limit > 0) {
      return ordersRef.where('sellerId', isEqualTo: sellerId).orderBy('requestedAt', descending: true).limit(limit).snapshots();
    }
    return ordersRef.where('sellerId', isEqualTo: sellerId).orderBy('requestedAt', descending: true).snapshots();
  }

  //TODO Query pelo dia
  Stream<QuerySnapshot> getOpenOrdersFromSeller(String sellerId, {int limit}) {
    if (limit != null && limit > 0) {
      return ordersRef.where('sellerId', isEqualTo: sellerId).where('status', whereIn: ['requested', 'reserved']).orderBy('requestedAt', descending: true).limit(limit).snapshots();
    }
    return ordersRef.where('sellerId', isEqualTo: sellerId).where('status', whereIn: ['requested', 'reserved']).orderBy('requestedAt', descending: true).snapshots();
  }

  Stream<QuerySnapshot> getClosedOrdersFromSeller(String sellerId, {int limit}) {
    if (limit != null && limit > 0) {
      return ordersRef.where('sellerId', isEqualTo: sellerId).where('status', isEqualTo: 'sold').orderBy('requestedAt', descending: true).limit(limit).snapshots();
    }
    return ordersRef.where('sellerId', isEqualTo: sellerId).where('status', isEqualTo: 'sold').orderBy('requestedAt', descending: true).snapshots();
  }

  Future<void> updateSeller(String uid, Map<String, dynamic> dataToUpdate) async {
    return sellersRef.document(uid).updateData(dataToUpdate);
  }

  Future<Position> getUserLocation() {
    // Stream para pegar a localização da pessoa
    return Geolocator.getCurrentPosition();
  }

  bool isInTimeRange(DocumentSnapshot seller, String weekday, int time) {
    return seller.data["shift"][weekday]["openingTime"] <= time && seller.data["shift"][weekday]["closingTime"] >= time;
  }

  Stream<List<DocumentSnapshot>> filterTimeRange(Stream<List<DocumentSnapshot>> stream) {
    DateTime currentTime = DateTime.now();
    int formattedTime = int.parse(currentTime.hour.toString() + currentTime.minute.toString());
    String weekday = weekdayMap[currentTime.weekday];
    return stream.map((documents) => documents.where((seller) => isInTimeRange(seller, weekday, formattedTime)).map((i) => i).toList());
  }

  Stream<List<QuerySnapshot>> getCurrentMealsStream(List<DocumentSnapshot> sellerList, {bool queryByFeatured = false, int limit = -1}) {
    List<Stream<QuerySnapshot>> streams = [];

    for (var i = 0; i < sellerList.length; i++) {
      // Iterar todos os vendedores
      var seller = sellerList[i];

      var queryRef = seller.reference.collection("currentMeals").where("name");
      if (queryByFeatured == true) queryRef = queryRef.where("featured", isEqualTo: true);
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

  static Repository get instance => Repository();
}