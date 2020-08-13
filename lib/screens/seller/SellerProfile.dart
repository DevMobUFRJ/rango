import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rango/dadosMarretados.dart';
import 'package:rango/models/seller.dart';
import 'package:rango/screens/seller/ChatScreen.dart';
import 'package:rango/widgets/home/ListaHorizontal.dart';

class SellerProfile extends StatefulWidget {
  final String sellerName;

  SellerProfile(this.sellerName);

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
      seller =
          sellers.firstWhere((element) => element.name == widget.sellerName);
      loading = false;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final yellow = Color(0xFFF9B152);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.sellerName,
          style: GoogleFonts.montserrat(color: Theme.of(context).accentColor),
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
                size: 28,
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
                          margin: EdgeInsets.only(left: 40, bottom: 20),
                          height: 150,
                          width: 160,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
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
                            radius: 80,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.phone),
                      Text(seller.contact.phone),
                    ],
                  ),
                  SizedBox(height: 20),
                  ListaHorizontal(
                    title: 'Quentinhas disponíveis',
                    tagM: Random().nextDouble(),
                    meals: seller.meals,
                  ),
                  SizedBox(height: 40),
                  Container(
                    child: RaisedButton.icon(
                      icon: Icon(Icons.chat),
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
                      label: Text(
                        'Chat com o vendedor',
                        overflow: TextOverflow.clip,
                        style: GoogleFonts.montserrat(fontSize: 16),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    child: RaisedButton.icon(
                      icon: Icon(Icons.map),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      onPressed: () {},
                      label: Text(
                        'Ver localização',
                        style: GoogleFonts.montserrat(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
