import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rango/screens/auth/AuthScreen.dart';
import 'package:rango/screens/LoginScreen.dart';
import 'package:rango/screens/main/NewTabsScreen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rango/screens/reserva/DetalhesQuentinhaScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rango',
      theme: ThemeData(
        backgroundColor: Color(0xFFF5F5F5),
        accentColor: Colors.deepOrange[300],
        primaryColor: Color(0xFF8FDDCE),
        textTheme: GoogleFonts.montserratTextTheme(Theme.of(context).textTheme)
            .copyWith(
          headline1: TextStyle(
            fontSize: 35,
            color: Colors.deepOrange[300],
            fontWeight: FontWeight.w500,
          ),
          headline2: TextStyle(
            fontSize: 20,
            color: Color(0xFFF9B152),
          ),
          button: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        buttonTheme: ButtonTheme.of(context).copyWith(
          buttonColor: Color.fromRGBO(252, 116, 79, 1),
          textTheme: ButtonTextTheme.accent,
          colorScheme:
              Theme.of(context).colorScheme.copyWith(secondary: Colors.white),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.onAuthStateChanged,
        builder: (ctx, userSnapshot) {
          if (userSnapshot.hasData) {
            return NewTabsScreen();
          }
          return LoginScreen();
        },
      ),
      routes: {
        AuthScreen.routeName: (ctx) => AuthScreen(),
        DetalhesQuentinhaScreen.routeName: (ctx) => DetalhesQuentinhaScreen(),
      },
    );
  }
}
