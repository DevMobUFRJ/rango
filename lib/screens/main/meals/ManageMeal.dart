import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rango/models/meals.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rango/models/seller.dart';
import 'package:rango/resources/repository.dart';
import 'package:rango/widgets/pickers/MealImagePicker.dart';
import 'package:rango/utils/showSnackbar.dart';

class ManageMeal extends StatefulWidget {
  final Meal meal;
  @required
  final Seller seller;

  ManageMeal(this.seller, {this.meal});

  @override
  _ManageMealState createState() => _ManageMealState();
}

class _ManageMealState extends State<ManageMeal> {
  File _mealImageFile;
  void _pickedImage(File image) => setState(() => _mealImageFile = image);

  bool _loading = false;
  bool _loadingDelete = false;

  FocusNode _nameFocusNode = FocusNode();
  FocusNode _descriptionFocusNode = FocusNode();
  FocusNode _valueFocusNode = FocusNode();
  FocusNode _quantityFocusNode = FocusNode();

  TextEditingController _mealName = TextEditingController();
  MoneyMaskedTextController _mealValue =
      MoneyMaskedTextController(leftSymbol: 'R\$ ');
  TextEditingController _mealDescription = TextEditingController();
  TextEditingController _mealQuantity = TextEditingController();

  @override
  initState() {
    super.initState();
    if (widget.meal != null) {
      _mealName = TextEditingController(text: widget.meal.name);
      _mealValue = MoneyMaskedTextController(
        initialValue: widget.meal.price.toDouble() / 100,
        leftSymbol: 'R\$ ',
      );
      _mealDescription = TextEditingController(text: widget.meal.description);
      _mealQuantity =
          TextEditingController(text: widget.meal.quantity.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: Scrollbar(
        isAlwaysShown: true,
        child: LayoutBuilder(
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
                      focusNode: _nameFocusNode,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 5,
                      minLines: 1,
                      controller: _mealName,
                      maxLength: 50,
                      style: GoogleFonts.montserrat(
                        fontSize: 38.nsp,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).accentColor,
                      ),
                      cursorColor: Theme.of(context).accentColor,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        counterText: "",
                        hintText: 'Nome do prato',
                        hintStyle: GoogleFonts.montserrat(
                          fontSize: 38.nsp,
                          fontWeight: FontWeight.w500,
                          color: Color.fromRGBO(255, 175, 153, 1),
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
                      onFieldSubmitted: (_) => FocusScope.of(context)
                          .requestFocus(_descriptionFocusNode),
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
                        focusNode: _descriptionFocusNode,
                        controller: _mealDescription,
                        style: GoogleFonts.montserrat(
                          fontSize: 35.nsp,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).accentColor,
                        ),
                        keyboardType: TextInputType.text,
                        maxLines: 5,
                        minLines: 1,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          hintText: 'Descrição',
                          counterText: "",
                          hintStyle: GoogleFonts.montserrat(
                            fontSize: 38.nsp,
                            color: Color(0xFFFC3C3C3),
                          ),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 5,
                          ),
                        ),
                        onFieldSubmitted: (_) => FocusScope.of(context)
                            .requestFocus(_valueFocusNode),
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
                                focusNode: _valueFocusNode,
                                textAlign: TextAlign.center,
                                controller: _mealValue,
                                style: GoogleFonts.montserrat(
                                  fontSize: 38.nsp,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).accentColor,
                                ),
                                textInputAction: TextInputAction.next,
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
                                onFieldSubmitted: (_) => FocusScope.of(context)
                                    .requestFocus(_quantityFocusNode),
                              ),
                            ),
                          ),
                        ),
                        if (widget.seller.canReservate) ...{
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
                                  focusNode: _quantityFocusNode,
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
                                  onFieldSubmitted: (_) => _upsertMeal(context),
                                ),
                              ),
                            ),
                          )
                        }
                      ],
                    ),
                  ),
                  SizedBox(height: 0.02.hp),
                  Container(
                    width: 0.5.wp,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green[400],
                        padding: EdgeInsets.symmetric(vertical: 5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _loading || _loadingDelete
                          ? null
                          : () => _upsertMeal(context),
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
                                color: Colors.white,
                                fontSize: 34.nsp,
                              ),
                            ),
                    ),
                  ),
                  if (widget.meal != null)
                    Container(
                      width: 0.5.wp,
                      margin: EdgeInsets.only(bottom: 10),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red[500],
                          padding: EdgeInsets.symmetric(vertical: 5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _loading || _loadingDelete
                            ? null
                            : () => _showDeleteDialog(
                                  context,
                                  widget.seller.id,
                                  widget.meal.id,
                                ),
                        child: _loadingDelete
                            ? SizedBox(
                                width: 15,
                                height: 15,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : AutoSizeText(
                                "Excluir",
                                style: GoogleFonts.montserrat(
                                  fontSize: 34.nsp,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                ],
              ),
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

      if (_mealName.text != '') {
        dataToUpdate['name'] = _mealName.text;
      } else {
        showSnackbar(context, true, 'Você deve inserir o nome do prato');
        setState(() => _loading = false);
        return;
      }

      if (_mealDescription.text != '') {
        dataToUpdate['description'] = _mealDescription.text;
      } else {
        showSnackbar(context, true, 'Você deve inserir a descrição do prato');
        setState(() => _loading = false);
        return;
      }

      if (_mealValue != null && _mealValue.numberValue != 0) {
        dataToUpdate['price'] = (_mealValue.numberValue * 100).round();
      } else {
        showSnackbar(context, true, 'Você deve inserir o preço do prato');
        setState(() => _loading = false);
        return;
      }

      dataToUpdate['quantity'] = 1;
      if (_mealQuantity != null && _mealQuantity.text != '') {
        dataToUpdate['quantity'] = int.parse(_mealQuantity.text);
      } else if (widget.seller.canReservate) {
        showSnackbar(context, true, 'Você deve inserir a quantidade');
        setState(() => _loading = false);
        return;
      }

      if (widget.meal == null) {
        dataToUpdate['createdAt'] = DateTime.now();
      }
      dataToUpdate['updatedAt'] = DateTime.now();

      if (widget.meal != null) {
        if (_mealImageFile != null) {
          final ref = FirebaseStorage.instance
              .ref()
              .child('users/${widget.seller.id}/meals/${widget.meal.id}.png');
          await ref.putFile(_mealImageFile).whenComplete(() => null);
          final url = await ref.getDownloadURL();
          dataToUpdate['picture'] = url;
        }

        await Repository.instance
            .updateMeal(widget.seller.id, widget.meal.id, dataToUpdate);
      } else {
        String createdMealId = await Repository.instance
            .createMeal(widget.seller.id, dataToUpdate);

        if (_mealImageFile != null) {
          final ref = FirebaseStorage.instance
              .ref()
              .child('users/${widget.seller.id}/meals/$createdMealId.png');
          await ref.putFile(_mealImageFile).whenComplete(() => null);
          final url = await ref.getDownloadURL();
          Map<String, dynamic> pictureUpdate = {'picture': url};

          await Repository.instance
              .updateMeal(widget.seller.id, createdMealId, pictureUpdate);
        }
      }

      FocusScope.of(context).unfocus();
      showSnackbar(context, false, 'Quentinha salva com sucesso');
      setState(() => _loading = false);
      Navigator.of(context).pop();
    } catch (e) {
      setState(() => _loading = false);
      showSnackbar(context, true, 'Erro ao adicionar quentinha');
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
            top: 12,
            left: 24,
            right: 24,
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
          content: _loadingDelete
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                )
              : Text(
                  'Deseja realmente excluir essa quentinha? Ela será excluída para sempre.',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 32.nsp,
                  ),
                ),
          actions: _loadingDelete
              ? null
              : [
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
                      setState(() => _loadingDelete = true);
                      try {
                        await Repository.instance.deleteMeal(sellerId, mealId);
                        FocusScope.of(ctx).unfocus();
                        setState(() => _loadingDelete = false);
                        showSnackbar(
                            ctx, false, 'Quentinha excluída com sucesso');
                        Navigator.of(ctx).pop();
                      } catch (e) {
                        setState(() => _loadingDelete = false);
                        showSnackbar(ctx, true, e.toString());
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
                  )
                ],
        );
      },
    );
  }
}
