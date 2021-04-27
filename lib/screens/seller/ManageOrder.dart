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
    this.isEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    TextEditingController _mealName;
    TextEditingController _mealValue;
    TextEditingController _mealDescription;
    TextEditingController _mealQuantity;
    if (order != null) {
      _mealName = TextEditingController(text: order.quentinha.name);
      _mealValue =
          TextEditingController(text: order.quentinha.price.toString());
      _mealDescription =
          TextEditingController(text: order.quentinha.description);
      _mealQuantity = TextEditingController();
    } else {
      _mealName = TextEditingController();
      _mealValue = TextEditingController();
      _mealDescription = TextEditingController();
      _mealQuantity = TextEditingController();
    }

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
                    fontSize: 42.ssp,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).accentColor),
              ),
            ),
            Center(
              child: Container(
                width: 0.9.wp,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Color(0xFFFFAEEDE),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 0.05.wp),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (order != null && order.quentinha.picture != null)
                          ClipRRect(
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
                        if (order == null || order.quentinha.picture == null)
                          Icon(
                            Icons.photo,
                            color: Theme.of(context).accentColor,
                            size: ScreenUtil().setSp(82),
                          ),
                        Flexible(
                          child: Container(
                            width: 0.5.wp,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                    bottom: 10,
                                  ),
                                  child: TextFormField(
                                    controller: _mealName,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 28.ssp,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).accentColor,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Nome do prato',
                                      hintStyle: GoogleFonts.montserrat(
                                        fontSize: 32.ssp,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context).accentColor,
                                      ),
                                      isDense: true,
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context).accentColor,
                                        ),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context).accentColor,
                                        ),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 0,
                                        vertical: 0,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(bottom: 0.01.hp),
                                  child: Material(
                                    color: Color(0xFFFFAEEDE),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    elevation: 5,
                                    child: TextFormField(
                                      controller: _mealDescription,
                                      style: GoogleFonts.montserrat(
                                        fontSize:
                                            _mealDescription.value.text.length >
                                                    0
                                                ? 25.ssp
                                                : 32.ssp,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context).accentColor,
                                      ),
                                      maxLines: 5,
                                      minLines: 1,
                                      decoration: InputDecoration(
                                        hintText: 'Descrição',
                                        hintStyle: GoogleFonts.montserrat(
                                          color: Color(0xFFFC3C3C3),
                                        ),
                                        isDense: true,
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 15,
                                          vertical: 5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(bottom: 0.01.hp),
                                  child: Material(
                                    color: Color(0xFFFFAEEDE),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    elevation: 5,
                                    child: TextFormField(
                                      controller: _mealValue,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 32.ssp,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context).accentColor,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Valor',
                                        hintStyle: GoogleFonts.montserrat(
                                          color: Color(0xFFFC3C3C3),
                                        ),
                                        isDense: true,
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 15,
                                          vertical: 5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Material(
                                  color: Color(0xFFFFAEEDE),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  elevation: 5,
                                  child: TextFormField(
                                    controller: _mealQuantity,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 32.ssp,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).accentColor,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Quantidade',
                                      hintStyle: GoogleFonts.montserrat(
                                        color: Color(0xFFFC3C3C3),
                                      ),
                                      isDense: true,
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 15,
                                        vertical: 5,
                                      ),
                                    ),
                                  ),
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
            ),
            SizedBox(
              height: 0.01.hp,
            ),
            Center(
              child: RaisedButton(
                padding: EdgeInsets.symmetric(horizontal: 0.1.wp),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                onPressed: () => {},
                child: AutoSizeText(
                  "Confirmar",
                  style: GoogleFonts.montserrat(
                    fontSize: 32.ssp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
