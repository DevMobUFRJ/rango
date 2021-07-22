import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rango/models/contact.dart';
import 'package:rango/models/seller.dart';
import 'package:rango/resources/repository.dart';
import 'package:rango/widgets/auth/CustomTextFormField.dart';
import 'package:rango/widgets/pickers/UserImagePicker.dart';

class EditProfileScreen extends StatefulWidget {
  final Seller user;

  EditProfileScreen(this.user);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String _telefoneErrorMessage;
  String _nameErrorMessage;

  TextEditingController _tel = TextEditingController();
  TextEditingController _name = TextEditingController();
  TextEditingController _description = TextEditingController();
  TextEditingController _payments = TextEditingController();

  final _telFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _paymentsFocusNode = FocusNode();

  File _userImageFile;
  bool _loading = false;

  void _pickedImage(File image) => setState(() => _userImageFile = image);

  @override
  void initState() {
    setState(() {
      _name = TextEditingController(text: widget.user.name);
      _description = TextEditingController(text: widget.user.description);
      _tel = TextEditingController(text: widget.user.contact.phone);
      _payments = TextEditingController(text: widget.user.paymentMethods);
    });
    super.initState();
  }

  void _submit(BuildContext context) async {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();
    if (isValid && _telefoneErrorMessage == null && _nameErrorMessage == null) {
      _formKey.currentState.save();
      setState(() => _loading = true);
      try {
        Map<String, dynamic> dataToUpdate = {};
        if (_tel.text != '' && _tel.text != widget.user.contact.phone) {
          Contact contato = Contact(
              name: widget.user.contact.name, // TODO De onde pega?
              phone: _tel.text);
          dataToUpdate['contact'] = contato.toJson();
        }
        if (_name.text != '' && _name.text != widget.user.name) {
          dataToUpdate['name'] = _name.text;
          await FirebaseAuth.instance.currentUser.updateDisplayName(_name.text);
        }
        if (_description.text != '' &&
            _description.text != widget.user.description) {
          dataToUpdate['description'] = _description.text;
        }
        if (_payments.text != '' &&
            _payments.text != widget.user.paymentMethods) {
          dataToUpdate['paymentMethods'] = _payments.text;
        }
        if (_userImageFile != null) {
          final ref = FirebaseStorage.instance
              .ref()
              .child('users/${widget.user.id}/logo.png');
          await ref.putFile(_userImageFile).whenComplete(() => null);
          final url = await ref.getDownloadURL();
          dataToUpdate['logo'] = url;
        }
        if (dataToUpdate.length > 0) {
          await Repository.instance.updateSeller(widget.user.id, dataToUpdate);
        }
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 2),
            backgroundColor: Theme.of(context).accentColor,
            content: Text(
              'Perfil atualizado com sucesso',
              textAlign: TextAlign.center,
            ),
          ),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 2),
            backgroundColor: Theme.of(context).errorColor,
            content: Text(
              error.toString(),
              textAlign: TextAlign.center,
            ),
          ),
        );
        setState(() => _loading = false);
        print(error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          'Editar Perfil',
          maxLines: 1,
          style: GoogleFonts.montserrat(
            color: Theme.of(context).accentColor,
            fontSize: 35.nsp,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (ctx, constraint) => Scrollbar(
            isAlwaysShown: true,
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 22),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      GestureDetector(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            UserImagePicker(
                              _pickedImage,
                              image: widget.user.logo,
                              editText: 'Editar',
                            ),
                          ],
                        ),
                      ),
                      CustomTextFormField(
                        labelText: 'Nome',
                        textCapitalization: TextCapitalization.sentences,
                        key: ValueKey('name'),
                        controller: _name,
                        validator: (String value) {
                          _nameErrorMessage = null;
                          if (value.trim() == '') {
                            _nameErrorMessage = 'Nome não pode ser vazio!';
                          }
                          return null;
                        },
                        errorText: _nameErrorMessage,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode),
                      ),
                      CustomTextFormField(
                        labelText: 'Descrição',
                        textCapitalization: TextCapitalization.sentences,
                        hintText:
                            "Use para detalhar sua localização, biografia da empresa, o estilo da sua culinária ...",
                        key: ValueKey('description'),
                        controller: _description,
                        numberOfLines: 3,
                        focusNode: _descriptionFocusNode,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_telFocusNode),
                      ),
                      CustomTextFormField(
                        labelText: 'Celular com DDD',
                        focusNode: _telFocusNode,
                        key: ValueKey('phone'),
                        controller: _tel,
                        maxLength: 11,
                        validator: (String value) {
                          _telefoneErrorMessage = null;
                          if (value.trim() != '' && value.trim().length != 11) {
                            _telefoneErrorMessage =
                                'Celular precisa ter 11 números';
                          }
                          return null;
                        },
                        errorText: _telefoneErrorMessage,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => FocusScope.of(context)
                            .requestFocus(_paymentsFocusNode),
                      ),
                      CustomTextFormField(
                        labelText: 'Pagamentos aceitos',
                        hintText:
                            "Dinheiro, cartão de crédito, cartão de débito ...",
                        focusNode: _paymentsFocusNode,
                        controller: _payments,
                        textCapitalization: TextCapitalization.sentences,
                        key: ValueKey('payments'),
                        numberOfLines: 3,
                        onFieldSubmitted: (_) => _submit(ctx),
                      ),
                      Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: 0.85.wp,
                            child: AutoSizeText(
                              "*Dados visíveis para o cliente",
                              style: TextStyle(fontSize: 16.nsp),
                            ),
                          )),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 0.05.wp, vertical: 0.01.hp),
                        child: SizedBox(
                          width: 0.5.wp,
                          child: ElevatedButton(
                            onPressed: _loading
                                ? null
                                : (_userImageFile != null || _tel.text != null)
                                    ? () => _submit(ctx)
                                    : null,
                            child: _loading
                                ? SizedBox(
                                    child: CircularProgressIndicator(
                                      valueColor:
                                          new AlwaysStoppedAnimation<Color>(
                                              Colors.white),
                                      strokeWidth: 3.0,
                                    ),
                                    width: 20,
                                    height: 20,
                                  )
                                : AutoSizeText(
                                    'Salvar',
                                    style: TextStyle(
                                      color: Colors.white,
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
            )),
      ),
    );
  }
}
