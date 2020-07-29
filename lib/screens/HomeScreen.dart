import 'package:flutter/material.dart';
import 'package:rango/screens/AuthScreen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(190, 235, 227, 1),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  "RANGO",
                  style: TextStyle(color: Colors.white, fontSize: 30.0),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  child: SizedBox(
                    width: double.infinity,
                    child: RaisedButton(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      onPressed: () =>
                          Navigator.of(context).pushNamed(AuthScreen.routeName),
                      child: Text(
                        'Login',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  child: SizedBox(
                    width: double.infinity,
                    child: RaisedButton(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      onPressed: () {},
                      child: Text(
                        'Cadastro',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
