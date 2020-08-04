import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rango/models/contact.dart';
import 'package:rango/models/meals.dart';
import 'package:rango/models/seller.dart';
import 'package:rango/models/shift.dart';
import 'package:location/location.dart';

final List<Seller> sellers = [
  Seller(
    active: true,
    contact: Contact(name: "Maria", phone: "21994087257"),
    currentMeals: [
      Meal(
        name: "Estrogonofe de frango",
        description:
            "Estrogonofe de frango muito gostoso, preparado no dia anterior com ingredientes frescos.",
        price: 12.50,
        picture:
            "https://img.itdg.com.br/tdg/images/recipes/000/174/031/173715/173715_original.jpg?mode=crop&width=710&height=400",
      ),
    ],
    meals: [
      Meal(
        name: "Estrogonofe de frango",
        description:
            "Estrogonofe de frango muito gostoso, preparado no dia anterior com ingredientes frescos.",
        price: 12.5,
        picture:
            "https://img.itdg.com.br/tdg/images/recipes/000/174/031/173715/173715_original.jpg?mode=crop&width=710&height=400",
      ),
      Meal(
        description: "Macarrão com farofa, pra quem gosta.",
        name: "Macarrão",
        price: 11,
        picture: "https://pbs.twimg.com/media/EW-lGN6XgAECoF8.png:large",
      ),
    ],
    location: LatLng(-22.96926, 43.35842),
    logo:
        "https://s2.glbimg.com/U2ZXq3JIRKvJMXDLPNuhB1hdqTw=/i.glbimg.com/og/ig/infoglobo1/f/original/2018/08/10/quentinha.jpg",
    name: "Quentinha Legal",
    picture:
        "https://ogimg.infoglobo.com.br/in/22875948-611-fa5/FT1086A/384/x77867105_CI-Rio-de-Janeiro-RJ-10-07-2018Febre-das-Quentinhas-Varios-bairros-do-RJ-encontram-se-pe.jpg.pagespeed.ic.rfkyARw5WX.jpg",
    shift: Shift(
      closing: "1800",
      friday: true,
      monday: true,
      opening: "0900",
      saturday: null,
      sunday: false,
      thursday: false,
      tuesday: true,
      wednesday: true,
    ),
  ),
  Seller(
    active: true,
    contact: Contact(name: "Maria", phone: "21994087257"),
    currentMeals: [
      Meal(
        name: "Lasanha",
        description: "Lasanha bolonhesa com bastante molho e massa",
        price: 20,
        picture:
            "https://i.pinimg.com/originals/0b/3a/b4/0b3ab44ad459c68cd503d6e9da48b50e.png",
      ),
    ],
    meals: [
      Meal(
        name: "Lasanha",
        description: "Lasanha bolonhesa com bastante molho e massa",
        price: 20,
        picture:
            "https://i.pinimg.com/originals/0b/3a/b4/0b3ab44ad459c68cd503d6e9da48b50e.png",
      ),
      Meal(
        description: "Macarrão com farofa, pra quem gosta.",
        name: "Macarrão",
        price: 11,
        picture: "https://pbs.twimg.com/media/EW-lGN6XgAECoF8.png:large",
      ),
    ],
    location: LatLng(-22.96926, 43.35842),
    logo:
        "https://s2.glbimg.com/U2ZXq3JIRKvJMXDLPNuhB1hdqTw=/i.glbimg.com/og/ig/infoglobo1/f/original/2018/08/10/quentinha.jpg",
    name: "Quentinha Delivery",
    picture:
        "https://static-images.ifood.com.br/image/upload//logosgde/c40e3cdd-2aa3-4cf5-a405-4064ca2ee673/201811281636_logo.png",
    shift: Shift(
      closing: "1800",
      friday: true,
      monday: true,
      opening: "0900",
      saturday: null,
      sunday: false,
      thursday: false,
      tuesday: true,
      wednesday: true,
    ),
  ),
  Seller(
    active: true,
    contact: Contact(name: "Maria", phone: "21994087257"),
    currentMeals: [
      Meal(
        description: "Macarrão com farofa, pra quem gosta.",
        name: "Macarrão",
        price: 11,
        picture: "https://pbs.twimg.com/media/EW-lGN6XgAECoF8.png:large",
      ),
    ],
    meals: [
      Meal(
        description: "Macarrão com farofa, pra quem gosta.",
        name: "Macarrão",
        price: 11,
        picture: "https://pbs.twimg.com/media/EW-lGN6XgAECoF8.png:large",
      ),
    ],
    location: LatLng(-22.96926, 43.35842),
    logo:
        "https://s2.glbimg.com/U2ZXq3JIRKvJMXDLPNuhB1hdqTw=/i.glbimg.com/og/ig/infoglobo1/f/original/2018/08/10/quentinha.jpg",
    name: "Top quentinhas",
    picture:
        "https://static-images.ifood.com.br/image/upload//logosgde/c40e3cdd-2aa3-4cf5-a405-4064ca2ee673/201811281636_logo.png",
    shift: Shift(
      closing: "1800",
      friday: true,
      monday: true,
      opening: "0900",
      saturday: null,
      sunday: false,
      thursday: false,
      tuesday: true,
      wednesday: true,
    ),
  ),
];
