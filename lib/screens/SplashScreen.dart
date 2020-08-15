import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334);
    return Scaffold(
      body: Container(
        color: Theme.of(context).primaryColor,
        child: Center(
          child: Text(
            "RANGO",
            style: GoogleFonts.montserrat(
              fontSize: 80.nsp,
              color: Theme.of(context).accentColor,
            ),
          ),
        ),
      ),
    );
  }
}
