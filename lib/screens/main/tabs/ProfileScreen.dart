import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rango/models/order.dart';
import 'package:rango/models/seller.dart';
import 'package:rango/resources/repository.dart';
import 'package:rango/screens/main/profile/EditAccountScreen.dart';
import 'package:rango/screens/main/profile/EditProfileScreen.dart';
import 'package:rango/screens/main/profile/HorariosScreen.dart';
import 'package:rango/screens/main/profile/OrderHistory.dart';
import 'package:rango/screens/main/profile/ProfileSettings.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rango/screens/main/profile/ReportsScreen.dart';
import 'package:rango/screens/main/profile/SetLocationScreen.dart';
import 'package:rango/utils/string_formatters.dart';
import 'package:rango/widgets/user/UserPicture.dart';

class ProfileScreen extends StatefulWidget {
  final Seller usuario;
  final PersistentTabController controller;

  ProfileScreen(this.usuario, this.controller);

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
      body: SingleChildScrollView(
          child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              flex: 0,
              child: UserPicture(picture: widget.usuario.logo),
            ),
            Flexible(
              flex: 0,
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
                        screen:
                            ProfileSettings(widget.usuario, widget.controller),
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
                      key: Key('fechaabre'),
                      onTap: () => _showCloseStoreDialog(widget.usuario),
                      child: Icon(
                        widget.usuario.active ? Icons.lock_open : Icons.lock,
                        color: widget.usuario.active ? yellow : Colors.red[300],
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
                              screen: SetLocationScreen(widget.usuario),
                              withNavBar: false,
                            ),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(60)),
                            color: yellow,
                          ),
                        ),
                        Container(
                          child: AutoSizeText(
                            'Localização da loja',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              color: yellow,
                              fontWeight: FontWeight.w500,
                            ),
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
                            onPressed: () => pushNewScreen(context,
                                screen: HorariosScreen(widget.usuario),
                                withNavBar: false),
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
            Flexible(
              flex: 0,
              child: Container(
                margin: EdgeInsets.only(top: 10, bottom: 5),
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
                              Icons.event_note,
                              color: Colors.white,
                            ),
                            onPressed: () => pushNewScreen(
                              context,
                              screen: OrderHistoryScreen(),
                              withNavBar: false,
                              pageTransitionAnimation:
                                  PageTransitionAnimation.cupertino,
                            ),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(60)),
                            color: yellow,
                          ),
                        ),
                        AutoSizeText(
                          'Histórico',
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
            _buildReports(widget.usuario),
          ],
        ),
      )),
    );
  }

  Widget _buildReports(Seller seller) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      width: 0.8.wp,
      child: StreamBuilder(
        stream: Repository.instance.getLastWeekOrders(seller.id),
        builder: (context, AsyncSnapshot<QuerySnapshot<Order>> ordersSnapshot) {
          if (!ordersSnapshot.hasData || ordersSnapshot.hasError) {
            return SizedBox();
          }

          var numberOfSales = ordersSnapshot.data.docs
              .map((e) => e.data().quantity)
              .fold(0, (p, c) => p + c);
          var numberOfClients = ordersSnapshot.data.docs
              .map((e) => e.data().clientId)
              .toSet()
              .length;
          var total = ordersSnapshot.data.docs
              .map((e) => e.data().quantity * e.data().price)
              .fold(0, (p, c) => p + c);

          return Column(
            children: [
              AutoSizeText(
                "Nos últimos 7 dias:",
                maxLines: 1,
                style: GoogleFonts.montserrat(
                  fontSize: 40.nsp,
                  color: Theme.of(context).accentColor,
                ),
              ),
              SizedBox(height: 5),
              AutoSizeText(
                numberOfSales > 0
                    ? 'Você vendeu $numberOfSales quentinha${numberOfSales > 1 ? 's' : ''}'
                        ' para $numberOfClients cliente${numberOfClients > 1 ? 's' : ''}'
                        ' e recebeu um total de ${intToCurrency(total)}.'
                    : 'Você ainda não vendeu sua primeira quentinha.',
                style: GoogleFonts.montserrat(
                  fontSize: 30.nsp,
                  color: Theme.of(context).accentColor,
                ),
              ),
              SizedBox(height: 10),
              Align(
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
                      screen: ReportsScreen(widget.usuario),
                      withNavBar: false,
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
