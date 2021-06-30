import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rango/models/client.dart';
import 'package:rango/models/seller.dart';
import 'package:rango/resources/repository.dart';
import 'package:rango/screens/main/profile/EditProfileScreen.dart';
import 'package:rango/screens/main/profile/ProfileSettings.dart';
import 'package:rango/screens/seller/SellerProfile.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileScreen extends StatefulWidget {
  final Client usuario;

  ProfileScreen(this.usuario);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final yellow = Color(0xFFF9B152);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          "Meu Perfil",
          maxLines: 1,
          style: GoogleFonts.montserrat(color: Theme.of(context).accentColor),
        ),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: Container(
        padding: EdgeInsets.only(left: 0.1.wp, right: 0.1.wp),
        height: 1.hp - 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Flexible(
              flex: 4,
              child: Container(
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    FittedBox(
                      fit: BoxFit.cover,
                      child: Container(
                        margin: EdgeInsets.only(left: 80.w, bottom: 50.h),
                        height: 230.h,
                        width: 260.w,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(ScreenUtil().setSp(30)),
                          color: yellow,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: CircleAvatar(
                          backgroundColor: Theme.of(context).accentColor,
                          backgroundImage: widget.usuario.picture != null
                              ? NetworkImage(widget.usuario.picture)
                              : null,
                          radius: 150.w,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 0.01.hp),
                child: AutoSizeText(
                  widget.usuario.name,
                  style: GoogleFonts.montserrat(
                    color: Theme.of(context).accentColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 35.ssp,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 0.01.hp),
                width: 0.48.wp,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () => pushNewScreen(
                        context,
                        withNavBar: false,
                        screen: EditProfileScreen(widget.usuario),
                        pageTransitionAnimation:
                            PageTransitionAnimation.cupertino,
                      ),
                      child: Icon(
                        Icons.edit,
                        color: yellow,
                        size: ScreenUtil().setSp(48),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        var sellerRange =
                            await Repository.instance.getSellerRange();
                        return pushNewScreen(
                          context,
                          withNavBar: false,
                          screen: ProfileSettings(widget.usuario, sellerRange),
                          pageTransitionAnimation:
                              PageTransitionAnimation.cupertino,
                        );
                      },
                      child: Icon(
                        Icons.settings,
                        color: yellow,
                        size: ScreenUtil().setSp(48),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 0.03.wp, vertical: 0.01.hp),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    AutoSizeText(
                      'Favoritos',
                      maxLines: 1,
                      style: GoogleFonts.montserrat(
                        color: yellow,
                        fontSize: 35.nsp,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(
                      Icons.star,
                      color: yellow,
                      size: ScreenUtil().setSp(35),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 7,
              child: Container(
                child: StreamBuilder(
                  stream:
                      Repository.instance.getClientStream(widget.usuario.id),
                  builder: (context,
                      AsyncSnapshot<DocumentSnapshot> clientSnapshot) {
                    if (clientSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Container(
                        height: 0.4.hp,
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
                    if (clientSnapshot.data.data['favoriteSellers'] == null) {
                      return Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: 0.03.wp, vertical: 15),
                        child: AutoSizeText(
                          'Você ainda não marcou vendedores como favoritos.',
                          style: GoogleFonts.montserrat(
                            color: yellow,
                            fontSize: 45.nsp,
                          ),
                        ),
                      );
                    }
                    if (clientSnapshot.hasError) {
                      return Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: 0.03.wp, vertical: 15),
                        child: AutoSizeText(
                          clientSnapshot.error.toString(),
                          style: GoogleFonts.montserrat(
                            color: yellow,
                            fontSize: 45.nsp,
                          ),
                        ),
                      );
                    }
                    final favoriteSellers = List<String>.from(
                        clientSnapshot.data.data['favoriteSellers']);

                    // Um belo exemplo de list view! A busca pelo seller só acontece quando o elemento pode aparecer na tela.
                    // Usa-se um StreamBuilder para aproveitar a cache do firestore
                    return ListView.separated(
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 0.01.hp),
                      itemCount: favoriteSellers.length,
                      itemBuilder: (ctx, index) => StreamBuilder(
                        stream: Repository.instance
                            .getSeller(favoriteSellers[index]),
                        builder: (context,
                            AsyncSnapshot<DocumentSnapshot> sellerSnapshot) {
                          // TODO (Gabriel): Trocar esse indicator por um placeholder
                          if (!sellerSnapshot.hasData) {
                            return Center(child: CircularProgressIndicator());
                          }
                          if (sellerSnapshot.hasError) {
                            return Text(sellerSnapshot.error.toString());
                          }

                          Seller seller = Seller.fromJson(
                              sellerSnapshot.data.data,
                              id: sellerSnapshot.data.documentID);

                          return GestureDetector(
                            onTap: () => pushNewScreen(
                              context,
                              withNavBar: false,
                              screen: SellerProfile(seller.id, seller.name),
                              pageTransitionAnimation:
                                  PageTransitionAnimation.cupertino,
                            ),
                            child: Container(
                              height: 120.h,
                              padding: EdgeInsets.symmetric(
                                  vertical: 0.01.hp, horizontal: 0.05.wp),
                              decoration: BoxDecoration(
                                color: Theme.of(context).accentColor,
                                borderRadius: BorderRadius.circular(
                                  ScreenUtil().setSp(22),
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(seller.picture),
                                    radius: ScreenUtil().setSp(50),
                                  ),
                                  SizedBox(width: 0.03.wp),
                                  AutoSizeText(
                                    seller.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w300,
                                      decoration: TextDecoration.underline,
                                      fontSize: 32.nsp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
