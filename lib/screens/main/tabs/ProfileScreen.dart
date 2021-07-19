import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rango/models/seller.dart';
import 'package:rango/resources/repository.dart';
import 'package:rango/screens/main/profile/EditProfileScreen.dart';
import 'package:rango/screens/main/profile/HorariosScreen.dart';
import 'package:rango/screens/main/profile/ProfileSettings.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rango/screens/main/profile/ReportsScreen.dart';
import 'package:rango/screens/main/profile/SetLocationScreen.dart';
import 'package:rango/widgets/user/UserPicture.dart';

class ProfileScreen extends StatefulWidget {
  final Seller usuario;

  ProfileScreen(this.usuario);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final yellow = Color(0xFFF9B152);
  bool _loadingStore = false;

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
        height: 1.hp - 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Flexible(
              flex: 5,
              child: UserPicture(picture: widget.usuario.logo),
            ),
            Flexible(
              flex: 1,
              child: Container(
                constraints: BoxConstraints(maxWidth: 0.6.wp),
                margin: EdgeInsets.symmetric(vertical: 0.01.hp),
                child: AutoSizeText(
                  widget.usuario.name,
                  maxLines: 2,
                  textAlign: TextAlign.center,
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
                        withNavBar: false,
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
                        withNavBar: false,
                        pageTransitionAnimation:
                        PageTransitionAnimation.cupertino,
                      ),
                      child: Icon(
                        Icons.settings,
                        color: yellow,
                        size: ScreenUtil().setSp(48),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showCloseStoreDialog(widget.usuario),
                      child: Icon(
                        Icons.power_settings_new,
                        color: widget.usuario.active ? yellow : Colors.red[300],
                        size: ScreenUtil().setSp(48),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              flex: 3,
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 5),
                          child: IconButton(
                            iconSize: ScreenUtil().setSp(75),
                            icon: Icon(
                              Icons.map,
                              color: Colors.white,
                            ),
                            onPressed: () => pushNewScreen(
                              context,
                              screen: SetLocationScreen(),
                              withNavBar: false,
                            ),
                          ),
                          decoration: BoxDecoration(
                            borderRadius:
                            BorderRadius.all(Radius.circular(60)),
                            color: yellow,
                          ),
                        ),
                        AutoSizeText(
                          'Localização',
                          style: GoogleFonts.montserrat(
                            color: yellow,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 5),
                          child: IconButton(
                            iconSize: ScreenUtil().setSp(75),
                            icon: Icon(
                              Icons.schedule,
                              color: Colors.white,
                            ),
                            onPressed: () => pushNewScreen(
                              context,
                              screen: HorariosScreen(widget.usuario),
                              withNavBar: false,
                            ),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(60),
                            ),
                            color: yellow,
                          ),
                        ),
                        AutoSizeText(
                          'Meus horários',
                          style: GoogleFonts.montserrat(
                            color: yellow,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                  width: 0.8.wp,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        flex: 1,
                        child: AutoSizeText(
                          "Nos últimos 7 dias:",
                          maxLines: 1,
                          style: GoogleFonts.montserrat(
                            fontSize: 40.nsp,
                            color: Theme.of(context).accentColor,
                          ),
                        ),
                      ),
                      SizedBox(height: 0.01.hp),
                      Flexible(
                        flex: 1,
                        child: AutoSizeText(
                          "Você realizou um total de X vendas para Y clientes e vendeu um total de ZZ,ZZ reais",
                          style: GoogleFonts.montserrat(
                            fontSize: 30.nsp,
                            color: Theme.of(context).accentColor,
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: 0.35.wp,
                            child: ElevatedButton(
                              child: AutoSizeText(
                                "Ver mais",
                                style: TextStyle(fontSize: 36.nsp),
                              ),
                              onPressed: () => pushNewScreen(
                                context,
                                screen: ReportsScreen(),
                                withNavBar: false,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }

  void _showCloseStoreDialog(Seller seller) => showDialog(
        context: context,
        builder: (BuildContext ctx) => AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 0.1.wp),
          backgroundColor: Color(0xFFF9B152),
          actionsPadding: EdgeInsets.all(10),
          contentPadding: EdgeInsets.only(
            top: 20,
            left: 24,
            right: 24,
            bottom: 0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            !seller.active ? 'Abrindo a loja' : 'Fechando a loja',
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 38.ssp,
            ),
          ),
          actions: _loadingStore
              ? null
              : [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(
                      'Cancelar',
                      style: GoogleFonts.montserrat(
                        decoration: TextDecoration.underline,
                        color: Colors.white,
                        fontSize: 34.nsp,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: seller.active
                        ? () async {
                            try {
                              setState(() => _loadingStore = true);
                              await Repository.instance.closeStore(seller.id);
                              setState(() => _loadingStore = false);
                              Navigator.of(ctx).pop();
                            } catch (error) {
                              setState(() => _loadingStore = false);
                              Navigator.of(ctx).pop();
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Ocorreu um erro ao tentar fechar a loja, tente novamente',
                                    textAlign: TextAlign.center,
                                  ),
                                  backgroundColor: Theme.of(context).errorColor,
                                ),
                              );
                            }
                          }
                        : () async {
                            try {
                              setState(() => _loadingStore = true);
                              await Repository.instance.openStore(seller.id);
                              setState(() => _loadingStore = false);
                              Navigator.of(ctx).pop();
                            } catch (error) {
                              setState(() => _loadingStore = false);
                              Navigator.of(ctx).pop();
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Ocorreu um erro ao tentar fechar a loja, tente novamente',
                                    textAlign: TextAlign.center,
                                  ),
                                  backgroundColor: Theme.of(context).errorColor,
                                ),
                              );
                            }
                          },
                    child: Text(
                      seller.active ? 'Fechar' : 'Abrir',
                      style: GoogleFonts.montserrat(
                        decoration: TextDecoration.underline,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 34.nsp,
                      ),
                    ),
                  ),
                ],
          content: _loadingStore
              ? SizedBox(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                )
              : Text(
                  seller.active
                      ? 'Deseja realmente fechar a loja? Ela ficará fechada até ser aberta manualmente novamente.'
                      : 'Deseja realmente abrir a loja? Clientes poderão realizar reservas com você.',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 28.nsp,
                  ),
                ),
        ),
      );
}
