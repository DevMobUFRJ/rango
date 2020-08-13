import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rango/dadosMarretados.dart';
import 'package:rango/models/client.dart';
import 'package:rango/screens/main/profile/EditProfileScreen.dart';
import 'package:rango/screens/main/profile/ProfileSettings.dart';
import 'package:rango/screens/seller/SellerProfile.dart';

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
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Meu Perfil",
          style: GoogleFonts.montserrat(
              color: Theme.of(context).accentColor, fontSize: 22),
        ),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: Container(
        padding:
            EdgeInsets.only(top: 20, left: width * 0.1, right: width * 0.1),
        height: MediaQuery.of(context).size.height - kToolbarHeight - 86,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 4,
              child: Container(
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
                        backgroundImage: widget.usuario.picture != null
                            ? NetworkImage(widget.usuario.picture)
                            : null,
                        radius: 80,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Text(widget.usuario.name,
                    style: GoogleFonts.montserrat(
                      color: Theme.of(context).accentColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    )),
              ),
            ),
            Flexible(
              flex: 1,
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                width: width * 0.48,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () => pushNewScreen(
                        context,
                        screen: EditProfileScreen(widget.usuario),
                        withNavBar: true,
                        pageTransitionAnimation:
                            PageTransitionAnimation.cupertino,
                      ),
                      child: Icon(
                        Icons.edit,
                        color: yellow,
                        size: 28,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => pushNewScreen(
                        context,
                        screen: ProfileSettings(widget.usuario),
                        withNavBar: true,
                        pageTransitionAnimation:
                            PageTransitionAnimation.cupertino,
                      ),
                      child: Icon(
                        Icons.settings,
                        color: yellow,
                        size: 28,
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
                    horizontal: width * 0.03, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Favoritos',
                      style: GoogleFonts.montserrat(
                        color: yellow,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(
                      Icons.star,
                      color: yellow,
                      size: 20,
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.3,
                child: ListView.separated(
                  separatorBuilder: (context, index) => SizedBox(height: 5),
                  itemCount: sellers.length,
                  itemBuilder: (ctx, index) => GestureDetector(
                    onTap: () => pushNewScreen(
                      context,
                      screen: SellerProfile(sellers[index].name),
                      withNavBar: true,
                      pageTransitionAnimation:
                          PageTransitionAnimation.cupertino,
                    ),
                    child: Container(
                      height: 70,
                      margin: EdgeInsets.only(bottom: 10),
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                          color: Theme.of(context).accentColor,
                          borderRadius: BorderRadius.circular(18)),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage:
                                NetworkImage(sellers[index].picture),
                            radius: 25,
                          ),
                          SizedBox(width: 10),
                          Text(
                            sellers[index].name,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
