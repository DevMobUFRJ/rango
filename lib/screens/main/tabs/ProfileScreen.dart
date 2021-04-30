import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rango/models/seller.dart';
import 'package:rango/screens/main/profile/EditProfileScreen.dart';
import 'package:rango/screens/main/profile/ProfileSettings.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileScreen extends StatefulWidget {
  final Seller usuario;

  ProfileScreen(this.usuario);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final yellow = Color(0xFFF9B152);
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334);
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
        height: MediaQuery.of(context).size.height - kToolbarHeight - 86,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
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
                constraints: BoxConstraints(maxWidth: 0.6.wp),
                margin: EdgeInsets.symmetric(vertical: 0.01.hp),
                child: AutoSizeText(
                  widget.usuario.name,
                  maxLines: 1,
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
                        screen: EditProfileScreen(widget.usuario),
                        withNavBar: true,
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
                        screen: ProfileSettings(widget.usuario),
                        withNavBar: true,
                        pageTransitionAnimation:
                            PageTransitionAnimation.cupertino,
                      ),
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
              flex: 2,
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 0.03.wp, vertical: 0.01.hp),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 5),
                          child: IconButton(
                            iconSize: ScreenUtil().setSp(90),
                            icon: Icon(
                              Icons.map,
                              color: Colors.white,
                            ),
                            onPressed: () => {},
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(60)),
                            color: yellow,
                          ),
                        ),
                        AutoSizeText(
                          'Localização',
                          style: GoogleFonts.montserrat(
                            color: yellow,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 5),
                          child: IconButton(
                            iconSize: ScreenUtil().setSp(90),
                            icon: Icon(
                              Icons.schedule,
                              color: Colors.white,
                            ),
                            onPressed: () => {},
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(60)),
                            color: yellow,
                          ),
                        ),
                        AutoSizeText(
                          'Meus horários',
                          style: GoogleFonts.montserrat(
                            color: yellow,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                  child: Column(
                children: [
                  AutoSizeText("Resumo dos últimos 7 dias:"),
                  AutoSizeText("Você realizou X vendas para Y clientes"),
                  AutoSizeText("E vendeu um total de ZZ,ZZ reais"),
                  RaisedButton(child: Text("Ver mais"), onPressed: () => {}),
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }
}
