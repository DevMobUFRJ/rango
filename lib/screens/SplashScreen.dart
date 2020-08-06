import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).primaryColor,
        child: Center(
            child: Text(
          "RANGO",
          style: GoogleFonts.montserrat(
              fontSize: 50, color: Theme.of(context).accentColor),
        )),
      ),
    );
  }
}
