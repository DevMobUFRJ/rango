import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rango/models/client.dart';
import 'package:rango/screens/main/profile/AboutScreen.dart';
import 'package:rango/widgets/settings/CustomCheckBox.dart';

class ProfileSettings extends StatefulWidget {
  final Client user;

  ProfileSettings(this.user);

  @override
  _ProfileSettingsState createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  bool _switchValue = false;
  bool _attValue = false;
  bool _reservaValue = false;
  bool _newMessagesValue = false;
  bool _promotionsValue = false;

  @override
  void initState() {
    setState(() {
      _attValue = widget.user.notificationSettings != null &&
              widget.user.notificationSettings.favoriteSellers != null
          ? widget.user.notificationSettings.favoriteSellers
          : false;
      _reservaValue = widget.user.notificationSettings != null &&
              widget.user.notificationSettings.reservations != null
          ? widget.user.notificationSettings.reservations
          : false;
      _newMessagesValue = widget.user.notificationSettings != null &&
              widget.user.notificationSettings.messages != null
          ? widget.user.notificationSettings.messages
          : false;
      _promotionsValue = widget.user.notificationSettings != null &&
              widget.user.notificationSettings.discounts != null
          ? widget.user.notificationSettings.discounts
          : false;
    });
    super.initState();
  }

  void _logout() async {
    await showDialog(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 60),
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
        actions: [
          FlatButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              FirebaseAuth.instance.signOut();
            },
            child: Text(
              'Sair',
              style: GoogleFonts.montserrat(
                decoration: TextDecoration.underline,
                color: Colors.white,
              ),
            ),
          ),
          FlatButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancelar',
              style: GoogleFonts.montserrat(
                decoration: TextDecoration.underline,
                color: Colors.white,
              ),
            ),
          ),
        ],
        title: Text(
          'Já satisfeito?',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Tem certeza que deseja sair da sua conta?',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFC744F);
    const green = Color(0xFF609B90);
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.greenAccent),
        title: Text(
          'Configurações',
          style: GoogleFonts.montserrat(
            color: Theme.of(context).accentColor,
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.only(top: height * 0.05),
        margin: EdgeInsets.symmetric(horizontal: width * 0.08),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(right: width * 0.09),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notificações',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: orange,
                      fontSize: 22,
                    ),
                  ),
                  Switch(
                    value: _switchValue,
                    activeColor: Color(0xFF609B90),
                    onChanged: (value) => setState(() {
                      _switchValue = value;
                      if (value == false) {
                        _attValue = false;
                        _reservaValue = false;
                        _newMessagesValue = false;
                        _promotionsValue = false;
                      }
                    }),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: (width * 0.06)),
              child: Column(
                children: [
                  CustomCheckBox(
                    changeValue: (value) => setState(() => _attValue = value),
                    text: 'Atualização dos vendedores favoritos',
                    value: _attValue,
                    isActive: _switchValue,
                  ),
                  CustomCheckBox(
                    changeValue: (value) =>
                        setState(() => _reservaValue = value),
                    text: 'Reserva confirmada',
                    value: _reservaValue,
                    isActive: _switchValue,
                  ),
                  CustomCheckBox(
                    changeValue: (value) =>
                        setState(() => _newMessagesValue = value),
                    text: 'Novas mensagens',
                    value: _newMessagesValue,
                    isActive: _switchValue,
                  ),
                  CustomCheckBox(
                    changeValue: (value) =>
                        setState(() => _promotionsValue = value),
                    text: 'Promoções',
                    value: _promotionsValue,
                    isActive: _switchValue,
                  ),
                ],
              ),
            ),
            Container(
              width: width * 0.6,
              padding: EdgeInsets.symmetric(vertical: height * 0.01),
              margin: EdgeInsets.symmetric(vertical: height * 0.03),
              child: RaisedButton(
                padding: EdgeInsets.symmetric(vertical: 10),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                onPressed: () {},
                child: Text(
                  'Confirmar',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: height * 0.02),
              child: GestureDetector(
                onTap: () => pushNewScreen(
                  context,
                  screen: AboutScreen(),
                  withNavBar: true,
                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Sobre',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      decoration: TextDecoration.underline,
                      color: green,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: height * 0.02),
              child: GestureDetector(
                onTap: _logout,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Sair',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      decoration: TextDecoration.underline,
                      color: green,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
