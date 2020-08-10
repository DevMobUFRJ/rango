import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Notificações',
                  style: TextStyle(
                    color: orange,
                    fontSize: 22,
                  ),
                ),
                Container(
                  child: Switch(
                    value: _switchValue,
                    activeColor: Color(0xFF609B90),
                    onChanged: (value) => setState(() => _switchValue = value),
                  ),
                ),
              ],
            ),
            CustomCheckBox(
              changeValue: (value) => setState(() => _attValue = value),
              text: 'Atualização dos vendedores favoritos',
              value: _attValue,
            ),
            CustomCheckBox(
              changeValue: (value) => setState(() => _reservaValue = value),
              text: 'Reserva confirmada',
              value: _reservaValue,
            ),
            CustomCheckBox(
              changeValue: (value) => setState(() => _newMessagesValue = value),
              text: 'Novas mensagens',
              value: _newMessagesValue,
            ),
            CustomCheckBox(
              changeValue: (value) => setState(() => _promotionsValue = value),
              text: 'Promoções',
              value: _promotionsValue,
            ),
          ],
        ),
      ),
    );
  }
}
