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
  final sellersRef = FirebaseFirestore.instance.collection('sellers');
  final clientsRef = FirebaseFirestore.instance.collection('clients').withConverter<Client>(
      fromFirestore: (snapshot, _) => Client.fromJson(snapshot.data(), id: snapshot.id),
      toFirestore: (client, _) => client.toJson()
  );
  final ordersRef = FirebaseFirestore.instance.collection('orders').withConverter<Order>(
      fromFirestore: (snapshot, _) => Order.fromJson(snapshot.data(), id: snapshot.id),
      toFirestore: (order, _) => order.toJson()
  );
  CollectionReference<Meal> mealsRef(String sellerId) => sellersRef.doc(sellerId).collection('meals').withConverter<Meal>(
      fromFirestore: (snapshot, _) => Meal.fromJson(snapshot.data(), id: snapshot.id),
      toFirestore: (meal, _) => meal.toJson()
  );
  final geo = Geoflutterfire();
  final auth = FirebaseAuth.instance;

  Stream<DocumentSnapshot> getSeller(String uid) {
    return sellersRef.doc(uid).snapshots();
  }

  Stream<DocumentSnapshot> getMealFromSeller(String mealUid, String sellerUid) {
    return sellersRef.doc(sellerUid).collection("meals").doc(mealUid).snapshots();
  }

  Future<DocumentSnapshot> getSellerFuture(String uid) {
    return sellersRef.doc(uid).get();
  }

  User getCurrentUser() {
    return auth.currentUser;
  }

  Stream<DocumentSnapshot<Client>> getClientStream(String uid) {
    return clientsRef.doc(uid).snapshots();
  }

  Stream<QuerySnapshot> getSellerMeals(String uid) {
    return sellersRef.doc(uid).collection('meals').snapshots();
  }

  Stream<QuerySnapshot> getFavoriteSellers(List<String> favorites) {
    // Essa query whereIn tem o limite de 10 items
    return sellersRef.where(FieldPath.documentId, whereIn: favorites).snapshots();
  }

  Future<void> addSellerToClientFavorites(String clientId, String sellerId) {
    return clientsRef.doc(clientId).update({'favoriteSellers': FieldValue.arrayUnion([sellerId])});
  }

  Future<void> removeSellerFromClientFavorites(String clientId, String sellerId) {
    return clientsRef.doc(clientId).update({'favoriteSellers': FieldValue.arrayRemove([sellerId])});
  }

  Future<DocumentReference> addOrder(Order order) async {
    var mealDoc = await sellersRef.doc(order.sellerId).collection('meals').doc(order.mealId).get();
    Meal meal = Meal.fromJson(mealDoc.data());
    if (meal.quantity < order.quantity) {
      throw('Não há quentinhas suficientes para o seu pedido. Quantidade disponível: ${meal.quantity}.');
    }
    return ordersRef.add(order);
  }

  Future<void> reserveOrderTransaction(Order order) async {
    try {
      return await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentReference<Meal> mealRef = mealsRef(order.sellerId).doc(order.mealId);
        DocumentReference<Order> orderRef = ordersRef.doc(order.id);

        DocumentSnapshot<Meal> snapshot = await transaction.get<Meal>(mealRef);
        int quantity = snapshot.data().quantity;

        if (quantity - order.quantity >= 0) {
          transaction.update(mealRef, {
            'quantity' : quantity - order.quantity
          });
          transaction.update(orderRef, {
            'status': 'reserved',
            'reservedAt': Timestamp.now()
          });
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
      return await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentReference<Meal> mealRef = mealsRef(order.sellerId).doc(order.mealId);
        DocumentReference<Order> orderRef = ordersRef.doc(order.id);

        DocumentSnapshot<Meal> snapshot = await transaction.get<Meal>(mealRef);
        int quantity = snapshot.data().quantity;

        transaction.update(mealRef, {
          'quantity' : quantity + order.quantity
        });
        transaction.update(orderRef, {
          'status': 'requested',
          'reservedAt': null
        });
      });
    } catch (e) {
      throw e;
    }
  }

  Future<void> sellOrder(String orderUid) async {
    try {
      ordersRef.doc(orderUid).update(
          {
            'status': 'sold',
            'soldAt': Timestamp.now()
          });
    } catch (e) {
      throw e;
    }
  }

  Future<void> undoSellOrder(String orderUid) async {
    try {
      ordersRef.doc(orderUid).update(
          {
            'status': 'reserved',
            'soldAt': null
          });
    } catch (e) {
      throw e;
    }
  }

  Future<void> cancelOrder(Order order) async {
    try {
      return await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentReference<Order> orderRef = ordersRef.doc(order.id);

        if (order.status == 'reserved') {
          DocumentReference<Meal> mealRef = mealsRef(order.sellerId).doc(order.mealId);
          DocumentSnapshot<Meal> snapshot = await transaction.get<Meal>(mealRef);
          int quantity = snapshot.data().quantity;

          transaction.update(mealRef, {
            'quantity' : quantity + order.quantity
          });
        }

        transaction.update(orderRef, {
          'status': 'canceled',
          'canceledAt': Timestamp.now()
        });
      });
    } catch (e) {
      throw e;
    }
  }

  Stream<QuerySnapshot<Order>> getOrdersFromClient(String clientId, {int limit}) {
    if (limit != null && limit > 0) {
      return ordersRef.where('clientId', isEqualTo: clientId).orderBy('requestedAt', descending: true).limit(limit).snapshots();
    }
    return ordersRef.where('clientId', isEqualTo: clientId).orderBy('requestedAt', descending: true).snapshots();
  }

  Stream<QuerySnapshot<Order>> getOrdersFromSeller(String sellerId, {int limit}) {
    if (limit != null && limit > 0) {
      return ordersRef.where('sellerId', isEqualTo: sellerId).orderBy('requestedAt', descending: true).limit(limit).snapshots();
    }
    return ordersRef.where('sellerId', isEqualTo: sellerId).orderBy('requestedAt', descending: true).snapshots();
  }

  //TODO Query pelo dia
  Stream<QuerySnapshot<Order>> getOpenOrdersFromSeller(String sellerId, {int limit}) {
    if (limit != null && limit > 0) {
      return ordersRef.where('sellerId', isEqualTo: sellerId).where('status', whereIn: ['requested', 'reserved']).orderBy('requestedAt').limit(limit).snapshots();
    }
    return ordersRef.where('sellerId', isEqualTo: sellerId).where('status', whereIn: ['requested', 'reserved']).orderBy('requestedAt').snapshots();
  }

  Stream<QuerySnapshot<Order>> getClosedOrdersFromSeller(String sellerId, {int limit}) {
    if (limit != null && limit > 0) {
      return ordersRef.where('sellerId', isEqualTo: sellerId).where('status', isEqualTo: 'sold').orderBy('requestedAt', descending: true).limit(limit).snapshots();
    }
    return ordersRef.where('sellerId', isEqualTo: sellerId).where('status', isEqualTo: 'sold').orderBy('requestedAt', descending: true).snapshots();
  }

  Future<void> updateSeller(String uid, Map<String, dynamic> dataToUpdate) async {
    return sellersRef.doc(uid).update(dataToUpdate);
  }

  Future<Position> getUserLocation() {
    // Stream para pegar a localização da pessoa
    return Geolocator.getCurrentPosition();
  }

  bool isInTimeRange(DocumentSnapshot seller, String weekday, int time) {
    return (seller.data() as Map<String, dynamic>)["shift"][weekday]["openingTime"] <= time && (seller.data() as Map<String, dynamic>)["shift"][weekday]["closingTime"] >= time;
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