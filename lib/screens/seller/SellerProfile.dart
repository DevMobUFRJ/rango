import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rango/models/meal_request.dart';
import 'package:rango/models/seller.dart';
import 'package:rango/resources/repository.dart';
import 'package:rango/screens/seller/ChatScreen.dart';
import 'package:rango/widgets/home/ListaHorizontal.dart';
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
          // TODO (Gabriel): Melhorar esse indicator
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }

          Seller seller =
              Seller.fromJson(snapshot.data.data, id: snapshot.data.documentID);
          var currentMeals = seller.currentMeals;
          List<MealRequest> allCurrentMeals = currentMeals.entries.map((meal) {
            return MealRequest(mealId: meal.key, seller: seller);
          }).toList();

          return Column(
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
                        backgroundImage: seller.logo != null
                            ? NetworkImage(seller.logo)
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
                  Icon(
                    Icons.phone,
                    size: 32.nsp,
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: AutoSizeText(
                      seller.contact.phone,
                      maxLines: 1,
                      style: GoogleFonts.montserrat(
                        fontSize: 30.nsp,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              ListaHorizontal(
                title: 'Quentinhas disponíveis',
                tagM: Random().nextDouble(),
                meals: allCurrentMeals,
              ),
              SizedBox(height: 40.h),
              ElevatedButton.icon(
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
              SizedBox(height: 10.h),
              ElevatedButton.icon(
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
              // TODO Acho que nesse caso não precisa de indicator, se estiver carregando mostra a estrela vazia
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

              // TODO Se der erro, não mostrar a estrela pro usuário não poder clicar
              // TODO Deletar esses comentários caso concordar
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
