import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    ScreenUtil.init(context, width: 750, height: 1334);
    final yellow = Color(0xFFF9B152);
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          widget.sellerName,
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
                size: 42.nsp,
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
                          margin: EdgeInsets.only(left: 80.w, bottom: 50.h),
                          height: 230.h,
                          width: 260.w,
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
                      width: 270.w,
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
                      width: 190.w,
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
