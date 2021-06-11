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
  
  Stream<QuerySnapshot> getOrdersFromClient(String clientUid) {
    return ordersRef.where('clientId', isEqualTo: clientUid).snapshots();
  }

  // Não tá sendo usada
  Stream<List<QuerySnapshot>> getMealsFromNearbySellers() {
    Position position = Position();
    Geolocator.getCurrentPosition()
        .then((value) => position = value)
        .catchError(() => print("error on getCurrentPosition"));

    GeoFirePoint center = geo.point(latitude: position.latitude, longitude: position.longitude);
    double radius = 30; // Em km TODO Pegar isso de SharedPreferences
    var queryRef = sellersRef; //.where("active", isEqualTo: true); //TODO Adicionar query por "active" e "shift"
    Stream<List<DocumentSnapshot>> sellersStream = geo.collection(collectionRef: queryRef)
        .within(center: center, radius: radius, field: "location", strictMode: true);

    List<Stream<QuerySnapshot>> mealsStreams = [];

    sellersStream.listen((List<DocumentSnapshot> sellers) {
      mealsStreams = [];
      for (var i = 0; i < sellers.length; i++) {
        // Iterar todos os vendedores
        var seller = sellers[i];

        // TODO Limitar quantidade de pratos para seção Sugestões e filtrar por featured
        mealsStreams.add(seller.reference.collection('currentMeals').snapshots()); //.where("featured", isEqualTo: true).limit(2)
      }
    });

    return CombineLatestStream.list<QuerySnapshot>(mealsStreams).asBroadcastStream(); //TODO Usar transformer para retornar stream de Meal?
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

    //return filterTimeRange(geo.collection(collectionRef: queryRef).within(center: center, radius: radius, field: "location", strictMode: true));
    return geo.collection(collectionRef: queryRef).within(center: center, radius: radius, field: "location", strictMode: true);
  }

  Stream<List<QuerySnapshot>> getCurrentMealsStream(List<DocumentSnapshot> documentList) {
    List<Stream<QuerySnapshot>> streams = [];

    for (var i = 0; i < documentList.length; i++) {
      // Iterar todos os vendedores
      var seller = documentList[i];

      // TODO Limitar quantidade de pratos para seção Sugestões e filtrar por featured
      streams.add(seller.reference.collection("currentMeals").getDocuments(source: Source.cache).asStream()); //.where("featured", isEqualTo: true).limit(2)
    }

    return CombineLatestStream.list<QuerySnapshot>(streams).asBroadcastStream();
  }

  static Repository get instance => Repository(); // TODO Necessario?
}