import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rango/models/client.dart';

class ProfileScreen extends StatefulWidget {
  final Client usuario;

  ProfileScreen(this.usuario);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Meu Perfil",
          style: GoogleFonts.montserrat(
              color: Theme.of(context).accentColor, fontSize: 25),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).backgroundColor,
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: Padding(
        padding: EdgeInsets.only(top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 50, bottom: 40),
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Color(0xFFF9B152)),
                ),
                CircleAvatar(
                  backgroundImage: widget.usuario.picture != null
                      ? NetworkImage(widget.usuario.picture)
                      : null,
                  radius: 80,
                ),
              ],
            ),
            Text(widget.usuario.name),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.edit),
                Icon(Icons.settings),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[Text('Favoritos'), Icon(Icons.star)],
            ),
            Container(
              color: Colors.deepOrange,
              child: Text('Quentinha Colorida'),
            ),
          ],
        ),
      ),
    );
  }
}
