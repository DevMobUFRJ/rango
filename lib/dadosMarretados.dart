import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rango/models/contact.dart';
import 'package:rango/models/meals.dart';
import 'package:rango/models/seller.dart';
import 'package:rango/models/shift.dart';

final List<Seller> sellers = [
  Seller(
    active: true,
    contact: Contact(name: "Maria", phone: "21994087257"),
    currentMeals: {},
    meals: [
      Meal(
        sellerId: "1",
        sellerName: "Quentinha Legal",
        name: "Estrogonofe de frango",
        description:
            "Estrogonofe de frango muito gostoso, preparado no dia anterior com ingredientes frescos.",
        price: 1250,
        picture:
            "https://img.itdg.com.br/tdg/images/recipes/000/174/031/173715/173715_original.jpg?mode=crop&width=710&height=400",
      ),
      Meal(
        sellerId: "1",
        sellerName: "Quentinha Legal",
        description: "Macarrão com farofa, pra quem gosta.",
        name: "Macarrão",
        price: 11,
        picture: "https://pbs.twimg.com/media/EW-lGN6XgAECoF8.png:large",
      ),
    ],
    location: Location(
      geohash: "askjfhakjsf",
      geopoint: GeoPoint(-20, -40)
    ),
    logo:
        "https://s2.glbimg.com/U2ZXq3JIRKvJMXDLPNuhB1hdqTw=/i.glbimg.com/og/ig/infoglobo1/f/original/2018/08/10/quentinha.jpg",
    name: "Quentinha Legal",
    picture:
        "https://ogimg.infoglobo.com.br/in/22875948-611-fa5/FT1086A/384/x77867105_CI-Rio-de-Janeiro-RJ-10-07-2018Febre-das-Quentinhas-Varios-bairros-do-RJ-encontram-se-pe.jpg.pagespeed.ic.rfkyARw5WX.jpg",
    shift: Shift(
      friday: (
        Weekday(
          openingTime: 800,
          closingTime: 1600,
          open: true
        )
      ),
      monday: Weekday(
          openingTime: 800,
          closingTime: 1600,
          open: true
      ),
      saturday: Weekday(
          openingTime: 800,
          closingTime: 1600,
          open: true
      ),
      sunday: Weekday(
          openingTime: 800,
          closingTime: 1600,
          open: true
      ),
      thursday: Weekday(
          openingTime: 800,
          closingTime: 1600,
          open: true
      ),
      tuesday: Weekday(
          openingTime: 800,
          closingTime: 1600,
          open: true
      ),
      wednesday: Weekday(
          openingTime: 800,
          closingTime: 1600,
          open: true
      ),
    ),
  ),
];
