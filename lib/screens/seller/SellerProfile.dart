import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rango/dadosMarretados.dart';
import 'package:rango/models/contact.dart';
import 'package:rango/models/meals.dart';
import 'package:rango/models/seller.dart';
import 'package:rango/models/shift.dart';
import 'package:rango/screens/seller/ChatScreen.dart';
import 'package:rango/widgets/home/ListaHorizontal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SellerProfile extends StatefulWidget {
  final String sellerName;
  final String sellerId;

  SellerProfile(this.sellerId, this.sellerName);

  @override
  _SellerProfileState createState() => _SellerProfileState();
}

class _SellerProfileState extends State<SellerProfile> {
  bool isFavorite = false;
  bool loading = true;
  Seller seller;

  @override
  void initState() {
    setState(() {
      seller = Seller(
        active: true,
        contact: Contact(name: "Maria", phone: "21994087257"),
        currentMeals: [
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
        ],
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
      );
      loading = false;
    });
    super.initState();
  }

  final _database = Firestore.instance;
  void _fetch() async {
    try {
      print("Start seller fetch: ${widget.sellerId}");
      var doc = await _database.collection("sellers").document(widget.sellerId).get();
      Seller tempSeller = Seller.fromJson(doc.data);

      var a = await _database.collection("sellers").document(widget.sellerId).collection("currentMeals").getDocuments();
      var currentMeals = a.documents;
      for(var i=0; i < currentMeals.length; i++){
        tempSeller.currentMeals.add(Meal.fromJson(currentMeals[i].data));
      }

      var b = await _database.collection("sellers").document(widget.sellerId).collection("meals").getDocuments();
      var meals = b.documents;
      for(var i=0; i < meals.length; i++){
        tempSeller.meals.add(Meal.fromJson(meals[i].data));
      }
      print("${tempSeller.meals.length} meals found");

      setState(() {
        seller = tempSeller;
      });
    } catch(e) {
      print(e);
    }
    loading = false;
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334);
    _fetch();
    final yellow = Color(0xFFF9B152);
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          seller.name,
          maxLines: 1,
          style: GoogleFonts.montserrat(
            color: Theme.of(context).accentColor,
            fontSize: 35.nsp,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(
              right: 20,
            ),
            child: GestureDetector(
              onTap: () => setState(() => isFavorite = !isFavorite),
              child: Icon(
                isFavorite ? Icons.star : Icons.star_border,
                size: 48.nsp,
              ),
            ),
          )
        ],
      ),
      body: loading
          ? CircularProgressIndicator()
          : Center(
              child: Column(
                children: [
                  Container(
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(left: 80.w, bottom: 40.h),
                          height: 210.h,
                          width: 240.w,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(ScreenUtil().setSp(30)),
                            color: yellow,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 20),
                          child: CircleAvatar(
                            backgroundColor: Theme.of(context).accentColor,
                            backgroundImage: seller.picture != null
                                ? NetworkImage(seller.picture)
                                : null,
                            radius: 130.w,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.phone, size: 38.nsp),
                      Container(
                        width: 170.w,
                        child: AutoSizeText(
                          seller.contact.phone,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  ListaHorizontal(
                    title: 'Quentinhas disponíveis',
                    tagM: Random().nextDouble(),
                    meals: seller.meals,
                  ),
                  SizedBox(height: 40.h),
                  RaisedButton.icon(
                    icon: Icon(Icons.chat, size: 38.nsp),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    onPressed: () => pushNewScreen(
                      context,
                      screen: ChatScreen(seller),
                      withNavBar: false,
                      pageTransitionAnimation:
                          PageTransitionAnimation.cupertino,
                    ),
                    label: Container(
                      width: 0.5.wp,
                      child: AutoSizeText(
                        'Chat com o vendedor',
                        maxLines: 1,
                        style: GoogleFonts.montserrat(),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  RaisedButton.icon(
                    icon: Icon(Icons.map, size: 38.nsp),
                    padding: EdgeInsets.symmetric(
                        vertical: 0.005.hp, horizontal: 0.03.wp),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    onPressed: () {},
                    label: Container(
                      width: 0.35.wp,
                      child: AutoSizeText(
                        'Ver localização',
                        maxLines: 1,
                        style: GoogleFonts.montserrat(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
