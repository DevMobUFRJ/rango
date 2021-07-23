import 'package:auto_size_text/auto_size_text.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:data_connection_checker/data_connection_checker.dart';

class NoConnection extends StatefulWidget {
  NoConnection();

  _NoConnectionState createState() => _NoConnectionState();
}

class _NoConnectionState extends State<NoConnection> {
  bool isDeviceConnected = true;
  var subscription;

  initState() {
    super.initState();
    subscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) async {
      if (result != ConnectivityResult.none) {
        bool connected = await DataConnectionChecker().hasConnection;
        setState(() {
          isDeviceConnected = connected;
        });
      } else {
        setState(() {
          isDeviceConnected = false;
        });
      }
    });
  }

  dispose() {
    super.dispose();
    subscription.cancel();
  }

  Widget build(BuildContext context) {
    return !isDeviceConnected
        ? Padding(
        padding: EdgeInsets.only(bottom: 56),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                  padding: EdgeInsets.all(10),
                  color: Colors.red[400],
                  child: Center(
                    child: AutoSizeText(
                      'Você não possui conexão com a internet. Para usar o app corretamente, conecte-se à uma rede.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        decoration: TextDecoration.none,
                        color: Colors.white,
                        fontSize: 28.nsp,
                      ),
                    ),
                  )
              )
            ]
        )
    )
        : SizedBox();
  }
}