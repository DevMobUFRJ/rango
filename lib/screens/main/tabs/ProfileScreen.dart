import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rango/models/client.dart';
import 'package:rango/models/seller.dart';
import 'package:rango/resources/repository.dart';
import 'package:rango/screens/main/profile/EditAccountScreen.dart';
import 'package:rango/screens/main/profile/EditProfileScreen.dart';
import 'package:rango/screens/main/profile/ProfileSettings.dart';
import 'package:rango/screens/seller/SellerProfile.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rango/widgets/user/UserPicture.dart';
import 'package:transparent_image/transparent_image.dart';

class ProfileScreen extends StatefulWidget {
  final Client usuario;
  final PersistentTabController controller;
  ProfileScreen(this.usuario, this.controller);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void initState() {
    super.initState();
  }

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
        padding: EdgeInsets.symmetric(horizontal: 0.1.wp),
        height: 1.hp - 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Flexible(
              flex: 0,
              child: UserPicture(widget.usuario.picture),
            ),
            Flexible(
              flex: 0,
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 0.01.hp),
                child: AutoSizeText(
                  widget.usuario.name,
                  maxLines: 2,
                  style: GoogleFonts.montserrat(
                    color: Theme.of(context).accentColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 35.ssp,
                  ),
                ),
              ),
            ),
            Flexible(
              flex: 0,
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
                      onTap: () => pushNewScreen(
                        context,
                        screen: EditAccountScreen(),
                        withNavBar: false,
                        pageTransitionAnimation:
                            PageTransitionAnimation.cupertino,
                      ),
                      child: Icon(
                        Icons.manage_accounts,
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
                          screen: ProfileSettings(
                              widget.usuario, sellerRange, widget.controller),
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
              flex: 0,
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
                        fontWeight: FontWeight.w500,
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
                flex: 5,
                child: (widget.usuario.favoriteSellers == null ||
                        widget.usuario.favoriteSellers.length == 0)
                    ? Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: 0.03.wp, vertical: 15),
                        child: AutoSizeText(
                          'Você ainda não marcou vendedores como favoritos.',
                          style: GoogleFonts.montserrat(
                            color: yellow,
                            fontSize: 45.nsp,
                          ),
                        ),
                      )
                    : ListView.separated(
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 0.01.hp),
                        itemCount: widget.usuario.favoriteSellers.length,
                        physics: ClampingScrollPhysics(),
                        itemBuilder: (ctx, index) => StreamBuilder(
                          stream: Repository.instance
                              .getSeller(widget.usuario.favoriteSellers[index]),
                          builder: (
                            context,
                            AsyncSnapshot<DocumentSnapshot<Seller>>
                                sellerSnapshot,
                          ) {
                            if (sellerSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container(
                                height: 0.3.hp,
                                alignment: Alignment.center,
                                child: SizedBox(
                                  height: 40,
                                  width: 40,
                                  child: CircularProgressIndicator(
                                    color: Theme.of(context).accentColor,
                                  ),
                                ),
                              );
                            }
                            if (sellerSnapshot.hasError) {
                              return Container(
                                height: 0.4.hp - 56,
                                alignment: Alignment.center,
                                child: AutoSizeText(
                                  sellerSnapshot.error.toString(),
                                  style: GoogleFonts.montserrat(
                                      fontSize: 45.nsp,
                                      color: Theme.of(context).accentColor),
                                ),
                              );
                            }

                            Seller seller = sellerSnapshot.data.data();
                            if (seller == null) {
                              Repository.instance.removeSellerFromClientFavorites(
                                  widget.usuario.id,
                                  widget.usuario.favoriteSellers[index]
                              );
                              return SizedBox();
                            }

                            return Material(
                              borderRadius: BorderRadius.circular(12),
                              elevation: 2,
                              child: GestureDetector(
                                onTap: () => pushNewScreen(
                                  context,
                                  withNavBar: false,
                                  screen: SellerProfile(
                                    seller.id,
                                    seller.name,
                                    widget.controller,
                                  ),
                                  pageTransitionAnimation:
                                      PageTransitionAnimation.cupertino,
                                ),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 0.01.hp, horizontal: 0.05.wp),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).accentColor,
                                    borderRadius: BorderRadius.circular(
                                      12,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          90,
                                        ),
                                        child: Container(
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    90,
                                                  ),
                                                  color: Colors.white,
                                                ),
                                                width: 60,
                                                height: 60,
                                              ),
                                              Center(
                                                child: Container(
                                                  child: Icon(
                                                    Icons.store,
                                                    size: 38,
                                                    color: Theme.of(context)
                                                        .accentColor,
                                                  ),
                                                ),
                                              ),
                                              if (seller.logo != null)
                                                CachedNetworkImage(
                                                  imageUrl: seller.logo,
                                                  fit: BoxFit.cover,
                                                  width: 60,
                                                  height: 60,
                                                  placeholder: (ctx, url) =>
                                                      Image(
                                                          image: MemoryImage(
                                                              kTransparentImage)),
                                                  errorWidget: (ctx, url,
                                                          error) =>
                                                      Image(
                                                          image: MemoryImage(
                                                              kTransparentImage)),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 0.03.wp),
                                      Container(
                                        width: 0.5.wp,
                                        child: AutoSizeText(
                                          seller.name,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.montserrat(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 32.nsp,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )),
          ],
        ),
      ),
    );
  }
}
