import 'package:flutter/material.dart';
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
          style: TextStyle(color: Theme.of(context).accentColor, fontSize: 25),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).backgroundColor,
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: Center(
        child: Text(widget.usuario.name),
      ),
    );
  }
}
