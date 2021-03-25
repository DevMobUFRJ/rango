import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rango/models/order.dart';
import 'package:rango/screens/seller/ChatScreen.dart';

class OrderScreen extends StatelessWidget {
  final Order order;

  OrderScreen({
    @required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          'Reserva',
          maxLines: 1,
          style: GoogleFonts.montserrat(
            color: Theme.of(context).accentColor,
            fontSize: 35.nsp,
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.only(top: 0.02.hp),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.08.wp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoSizeText(
                order.quentinha.name,
                style:
                    GoogleFonts.montserratTextTheme(Theme.of(context).textTheme)
                        .headline2
                        .copyWith(fontSize: 42.nsp),
              ),
              SizedBox(height: 0.01.hp),
              AutoSizeText(
                "Cliente: " + order.cliente.name,
                style: GoogleFonts.montserrat(
                  color: Theme.of(context).accentColor,
                  fontSize: 42.nsp,
                ),
              ),
              if (order.cliente.phone != null)
                AutoSizeText(
                  "Tel: " + order.cliente.phone,
                  style: GoogleFonts.montserrat(
                    color: Theme.of(context).accentColor,
                    fontSize: 42.nsp,
                  ),
                ),
              SizedBox(height: 0.01.hp),
              Center(
                child: RaisedButton(
                  onPressed: () => pushNewScreen(
                    context,
                    screen: ChatScreen(order.cliente),
                  ),
                  child: AutoSizeText(
                    'Chat com cliente',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
