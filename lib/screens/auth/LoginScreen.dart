import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rango/screens/auth/AuthScreen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                      style: TextStyle(color: Colors.white, fontSize: 30.0),
                    ),
                  ),
                  Flexible(
                    fit: FlexFit.loose,
                    flex: 3,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 20),
                        width: double.infinity,
                        child: RaisedButton(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          onPressed: () => Navigator.of(context)
                              .pushNamed(AuthScreen.routeName, arguments: true),
                          child: Text(
                            'Login',
                            style: GoogleFonts.montserratTextTheme(
                                    Theme.of(context).textTheme)
                                .button,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 3,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 20),
                        width: double.infinity,
                        child: RaisedButton(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          onPressed: () => Navigator.of(context).pushNamed(
                              AuthScreen.routeName,
                              arguments: false),
                          child: Text(
                            'Cadastro',
                            style: GoogleFonts.montserratTextTheme(
                                    Theme.of(context).textTheme)
                                .button,
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
                  width: MediaQuery.of(context).size.width,
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
