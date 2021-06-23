import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
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
  String _confirmPasswordErrorMessage;
  TextEditingController _pass = TextEditingController();
  TextEditingController _confirmPass = TextEditingController();
  TextEditingController _tel;

  final _passFocusNode = FocusNode();
  final _focusNodeConfirmPass = FocusNode();

  String _phone;
  String _password;
  String _telefone;
  String _confirmPassword;
  File _userImageFile;
  bool _loading = false;

  void _pickedImage(File image) => setState(() => _userImageFile = image);

  @override
  void initState() {
    setState(() {
      widget.user.phone != null ? _phone = widget.user.phone : null;
      _tel = new TextEditingController(text: widget.user.phone);
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
        Map<String, String> dataToUpdate = {};
        if (_phone != null && _phone != widget.user.phone) {
          dataToUpdate['phone'] = _phone;
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
              .collection('clients')
              .document(firebaseUser.uid)
              .updateData({...dataToUpdate});
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
        builder: (ctx, constraint) => Container(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Flexible(
                  flex: 1,
                  child: GestureDetector(
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
                ),
                SizedBox(height: 0.02.hp),
                Expanded(
                  flex: 3,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          flex: 2,
                          child: CustomTextFormField(
                            labelText: 'Telefone com DDD:',
                            key: ValueKey('phone'),
                            controller: _tel,
                            onChanged: (value) =>
                                setState(() => _telefone = value),
                            validator: (String value) {
                              if (value.trim() != '' &&
                                  value.trim().length != 11) {
                                setState(() => _telefoneErrorMessage =
                                    'Telefone precisa ter 11 números');
                              }
                              return null;
                            },
                            errorText: _telefoneErrorMessage,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            onSaved: (value) => _phone = value,
                            onFieldSubmitted: (_) => FocusScope.of(context)
                                .requestFocus(_passFocusNode),
                          ),
                        ),
                        Flexible(
                          flex: 2,
                          child: Container(
                            child: CustomTextFormField(
                              labelText: 'Senha:',
                              controller: _pass,
                              focusNode: _passFocusNode,
                              onChanged: (value) =>
                                  setState(() => _password = value),
                              isPassword: true,
                              onFieldSubmitted: (_) => FocusScope.of(context)
                                  .requestFocus(_focusNodeConfirmPass),
                              onSaved: (value) => _password = value,
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
                          ),
                        ),
                        Flexible(
                          flex: 2,
                          child: CustomTextFormField(
                            labelText: 'Confimar Senha:',
                            focusNode: _focusNodeConfirmPass,
                            controller: _confirmPass,
                            onChanged: (value) =>
                                setState(() => _confirmPassword = value),
                            isPassword: true,
                            onSaved: (value) => _password = value,
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
                        ),
                        Flexible(
                          flex: 1,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 0.05.wp, vertical: 0.01.hp),
                            child: SizedBox(
                              width: 0.7.wp,
                              child: ElevatedButton(
                                onPressed: _loading
                                    ? () => {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content:
                                                  Text('Carregando, aguarde.'),
                                            ),
                                          ),
                                        }
                                    : (_userImageFile != null ||
                                            (_password != null &&
                                                _confirmPassword != null) ||
                                            _telefone != null)
                                        ? () => _submit(ctx)
                                        : null,
                                child: _loading
                                    ? Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 0.01.hp),
                                        child: SizedBox(
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                new AlwaysStoppedAnimation<
                                                    Color>(Colors.white),
                                            strokeWidth: 3.0,
                                          ),
                                          height: 30.w,
                                          width: 30.w,
                                        ),
                                      )
                                    : Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 0.01.hp),
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
    );
  }
}
