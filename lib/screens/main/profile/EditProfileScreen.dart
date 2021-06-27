import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rango/models/contact.dart';
import 'package:rango/models/seller.dart';
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
  String _passwordErrorMessage;
  String _nameErrorMessage;
  String _confirmPasswordErrorMessage;
  TextEditingController _pass = TextEditingController();
  TextEditingController _confirmPass = TextEditingController();
  TextEditingController _tel = TextEditingController();
  TextEditingController _name = TextEditingController();
  TextEditingController _description = TextEditingController();
  TextEditingController _payments = TextEditingController();

  final _passFocusNode = FocusNode();
  final _focusNodeConfirmPass = FocusNode();
  final _telFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _paymentsFocusNode = FocusNode();

  File _userImageFile;
  bool _loading = false;

  void _pickedImage(File image) => setState(() => _userImageFile = image);

  @override
  void initState() {
    setState(() {
      _name = new TextEditingController(text: widget.user.name);
      _description = new TextEditingController(text: widget.user.description);
      _tel = new TextEditingController(text: widget.user.contact.phone);
      _payments = new TextEditingController(text: widget.user.payments);
    });
    super.initState();
  }

  void _submit(BuildContext context) async {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();
    if (isValid &&
        _telefoneErrorMessage == null &&
        _passwordErrorMessage == null &&
        _confirmPasswordErrorMessage == null) {
      _formKey.currentState.save();
      setState(() => _loading = true);
      try {
        Map<String, dynamic> dataToUpdate = {};
        if (_tel.text != null && _tel.text != widget.user.contact.phone) {
          Map<String, dynamic> contato = {};
          contato['phone'] = _tel.text;
          contato['name'] = widget.user.contact.name;
          dataToUpdate['contact'] = contato;
        }
        if (_name.text != widget.user.name) {
          dataToUpdate['name'] = _name.text;
        }
        if (_description.text != null &&
            _description.text != widget.user.description) {
          dataToUpdate['description'] = _description.text;
        }
        if (_payments.text != null && _payments.text != widget.user.payments) {
          dataToUpdate['paymentMethods'] = _payments.text;
        }
        if (_userImageFile != null) {
          final user = await FirebaseAuth.instance.currentUser();
          final ref = FirebaseStorage.instance
              .ref()
              .child('user_image')
              .child(user.uid + '.jpg');
          await ref.putFile(_userImageFile).onComplete;
          final url = await ref.getDownloadURL();
          dataToUpdate['picture'] = url;
        }
        if (dataToUpdate.length > 0) {
          final firebaseUser = await FirebaseAuth.instance.currentUser();
          await Firestore.instance
              .collection('sellers')
              .document(firebaseUser.uid)
              .updateData(dataToUpdate);
        }
        setState(() => _loading = false);
        Navigator.of(context).pop();
        //TODO: trocar senha e tratar erros
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
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
        builder: (ctx, constraint) => SingleChildScrollView(
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
                          image: widget.user.picture,
                          editText: 'Editar',
                        ),
                      ],
                    ),
                  ),
                  CustomTextFormField(
                    labelText: 'Nome:',
                    key: ValueKey('name'),
                    controller: _name,
                    validator: (String value) {
                      if (value.trim() == '') {
                        setState(() =>
                            _nameErrorMessage = 'Nome não pode ser vazio!');
                      }
                      return null;
                    },
                    errorText: _nameErrorMessage,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context)
                        .requestFocus(_descriptionFocusNode),
                  ),
                  CustomTextFormField(
                    labelText: 'Descrição:',
                    key: ValueKey('description'),
                    controller: _description,
                    numberOfLines: 3,
                    focusNode: _descriptionFocusNode,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_telFocusNode),
                  ),
                  CustomTextFormField(
                    labelText: 'Telefone com DDD:',
                    key: ValueKey('phone'),
                    controller: _tel,
                    validator: (String value) {
                      if (value.trim() != '' && value.trim().length != 11) {
                        setState(() => _telefoneErrorMessage =
                            'Telefone precisa ter 11 números');
                      }
                      return null;
                    },
                    errorText: _telefoneErrorMessage,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_passFocusNode),
                  ),
                  CustomTextFormField(
                    labelText: 'Pagamentos aceitos:',
                    key: ValueKey('payments'),
                    focusNode: _paymentsFocusNode,
                    controller: _payments,
                    numberOfLines: 3,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_passFocusNode),
                  ),
                  CustomTextFormField(
                    labelText: 'Senha:',
                    controller: _pass,
                    focusNode: _passFocusNode,
                    isPassword: true,
                    onFieldSubmitted: (_) => FocusScope.of(context)
                        .requestFocus(_focusNodeConfirmPass),
                    textInputAction: TextInputAction.next,
                    key: ValueKey('password'),
                    validator: (String value) {
                      if (value != '' && value.length < 7) {
                        setState(() => _passwordErrorMessage =
                            'Senha precisa ter pelo menos 7 caracteres');
                      }
                      return null;
                    },
                    errorText: _passwordErrorMessage,
                  ),
                  CustomTextFormField(
                    labelText: 'Confimar Senha:',
                    focusNode: _focusNodeConfirmPass,
                    controller: _confirmPass,
                    isPassword: true,
                    key: ValueKey('confirmPassword'),
                    validator: (String value) {
                      if (value != '' && value.length < 7) {
                        setState(() => _passwordErrorMessage =
                            'Senha precisa ter pelo menos 7 caracteres');
                      }
                      return null;
                    },
                    errorText: _passwordErrorMessage,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 0.05.wp, vertical: 0.01.hp),
                    child: SizedBox(
                      width: 0.7.wp,
                      child: ElevatedButton(
                        onPressed: _loading
                            ? () => {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Carregando, aguarde.'),
                                    ),
                                  ),
                                }
                            : (_userImageFile != null ||
                                    (_pass.text != null &&
                                        _confirmPass.text != null) ||
                                    _tel.text != null)
                                ? () => _submit(ctx)
                                : null,
                        child: _loading
                            ? Padding(
                                padding:
                                    EdgeInsets.symmetric(vertical: 0.01.hp),
                                child: SizedBox(
                                  child: CircularProgressIndicator(
                                    valueColor:
                                        new AlwaysStoppedAnimation<Color>(
                                            Colors.white),
                                    strokeWidth: 3.0,
                                  ),
                                  height: 30.w,
                                  width: 30.w,
                                ),
                              )
                            : Padding(
                                padding:
                                    EdgeInsets.symmetric(vertical: 0.01.hp),
                                child: AutoSizeText(
                                  'Continuar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 38.nsp,
                                  ),
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
      ),
    );
  }
}
