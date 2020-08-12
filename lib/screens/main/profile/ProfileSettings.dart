import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rango/screens/main/profile/AboutScreen.dart';
import 'package:rango/widgets/settings/CustomCheckBox.dart';

class ProfileSettings extends StatefulWidget {
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
                    onChanged: (value) => setState(() => _switchValue = value),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: (width * 0.06)),
              child: CustomCheckBox(
                changeValue: (value) => setState(() => _attValue = value),
                text: 'Atualização dos vendedores favoritos',
                value: _attValue,
                isActive: _switchValue,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: (width * 0.06)),
              child: CustomCheckBox(
                changeValue: (value) => setState(() => _reservaValue = value),
                text: 'Reserva confirmada',
                value: _reservaValue,
                isActive: _switchValue,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: (width * 0.06)),
              child: CustomCheckBox(
                changeValue: (value) =>
                    setState(() => _newMessagesValue = value),
                text: 'Novas mensagens',
                value: _newMessagesValue,
                isActive: _switchValue,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: (width * 0.06)),
              child: CustomCheckBox(
                changeValue: (value) =>
                    setState(() => _promotionsValue = value),
                text: 'Promoções',
                value: _promotionsValue,
                isActive: _switchValue,
              ),
            ),
            Container(
              width: width * 0.6,
              padding: EdgeInsets.symmetric(vertical: height * 0.01),
              margin: EdgeInsets.symmetric(vertical: height * 0.03),
              child: RaisedButton(
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
                onTap: () => FirebaseAuth.instance.signOut(),
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
