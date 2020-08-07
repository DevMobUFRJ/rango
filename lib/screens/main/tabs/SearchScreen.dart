import 'package:flutter/material.dart';
import 'package:rango/models/client.dart';

class SearchScreen extends StatefulWidget {
  final Client usuario;

  SearchScreen(this.usuario);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Center(
        child: Text('oi'),
      ),
    );
  }
}
