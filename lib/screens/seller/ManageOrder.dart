import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rango/models/order.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ManageOrder extends StatelessWidget {
  final Order order;
  final bool isEdit;

  ManageOrder({
    this.order,
    @required this.isEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  EdgeInsets.symmetric(vertical: 0.06.hp, horizontal: 0.02.wp),
              child: AutoSizeText(
                isEdit ? "Edite a quentinha" : "E aí, o que tem hoje?",
                style: GoogleFonts.montserrat(
                    fontSize: 28.ssp,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).accentColor),
              ),
            ),
            Center(
              child: Container(
                width: 0.8.wp,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Color(0xFFFFAEEDE),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (order.quentinha.picture != null)
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 0.01.hp, horizontal: 0.02.wp),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: FadeInImage.assetNetwork(
                              placeholder:
                                  'assets/imgs/quentinha_placeholder.png',
                              image: order.quentinha.picture != null
                                  ? order.quentinha.picture
                                  : 'assets/imgs/quentinha_placeholder.png',
                              fit: BoxFit.cover,
                              height: 150.h,
                              width: 0.3.wp,
                            ),
                          ),
                        ),
                      if (order.quentinha.picture == null)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 0.06.wp,
                            vertical: 0.05.hp,
                          ),
                          child: Icon(
                            Icons.photo,
                            color: Theme.of(context).accentColor,
                          ),
                        ),
                      if (order == null)
                        Flexible(
                          child: Container(
                            margin: EdgeInsets.only(right: 0.06.wp),
                            constraints: BoxConstraints(maxWidth: 0.6.wp),
                            child: Column(
                              children: [
                                AutoSizeText(
                                  "Nome do prato",
                                  overflow: TextOverflow.visible,
                                  style: GoogleFonts.montserrat(
                                      fontSize: 28.ssp,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).accentColor),
                                ),
                                AutoSizeText(
                                  "Descrição",
                                  style: GoogleFonts.montserrat(
                                      fontSize: 28.ssp,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).accentColor),
                                ),
                                AutoSizeText(
                                  "Valor",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 28.ssp,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).accentColor,
                                  ),
                                ),
                                AutoSizeText(
                                  "Quantidade disponível",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 28.ssp,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).accentColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (order != null)
                        Flexible(
                          child: Container(
                            margin: EdgeInsets.only(right: 0.06.wp),
                            constraints: BoxConstraints(maxWidth: 0.6.wp),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(bottom: 0.01.hp),
                                  child: AutoSizeText(
                                    order.quentinha.name,
                                    style: GoogleFonts.montserrat(
                                        fontSize: 28.nsp,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context).accentColor),
                                  ),
                                ),
                                if (order.quentinha.description != null &&
                                    order.quentinha.description != "")
                                  Container(
                                    margin: EdgeInsets.only(bottom: 0.01.hp),
                                    child: AutoSizeText(
                                      order.quentinha.description,
                                      style: GoogleFonts.montserrat(
                                          fontSize: 28.ssp,
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context).accentColor),
                                    ),
                                  ),
                                Container(
                                  margin: EdgeInsets.only(bottom: 0.01.hp),
                                  child: AutoSizeText(
                                    order.quentinha.price.toString(),
                                    style: GoogleFonts.montserrat(
                                        fontSize: 28.ssp,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context).accentColor),
                                  ),
                                ),
                                AutoSizeText(
                                  "Quantidade: 2",
                                  style: GoogleFonts.montserrat(
                                      fontSize: 28.ssp,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).accentColor),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: RaisedButton(
                onPressed: () => {},
                child: Text("Confirmar"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
