import 'package:flutter/material.dart';
import 'package:rango/models/client.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rango/resources/repository.dart';
import 'package:rango/utils/constants.dart';
import 'package:rango/widgets/others/NoConecctionWidget.dart';

class SearchScreen extends StatefulWidget {
  final Client usuario;
  final bool hasInternet;
  SearchScreen(this.usuario, this.hasInternet);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: !widget.hasInternet
          ? Container(
              height: 1.hp - 56,
              child: NoConecctionWidget(),
            )
          : Center(
              child: Text('oi'),
            ),
    );
  }
}
