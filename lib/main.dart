import 'package:flutter/material.dart';
import 'package:rango/screens/AuthScreen.dart';
import 'package:rango/screens/HomeScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rango',
      theme: ThemeData(
        buttonTheme: ButtonTheme.of(context).copyWith(
          buttonColor: Color.fromRGBO(252, 116, 79, 1),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
      home: HomeScreen(),
      routes: {
        AuthScreen.routeName: (ctx) => AuthScreen(),
      },
    );
  }
}
