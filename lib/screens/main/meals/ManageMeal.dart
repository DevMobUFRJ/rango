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
  @required
  final String sellerId;

  ManageMeal(this.sellerId, {this.meal});

  @override
  _ManageMealState createState() => _ManageMealState();
}

class _ManageMealState extends State<ManageMeal> {
  File _mealImageFile;
  void _pickedImage(File image) => setState(() => _mealImageFile = image);

  bool _loading = false;
  TextEditingController _mealName;
  MoneyMaskedTextController _mealValue;
  TextEditingController _mealDescription;
  TextEditingController _mealQuantity;

  @override
  Widget build(BuildContext context) {
    if (widget.meal != null) {
      _mealName = TextEditingController(text: widget.meal.name);
      _mealValue = MoneyMaskedTextController(
        initialValue: widget.meal.price.toDouble() / 100,
        leftSymbol: 'R\$ ',
      );
      _mealDescription = TextEditingController(text: widget.meal.description);
      _mealQuantity =
          TextEditingController(text: widget.meal.quantity.toString());
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
        builder: (builderContext, constraints) => SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(top: 15),
            child: Column(
              children: [
                MealImagePicker(
                  _pickedImage,
                  image: widget.meal != null && widget.meal.picture != null
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
                SizedBox(height: 0.02.hp),
                Container(
                  width: 0.6.wp,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _loading ? null : () => _upsertMeal(context),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 42),
                      child: _loading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.white,
                              ),
                            )
                          : AutoSizeText(
                              "Confirmar",
                              style: GoogleFonts.montserrat(
                                fontSize: 38.nsp,
                              ),
                            ),
                    ),
                  ),
                ),
                if (widget.meal != null)
                  Container(
                    width: 0.6.wp,
                    margin: EdgeInsets.only(bottom: 10),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red[500],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _loading
                          ? null
                          : () => _showDeleteDialog(
                              context, widget.sellerId, widget.meal.id),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 42),
                        child: AutoSizeText(
                          "Excluir",
                          style: GoogleFonts.montserrat(
                            fontSize: 38.nsp,
                            color: _loading ? Colors.white : null,
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
    setState(() => _loading = true);
    try {
      Map<String, dynamic> dataToUpdate = {};

      if (_mealName.toString() != null) {
        dataToUpdate['name'] = _mealName.text;
      }
      if (_mealDescription.toString() != null) {
        dataToUpdate['description'] = _mealDescription.text;
      }
      if (_mealValue != null && _mealValue.numberValue != 0) {
        dataToUpdate['price'] = (_mealValue.numberValue * 100).round();
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
          final url = await ref.getDownloadURL();
          dataToUpdate['picture'] = url;
        }

        await Repository.instance
            .updateMeal(widget.sellerId, widget.meal.id, dataToUpdate);
      } else {
        String createdMealId =
            await Repository.instance.createMeal(widget.sellerId, dataToUpdate);

        if (_mealImageFile != null) {
          final ref = FirebaseStorage.instance
              .ref()
              .child('users/${widget.sellerId}/meals/$createdMealId.png');
          await ref.putFile(_mealImageFile).whenComplete(() => null);
          final url = await ref.getDownloadURL();
          Map<String, dynamic> pictureUpdate = {'picture': url};

          await Repository.instance
              .updateMeal(widget.sellerId, createdMealId, pictureUpdate);
        }
      }

      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 2),
          backgroundColor: Theme.of(context).accentColor,
          content: Text(
            'Quentinha salva com sucesso',
            textAlign: TextAlign.center,
          ),
        ),
      );
      setState(() => _loading = false);
      Navigator.of(context).pop();
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).errorColor,
          content: Text(
            'Erro ao adicionar quentinha.',
            textAlign: TextAlign.center,
          ),
        ),
      );
      print(e);
    }
  }

  void _showDeleteDialog(context, sellerId, mealId) async {
    await showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 0.1.wp),
          backgroundColor: Color(0xFFF9B152),
          actionsPadding: EdgeInsets.all(10),
          contentPadding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: 10,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Excluindo quentinha',
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 32.ssp,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Essa quentinha será excluída para sempre.',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 28.nsp,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: Text(
                      'Voltar',
                      style: GoogleFonts.montserrat(
                        decoration: TextDecoration.underline,
                        color: Colors.white,
                        fontSize: 34.nsp,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      try {
                        await Repository.instance.deleteMeal(sellerId, mealId);
                        FocusScope.of(context).unfocus();
                        Navigator.of(ctx).pop();
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            duration: Duration(seconds: 2),
                            backgroundColor: Theme.of(context).accentColor,
                            content: Text(
                              "Quentinha excluída com sucesso.",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      } catch (e) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            duration: Duration(seconds: 2),
                            padding: EdgeInsets.only(bottom: 60),
                            content: Text(
                              e.toString(),
                              textAlign: TextAlign.center,
                            ),
                            backgroundColor: Theme.of(context).errorColor,
                          ),
                        );
                      }
                    },
                    child: Text(
                      'Excluir',
                      style: GoogleFonts.montserrat(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 34.nsp,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
