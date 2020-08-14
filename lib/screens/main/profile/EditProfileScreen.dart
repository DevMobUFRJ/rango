import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rango/models/client.dart';
import 'package:rango/widgets/auth/CustomTextFormField.dart';
import 'package:rango/widgets/pickers/UserImagePicker.dart';

class EditProfileScreen extends StatefulWidget {
  final Client user;

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

  String _phone;
  String _password;
  String _userImage;
  String _confirmPassword;
  File _userImageFile;
  bool _loading = false;
  final _focusNodeConfirmPass = FocusNode();

  void _pickedImage(File image) => _userImageFile = image;

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
        Scaffold.of(context).showSnackBar(
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
        title: Text(
          'Editar Perfil',
          style: GoogleFonts.montserrat(
            color: Theme.of(context).accentColor,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (ctx, constraint) => SingleChildScrollView(
          child: Container(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Flexible(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {},
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
                    SizedBox(height: 10),
                    Flexible(
                      flex: 2,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: CustomTextFormField(
                                labelText: 'Telefone:',
                                key: ValueKey('phone'),
                                controller: _tel,
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
                                onFieldSubmitted: (_) =>
                                    FocusScope.of(context).nextFocus(),
                              ),
                            ),
                            Expanded(
                              child: CustomTextFormField(
                                labelText: 'Senha:',
                                controller: _pass,
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
                            Expanded(
                              child: CustomTextFormField(
                                labelText: 'Confimar Senha:',
                                focusNode: _focusNodeConfirmPass,
                                controller: _confirmPass,
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
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 60, vertical: 10),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: RaisedButton(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    disabledColor: Colors.grey,
                                    onPressed: _loading
                                        ? () => {
                                              Scaffold.of(context).showSnackBar(
                                                  SnackBar(
                                                      content: Text(
                                                          'Carregando, aguarde.')))
                                            }
                                        : () => _submit(ctx),
                                    child: _loading
                                        ? SizedBox(
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  new AlwaysStoppedAnimation<
                                                      Color>(Colors.white),
                                              strokeWidth: 3.0,
                                            ),
                                            height: 15,
                                            width: 15,
                                          )
                                        : Text(
                                            'Continuar',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20),
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
        ),
      ),
    );
  }
}
