import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rango/models/meal_request.dart';
import 'package:rango/models/seller.dart';
import 'package:rango/resources/repository.dart';
import 'package:rango/screens/seller/ChatScreen.dart';
import 'package:rango/widgets/home/ListaHorizontal.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show DocumentSnapshot;

class SellerProfile extends StatefulWidget {
  final String sellerName;
  final String sellerId;

  SellerProfile(this.sellerId, this.sellerName);

  @override
  _SellerProfileState createState() => _SellerProfileState();
}

class _SellerProfileState extends State<SellerProfile> {
  @override
  Widget build(BuildContext context) {
    final yellow = Color(0xFFF9B152);
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          widget.sellerName,
          maxLines: 1,
          style: GoogleFonts.montserrat(
            color: Theme.of(context).accentColor,
            fontSize: 38.nsp,
          ),
        ),
        actions: [_buildFavoriteButton()],
      ),
      body: StreamBuilder(
        stream: Repository.instance.getSeller(widget.sellerId),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              height: 0.5.hp,
              alignment: Alignment.center,
              child: SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(
                  color: Theme.of(context).accentColor,
                ),
              ),
            );
          }
          if (snapshot.hasError) {
            return Container(
              height: 0.6.hp - 56,
              alignment: Alignment.center,
              child: AutoSizeText(
                snapshot.error.toString(),
                style: GoogleFonts.montserrat(
                    fontSize: 45.nsp, color: Theme.of(context).accentColor),
              ),
            );
          }

          Seller seller =
              Seller.fromJson(snapshot.data.data, id: snapshot.data.documentID);
          var currentMeals = seller.currentMeals;
          List<MealRequest> allCurrentMeals = currentMeals.entries.map((meal) {
            return MealRequest(mealId: meal.key, seller: seller);
          }).toList();

          return Column(
            children: [
              Flexible(
                flex: 2,
                child: Container(
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
                          backgroundImage: seller.logo != null
                              ? NetworkImage(seller.logo)
                              : null,
                          radius: 130.w,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (seller.description != null)
                Flexible(
                  flex: 0,
                  child: Container(
                    margin: EdgeInsets.only(top: 8),
                    constraints: BoxConstraints(maxWidth: 0.8.wp),
                    child: AutoSizeText(
                      seller.description,
                      textAlign: TextAlign.center,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.montserrat(fontSize: 30.nsp),
                    ),
                  ),
                ),
              Flexible(
                flex: 0,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 5),
                        child: GestureDetector(
                          onTap: () => {
                            Clipboard.setData(
                              ClipboardData(text: seller.contact.phone),
                            ),
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Theme.of(context).accentColor,
                                content: AutoSizeText(
                                  'Número copiado para área de transferência',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.montserrat(),
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            )
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                margin: EdgeInsets.only(right: 1),
                                child: Icon(Icons.phone, size: 32.nsp),
                              ),
                              AutoSizeText(
                                seller.contact.phone,
                                maxLines: 1,
                                style: GoogleFonts.montserrat(
                                  fontSize: 30.nsp,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          try {
                            final Uri whatsAppUrl = Uri(
                              scheme: 'http',
                              path:
                                  "wa.me/+55${seller.contact.phone.replaceAll('(', '').replaceAll(')', '')}",
                            );
                            launch(whatsAppUrl.toString());
                          } catch (error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'WhatsApp não instalado',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.montserrat(),
                                ),
                              ),
                            );
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AutoSizeText(
                              'Abrir no WhatsApp',
                              style: GoogleFonts.montserrat(
                                fontSize: 30.nsp,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 2),
                              child: FaIcon(
                                FontAwesomeIcons.whatsapp,
                                size: 36.nsp,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                flex: 0,
                child: Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: ListaHorizontal(
                    title: 'Quentinhas disponíveis',
                    tagM: Random().nextDouble(),
                    meals: allCurrentMeals,
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.chat, size: 38.nsp),
                  onPressed: () => pushNewScreen(
                    context,
                    withNavBar: false,
                    screen: ChatScreen(seller),
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  ),
                  label: Container(
                    width: 0.5.wp,
                    child: AutoSizeText(
                      'Chat com o vendedor',
                      maxLines: 1,
                      style: GoogleFonts.montserrat(
                        fontSize: 38.nsp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.map, size: 38.nsp),
                  onPressed: () {},
                  label: Container(
                    width: 0.35.wp,
                    child: AutoSizeText(
                      'Ver localização',
                      maxLines: 1,
                      style: GoogleFonts.montserrat(
                        fontSize: 38.nsp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  _buildFavoriteButton() {
    return FutureBuilder(
      future: Repository.instance.getCurrentUser(),
      builder: (context, AsyncSnapshot<FirebaseUser> authSnapshot) {
        if (!authSnapshot.hasData || authSnapshot.hasError) {
          return Padding(
            padding: EdgeInsets.only(
              right: 20,
            ),
            child: Icon(
              Icons.star_border,
              size: 48.nsp,
            ),
          );
        }

        return StreamBuilder(
            stream: Repository.instance.getClientStream(authSnapshot.data.uid),
            builder: (context, AsyncSnapshot<DocumentSnapshot> clientSnapshot) {
              if (!clientSnapshot.hasData) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: 20,
                  ),
                  child: Icon(
                    Icons.star_border,
                    size: 48.nsp,
                  ),
                );
              }

              if (clientSnapshot.hasError) {
                return SizedBox();
              }
              var isFavorite = false;
              if (clientSnapshot.data.data['favoriteSellers'] != null) {
                isFavorite = clientSnapshot.data.data['favoriteSellers']
                    .contains(widget.sellerId);
              }
              return Padding(
                padding: EdgeInsets.only(
                  right: 20,
                ),
                child: GestureDetector(
                  onTap: () async {
                    if (isFavorite) {
                      Repository.instance.removeSellerFromClientFavorites(
                          clientSnapshot.data.documentID, widget.sellerId);
                    } else {
                      Repository.instance.addSellerToClientFavorites(
                          clientSnapshot.data.documentID, widget.sellerId);
                    }
                  },
                  child: Icon(
                    isFavorite == true ? Icons.star : Icons.star_border,
                    size: 48.nsp,
                  ),
                ),
              );
            });
      },
    );
  }
}
