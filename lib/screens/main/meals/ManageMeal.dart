import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rango/models/meals.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rango/resources/repository.dart';
import 'package:rango/widgets/pickers/MealImagePicker.dart';

class ManageMeal extends StatefulWidget {
  final Meal meal;
  @required final String sellerId;

  ManageMeal(this.sellerId, {
      this.meal
    }
  );

  @override
  _ManageMealState createState() => _ManageMealState();
}

class _ManageMealState extends State<ManageMeal> {
  File _mealImageFile;
  void _pickedImage(File image) => setState(() => _mealImageFile = image);

  TextEditingController _mealName;
  MoneyMaskedTextController _mealValue;
  TextEditingController _mealDescription;
  TextEditingController _mealQuantity;

  @override
  Widget build(BuildContext context) {
    if (widget.meal != null) {
      _mealName = TextEditingController(
          text: widget.meal.name);
      _mealValue = MoneyMaskedTextController(
          initialValue: widget.meal.price.toDouble()/100,
          leftSymbol: 'R\$ ',
      );
      _mealDescription = TextEditingController(
          text: widget.meal.description);
      _mealQuantity = TextEditingController(
          text: widget.meal.quantity.toString());
    } else {
      _mealName = TextEditingController();
      _mealValue = MoneyMaskedTextController(leftSymbol: 'R\$ ');
      _mealDescription = TextEditingController();
      _mealQuantity = TextEditingController();
    }
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          widget.meal != null ? "Edite a quentinha" : "E aí, o que tem hoje?",
          maxLines: 1,
          style: GoogleFonts.montserrat(
            color: Theme.of(context).accentColor,
            fontSize: 35.nsp,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(top: 15),
            child: Column(
              children: [
                MealImagePicker(
                  _pickedImage,
                  image: widget.meal != null &&
                          widget.meal.picture != null
                      ? widget.meal.picture
                      : null,
                  editText: "Editar imagem",
                ),
                Container(
                  margin: EdgeInsets.only(
                    bottom: 10,
                  ),
                  constraints: BoxConstraints(maxWidth: 0.8.wp),
                  child: TextFormField(
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 5,
                    minLines: 1,
                    controller: _mealName,
                    style: GoogleFonts.montserrat(
                      fontSize: 38.nsp,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).accentColor,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Nome do prato',
                      hintStyle: GoogleFonts.montserrat(
                        fontSize: 38.nsp,
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
                SizedBox(
                  height: 0.01.hp,
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 0.01.hp),
                  constraints: BoxConstraints(maxWidth: 0.8.wp),
                  child: Material(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 5,
                    child: TextFormField(
                      textCapitalization: TextCapitalization.sentences,
                      controller: _mealDescription,
                      style: GoogleFonts.montserrat(
                        fontSize: 35.nsp,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).accentColor,
                      ),
                      maxLines: 5,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: 'Descrição',
                        hintStyle: GoogleFonts.montserrat(
                          fontSize: 38.nsp,
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
                Container(
                  constraints: BoxConstraints(maxWidth: 0.8.wp),
                  child: Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: Container(
                          margin: EdgeInsets.only(right: 10),
                          child: Material(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 5,
                            child: TextFormField(
                              textAlign: TextAlign.center,
                              controller: _mealValue,
                              style: GoogleFonts.montserrat(
                                fontSize: 38.nsp,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).accentColor,
                              ),
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'Valor',
                                alignLabelWithHint: true,
                                hintStyle: GoogleFonts.montserrat(
                                  color: Color(0xFFFC3C3C3),
                                  fontSize: 38.nsp,
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
                      ),
                      Flexible(
                        flex: 1,
                        child: Container(
                          margin: EdgeInsets.only(left: 10),
                          child: Material(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 5,
                            child: TextFormField(
                              controller: _mealQuantity,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.montserrat(
                                fontSize: 38.nsp,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).accentColor,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Quantidade',
                                hintStyle: GoogleFonts.montserrat(
                                  color: Color(0xFFFC3C3C3),
                                  fontSize: 32.nsp,
                                ),
                                alignLabelWithHint: true,
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
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 0.01.hp,
                ),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => _upsertMeal(context),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 42),
                      child: AutoSizeText(
                        "Confirmar",
                        style: GoogleFonts.montserrat(
                          fontSize: 38.nsp,
                        ),
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

  void _upsertMeal(BuildContext context) async {
    try {
      Map<String, dynamic> dataToUpdate = {};

      if (_mealName.toString() != null) {
        dataToUpdate['name'] = _mealName.text;
      }
      if (_mealDescription.toString() != null) {
        dataToUpdate['description'] = _mealDescription.text;
      }
      if (_mealValue != null && _mealValue.numberValue != 0) {
        dataToUpdate['price'] = (_mealValue.numberValue*100).round();
      }
      if (_mealQuantity != null && _mealQuantity.text != '') {
        dataToUpdate['quantity'] = int.parse(_mealQuantity.text);
      }
      if (widget.meal == null) {
        dataToUpdate['createdAt'] = DateTime.now();
      }
      dataToUpdate['updatedAt'] = DateTime.now();

      if (widget.meal != null) {
        if (_mealImageFile != null) {
          final ref = FirebaseStorage.instance
              .ref()
              .child('users/${widget.sellerId}/meals/${widget.meal.id}.png');
          await ref.putFile(_mealImageFile).whenComplete(() => null);
          final metadata = await ref.getMetadata();
          dataToUpdate['picture'] = 'gs://${metadata.bucket}/${metadata.fullPath}';
        }

        await Repository.instance.updateMeal(widget.sellerId, widget.meal.id, dataToUpdate);
      } else {
        String createdMealId = await Repository.instance.createMeal(widget.sellerId, dataToUpdate);

        if (_mealImageFile != null) {
          final ref = FirebaseStorage.instance
              .ref()
              .child('users/${widget.sellerId}/meals/$createdMealId.png');
          await ref.putFile(_mealImageFile).whenComplete(() => null);
          final metadata = await ref.getMetadata();
          Map<String, dynamic> pictureUpdate = {
            'picture': 'gs://${metadata.bucket}/${metadata.fullPath}'
          };

          await Repository.instance.updateMeal(widget.sellerId, createdMealId, pictureUpdate);
        }
      }

      Navigator.of(context).pop();
    } catch (e) {
      print(e);
    }
  }
}
