import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rango/models/meals.dart';
import 'package:rango/models/order.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:rxdart/rxdart.dart';

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
  final ordersRef = Firestore.instance.collection('orders');
  final geo = Geoflutterfire();

  Stream<DocumentSnapshot> getSeller(String uid) {
    return sellersRef.document(uid).snapshots();
  }

  Stream<QuerySnapshot> getSellerCurrentMeals(String uid) {
    //TODO Filtrar pelo tempo?
    return sellersRef.document(uid).collection('currentMeals').snapshots();
  }

  Future<DocumentReference> addOrder(Order order) async {
    var currentMealDoc = await sellersRef.document(order.sellerId).collection('currentMeals').document(order.mealId).get();
    Meal currentMeal = Meal.fromJson(currentMealDoc.data);
    if (currentMeal.quantity < order.quantity) {
      throw('Não há quentinhas suficientes para o seu pedido. Quantidade disponível: ${currentMeal.quantity}.');
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
      return ordersRef.where('clientId', isEqualTo: clientId).limit(limit).snapshots();
    }
    return ordersRef.where('clientId', isEqualTo: clientId).snapshots();
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

  Stream<List<DocumentSnapshot>> getNearbySellersStream(Position userLocation) {
    // Stream para pegar os vendedores próximos
    GeoFirePoint center = geo.point(latitude: userLocation.latitude, longitude: userLocation.longitude);
    double radius = 30; // Em km TODO Pegar isso de SharedPreferences

    DateTime currentTime = DateTime.now();
    String weekday = weekdayMap[currentTime.weekday];

    var queryRef = sellersRef
        .where("active", isEqualTo: true)
        .where("shift.$weekday.open", isEqualTo: true);

    // TODO return filterTimeRange(geo.collection(collectionRef: queryRef).within(center: center, radius: radius, field: "location", strictMode: true));
    return geo.collection(collectionRef: queryRef).within(center: center, radius: radius, field: "location", strictMode: true);
  }

  Stream<List<QuerySnapshot>> getCurrentMealsStream(List<DocumentSnapshot> documentList) {
    List<Stream<QuerySnapshot>> streams = [];

    for (var i = 0; i < documentList.length; i++) {
      // Iterar todos os vendedores
      var seller = documentList[i];

      // TODO Limitar quantidade de pratos para seção Sugestões e filtrar por featured?
      streams.add(seller.reference.collection("currentMeals").getDocuments(source: Source.cache).asStream()); //.where("featured", isEqualTo: true).limit(2)
    }

    return CombineLatestStream.list<QuerySnapshot>(streams).asBroadcastStream();
  }

  static Repository get instance => Repository(); // TODO Necessario?
}