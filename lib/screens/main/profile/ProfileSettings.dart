import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:rango/models/client.dart';
import 'package:rango/resources/rangeChangeNotifier.dart';
import 'package:rango/resources/repository.dart';
import 'package:rango/screens/main/profile/AboutScreen.dart';
import 'package:rango/widgets/settings/CustomCheckBox.dart';

class ProfileSettings extends StatefulWidget {
  final Client user;
  final double sellerRange;

  ProfileSettings(this.user, this.sellerRange);

  @override
  _ProfileSettingsState createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  bool _switchValue = false;
  bool _attValue = false;
  bool _reservaValue = false;
  bool _newMessagesValue = false;
  bool _promotionsValue = false;
  TextEditingController _rangeController;

  @override
  void initState() {
    _rangeController =
        TextEditingController(text: widget.sellerRange.toString());

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
                fontSize: 34.nsp,
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
                fontSize: 34.nsp,
              ),
            ),
          ),
        ],
        title: Text(
          'Já satisfeito?',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 38.ssp,
          ),
        ),
        content: Text(
          'Tem certeza que deseja sair da sua conta?',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 28.nsp,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFC744F);
    const green = Color(0xFF609B90);
    return Scaffold(
        appBar: AppBar(
          title: AutoSizeText(
            'Configurações',
            style: GoogleFonts.montserrat(
              color: Theme.of(context).accentColor,
              fontSize: 38.nsp,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(top: 0.02.hp),
            margin: EdgeInsets.symmetric(horizontal: 0.08.wp),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(right: 0.09.wp),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AutoSizeText(
                        'Notificações',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: orange,
                          fontSize: 38.nsp,
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
                  padding: EdgeInsets.only(left: 0.02.wp),
                  child: Column(
                    children: [
                      Container(
                        height: 0.07.hp,
                        child: CustomCheckBox(
                          changeValue: (value) =>
                              setState(() => _attValue = value),
                          text: 'Atualização dos vendedores favoritos',
                          value: _attValue,
                          isActive: _switchValue,
                        ),
                      ),
                      Container(
                        height: 0.07.hp,
                        child: CustomCheckBox(
                          changeValue: (value) =>
                              setState(() => _reservaValue = value),
                          text: 'Reserva confirmada',
                          value: _reservaValue,
                          isActive: _switchValue,
                        ),
                      ),
                      Container(
                        height: 0.07.hp,
                        child: CustomCheckBox(
                          changeValue: (value) =>
                              setState(() => _newMessagesValue = value),
                          text: 'Novas mensagens',
                          value: _newMessagesValue,
                          isActive: _switchValue,
                        ),
                      ),
                      Container(
                        height: 0.07.hp,
                        child: CustomCheckBox(
                          changeValue: (value) =>
                              setState(() => _promotionsValue = value),
                          text: 'Promoções',
                          value: _promotionsValue,
                          isActive: _switchValue,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 0.01.hp),
                  width: 0.6.wp,
                  // TODO Mudar isso para um slider?
                  child: TextField(
                    controller: _rangeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      focusColor: orange,
                      fillColor: orange,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: orange),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: orange),
                      ),
                      labelStyle: GoogleFonts.montserrat(
                        color: orange,
                        fontSize: 35.nsp,
                      ),
                      labelText: 'Raio de busca (km)',
                      hintText: 'Raio de busca',
                      suffixText: 'km',
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 0.01.hp),
                  width: 0.6.wp,
                  child: ElevatedButton(
                    onPressed: () => _saveSettings(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          vertical: 0.01.hp, horizontal: 0.1.wp),
                      child: AutoSizeText(
                        'Confirmar',
                        style: GoogleFonts.montserrat(
                          fontSize: 36.nsp,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 0.02.hp),
                  child: GestureDetector(
                    onTap: () => pushNewScreen(
                      context,
                      screen: AboutScreen(),
                      withNavBar: true,
                      pageTransitionAnimation:
                          PageTransitionAnimation.cupertino,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: AutoSizeText(
                        'Sobre',
                        style: GoogleFonts.montserrat(
                          fontSize: 36.nsp,
                          decoration: TextDecoration.underline,
                          color: green,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 0.02.hp),
                  child: GestureDetector(
                    onTap: _logout,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: AutoSizeText(
                        'Sair',
                        style: GoogleFonts.montserrat(
                          fontSize: 36.nsp,
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
        ));
  }

  void _saveSettings(context) async {
    try {
      await Repository.instance.setSellerRange(
          double.parse(_rangeController.text.replaceAll(',', '.')));
      Provider.of<RangeChangeNotifier>(context, listen: false).triggerRefresh();
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).accentColor,
          content: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Configurações salvas com sucesso.",
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    } catch (e) {
      print(e);
    }
  }
}
