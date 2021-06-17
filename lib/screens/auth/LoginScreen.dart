import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rango/screens/auth/AuthScreen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334);
    final String assetName = 'assets/imgs/curva_home.svg';
    final String asset2Name = 'assets/imgs/curva2_home.svg';
    return Scaffold(
      backgroundColor: Color.fromRGBO(190, 235, 227, 1),
      body: Center(
        child: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Text(
                      "RANGO",
                      style: TextStyle(color: Colors.white, fontSize: 58.nsp),
                    ),
                  ),
                  Flexible(
                    flex: 3,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 0.05.wp, vertical: 0),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 20),
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context)
                              .pushNamed(AuthScreen.routeName, arguments: true),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: AutoSizeText(
                              'Login',
                              style: GoogleFonts.montserratTextTheme(
                                      Theme.of(context).textTheme)
                                  .button
                                  .copyWith(fontSize: 38.nsp),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 3,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 0.05.wp, vertical: 0),
                      child: Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pushNamed(
                              AuthScreen.routeName,
                              arguments: false),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: AutoSizeText(
                              'Cadastro',
                              style: GoogleFonts.montserratTextTheme(
                                      Theme.of(context).textTheme)
                                  .button
                                  .copyWith(fontSize: 38.nsp),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                child: SvgPicture.asset(
                  assetName,
                  semanticsLabel: 'curvaHome',
                  width: 1.wp,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                child: SvgPicture.asset(
                  asset2Name,
                  semanticsLabel: 'curva2Home',
                  width: MediaQuery.of(context).size.width,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
