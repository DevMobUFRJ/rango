import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rango/models/order.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rango/widgets/pickers/MealImagePicker.dart';
import 'package:rango/widgets/pickers/UserImagePicker.dart';

class ManageOrder extends StatefulWidget {
  final Order order;
  final bool isEdit;

  ManageOrder({
    this.order,
    this.isEdit = false,
  });

  @override
  _ManageOrderState createState() => _ManageOrderState();
}

class _ManageOrderState extends State<ManageOrder> {
  File _userImageFile;

  void _pickedImage(File image) => _userImageFile = image;

  @override
  Widget build(BuildContext context) {
    TextEditingController _mealName;
    TextEditingController _mealValue;
    TextEditingController _mealDescription;
    TextEditingController _mealQuantity;
    if (widget.order != null) {
      _mealName = TextEditingController(text: widget.order.quentinha.name);
      _mealValue =
          TextEditingController(text: widget.order.quentinha.price.toString());
      _mealDescription =
          TextEditingController(text: widget.order.quentinha.description);
      _mealQuantity = TextEditingController();
    } else {
      _mealName = TextEditingController();
      _mealValue = TextEditingController();
      _mealDescription = TextEditingController();
      _mealQuantity = TextEditingController();
    }

    print(_userImageFile.toString());
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  padding: EdgeInsets.symmetric(
                      vertical: 0.06.hp, horizontal: 0.02.wp),
                  child: AutoSizeText(
                    widget.isEdit
                        ? "Edite a quentinha"
                        : "E aí, o que tem hoje?",
                    style: GoogleFonts.montserrat(
                        fontSize: 42.ssp,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).accentColor),
                  ),
                ),
              ),
              MealImagePicker(
                _pickedImage,
                image: widget.order != null &&
                        widget.order.quentinha.picture != null
                    ? widget.order.quentinha.picture
                    : null,
                editText: "Clique para editar",
              ),
              Container(
                margin: EdgeInsets.only(
                  bottom: 10,
                ),
                constraints: BoxConstraints(maxWidth: 0.6.wp),
                child: TextFormField(
                  maxLines: 5,
                  minLines: 1,
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
                constraints: BoxConstraints(maxWidth: 0.6.wp),
                child: Material(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 5,
                  child: TextFormField(
                    controller: _mealDescription,
                    style: GoogleFonts.montserrat(
                      fontSize: _mealDescription.value.text.length > 0
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
                constraints: BoxConstraints(maxWidth: 0.6.wp),
                child: Material(
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
                    keyboardType: TextInputType.number,
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
              Container(
                constraints: BoxConstraints(maxWidth: 0.6.wp),
                child: Material(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 5,
                  child: TextFormField(
                    controller: _mealQuantity,
                    keyboardType: TextInputType.number,
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
      ),
    );
  }
}
