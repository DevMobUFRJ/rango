import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  bool _switchValue;
  bool _reservaValue;
  bool _newMessagesValue;
  double _rangeValue;

  @override
  void initState() {
    _rangeValue = widget.sellerRange;
    setState(
      () {
        if (widget.user.notificationSettings == null) {
          _switchValue = false;
          _reservaValue = false;
          _newMessagesValue = false;
        } else {
          _switchValue = true;
          _reservaValue = widget.user.notificationSettings.reservations != null
              ? widget.user.notificationSettings.reservations
              : false;
          _newMessagesValue = widget.user.notificationSettings.messages != null
              ? widget.user.notificationSettings.messages
              : false;
        }
      },
    );
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
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await FirebaseAuth.instance.signOut();
              Navigator.of(ctx).pop();
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
                        color: Theme.of(context).accentColor,
                        fontSize: 38.nsp,
                      ),
                    ),
                    Switch(
                      value: _switchValue,
                      activeColor: Theme.of(context).accentColor,
                      onChanged: (value) => setState(() {
                        _switchValue = value;
                        if (value == false) {
                          _reservaValue = false;
                          _newMessagesValue = false;
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
                            setState(() => _reservaValue = value),
                        text: 'Atualizações de pedidos',
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
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 0.01.hp),
                width: 0.75.wp,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      'Raio de busca',
                      style: GoogleFonts.montserrat(
                        color: Theme.of(context).accentColor,
                        fontSize: 30.nsp,
                      ),
                    ),
                    Slider(
                      value: _rangeValue,
                      min: 1,
                      max: 50,
                      onChanged: (value) => setState(
                        () => _rangeValue = value.round().toDouble(),
                      ),
                      activeColor: Theme.of(context).accentColor,
                    ),
                    Center(
                      child: AutoSizeText(
                        ' ${_rangeValue.ceil().toString()} Km',
                        style: GoogleFonts.montserrat(
                          color: Theme.of(context).accentColor,
                          fontSize: 30.nsp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 0.01.hp),
                width: 0.5.wp,
                child: ElevatedButton(
                  onPressed: () => _saveSettings(context),
                  child: Container(
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
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
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
      ),
    );
  }

  void _saveSettings(context) async {
    try {
      await Repository.instance.setSellerRange(
        double.parse(
          _rangeValue.toString().replaceAll(',', '.'),
        ),
      );
      Provider.of<RangeChangeNotifier>(context, listen: false).triggerRefresh();
      Map<String, dynamic> dataToUpdate = {};
      if (_switchValue = false) {
        Map<String, dynamic> notifications = {};
        notifications['messages'] = false;
        notifications['reservations'] = false;
        dataToUpdate['notifications'] = notifications;
      } else {
        Map<String, dynamic> notifications = {};
        notifications['messages'] = _newMessagesValue;
        notifications['reservations'] = _reservaValue;
        dataToUpdate['notifications'] = notifications;
      }
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (dataToUpdate.length > 0) {
        await FirebaseFirestore.instance
            .collection('clients')
            .doc(firebaseUser.uid)
            .update(dataToUpdate);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 2),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 2),
          content: Text(
            e.toString(),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      print(e);
    }
  }
}
