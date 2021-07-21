import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rango/models/client.dart';
import 'package:rango/utils/constants.dart';
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
  String _nameErrorMessage;
  String _emailErrorMessage;
  String _telefoneErrorMessage;
  String _passwordErrorMessage;
  String _actualPassErrorMessage;
  String _confirmPasswordErrorMessage;

  TextEditingController _name = TextEditingController();
  TextEditingController _actualPass = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _pass = TextEditingController();
  TextEditingController _confirmPass = TextEditingController();
  TextEditingController _phone = TextEditingController();

  File _userImageFile;
  bool _loading = false;
  User _user;

  final _focusNodeName = FocusNode();
  final _focusNodeEmail = FocusNode();
  final _focusNodeTel = FocusNode();
  final _focusNodePass = FocusNode();
  final _focusNodeConfirmPass = FocusNode();

  void _pickedImage(File image) => _userImageFile = image;

  @override
  void initState() {
    setState(() {
      if (widget.user.phone != null) {
        _phone.text = widget.user.phone;
      }
      if (widget.user.name != null) {
        _name.text = widget.user.name;
      }
      _email.text = FirebaseAuth.instance.currentUser.email;
      _user = FirebaseAuth.instance.currentUser;
    });
    super.initState();
  }

  void _submit(BuildContext context) async {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();
    if (isValid &&
        _telefoneErrorMessage == null &&
        _passwordErrorMessage == null &&
        _nameErrorMessage == null &&
        _confirmPasswordErrorMessage == null &&
        _emailErrorMessage == null) {
      bool changeHasMade = false;
      _formKey.currentState.save();
      setState(() => _loading = true);
      try {
        Map<String, dynamic> dataToUpdate = {};
        if (_phone != null && _phone.text != widget.user.phone) {
          dataToUpdate['phone'] = _phone.text;
        }
        if (_name != null && _name.text != widget.user.name) {
          dataToUpdate['name'] = _name.text;
        }
        if (_email != null && _email.text != _user.email) {
          dataToUpdate['email'] = _email.text;
          await _user.updateEmail(_email.text);
          changeHasMade = true;
        }
        if (_userImageFile != null) {
          final ref = FirebaseStorage.instance
              .ref()
              .child('user_image')
              .child(_user.uid + '.jpg');
          await ref.putFile(_userImageFile).whenComplete(() => null);
          final url = 'gs://rango-ufrj.appspot.com/${ref.fullPath}';
          dataToUpdate['picture'] = url;
        }
        final firebaseUser = FirebaseAuth.instance.currentUser;
        await firebaseUser.updateDisplayName(_name.text.trim());
        if (dataToUpdate.length > 0) {
          await FirebaseFirestore.instance
              .collection('clients')
              .doc(firebaseUser.uid)
              .update(dataToUpdate);
          changeHasMade = true;
        }
        if (_pass.text.length > 0) {
          await firebaseUser.updatePassword(_pass.text);
          changeHasMade = true;
        }
        if (changeHasMade) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: Duration(seconds: 2),
              backgroundColor: Theme.of(context).accentColor,
              content: Text(
                'Mudanças realizadas',
                textAlign: TextAlign.center,
              ),
            ),
          );
          setState(() {
            _loading = false;
          });
        }
      } on FirebaseAuthException catch (error) {
        setState(() => _loading = false);
        print(error);
        String errorText;
        switch (error.code) {
          case 'network-request-failed':
            errorText = networkErrorMessage;
            break;
          case 'invalid-email':
            errorText = invalidEmailErrorMessage;
            break;
          case 'email-already-in-use':
            errorText = emailAlreadyInUseErrorMessage;
            break;
          case 'requires-recent-login':
            errorText = requiresRecentLoginErrorMessage;
            _showReauthenticateDialog();
            break;
          default:
            errorText = defaultErrorMessage;
            break;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 2),
            backgroundColor: Theme.of(context).errorColor,
            content: Text(
              errorText,
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

  void _showReauthenticateDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        backgroundColor: Color(0xFFF9B152),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        insetPadding:
            EdgeInsets.symmetric(horizontal: 0.1.wp, vertical: 0.1.hp),
        title: Text(
          'Para trocar email ou senha, você precisa confirmar sua senha atual e tentar novamente',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 32.nsp,
          ),
        ),
        content: Column(
          children: [
            CustomTextFormField(
              labelText: '',
              key: ValueKey('actualPass'),
              controller: _actualPass,
              isPassword: true,
              validator: (String value) {
                if (value.trim() == '') {
                  setState(() =>
                      _actualPassErrorMessage = 'Senha não pode ser vazia');
                } else {
                  setState(() => _actualPassErrorMessage = null);
                }
                return null;
              },
              errorText: _actualPassErrorMessage,
              onSaved: (value) => _actualPass.text = value,
            ),
            Container(
              margin: EdgeInsets.only(top: 8),
              child: ElevatedButton(
                onPressed: () async {
                  setState(() => _loading = true);
                  try {
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: _user.email,
                      password: _actualPass.text,
                    );
                    setState(() => _loading = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: Duration(seconds: 2),
                        content: Text(
                          'Senha confirmada, agora você já pode trocar seu email ou senha',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                    Navigator.of(context).pop();
                  } catch (error) {
                    setState(() => _loading = true);
                    print(error);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: Duration(seconds: 2),
                        backgroundColor: Theme.of(context).errorColor,
                        content: Text(
                          'Ocorreu um erro',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    'Confirmar',
                    style: GoogleFonts.montserrat(
                      fontSize: 32.nsp,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
          physics: ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 0.9.hp),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Flexible(
                    flex: 1,
                    child: UserImagePicker(
                      _pickedImage,
                      image: widget.user.picture,
                      editText: 'Editar',
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
                              labelText: 'Nome',
                              focusNode: _focusNodeName,
                              key: ValueKey('name'),
                              controller: _name,
                              textCapitalization: TextCapitalization.sentences,
                              validator: (String value) {
                                if (value.trim() == '') {
                                  setState(() => _nameErrorMessage =
                                      'Nome não pode ser vaizo');
                                } else {
                                  setState(() => _nameErrorMessage = null);
                                }
                                return null;
                              },
                              errorText: _nameErrorMessage,
                              textInputAction: TextInputAction.next,
                              onSaved: (value) => _name.text = value,
                              onFieldSubmitted: (_) => FocusScope.of(context)
                                  .requestFocus(_focusNodeTel),
                            ),
                          ),
                          Flexible(
                            flex: 2,
                            child: CustomTextFormField(
                              labelText: 'Email',
                              focusNode: _focusNodeEmail,
                              key: ValueKey('email'),
                              controller: _email,
                              validator: (String value) {
                                if (value.trim() == '') {
                                  setState(() => _emailErrorMessage =
                                      'Email não pode ser vaizo');
                                } else {
                                  setState(() => _nameErrorMessage = null);
                                }
                                return null;
                              },
                              errorText: _emailErrorMessage,
                              textInputAction: TextInputAction.next,
                              onSaved: (value) => _email.text = value,
                              onFieldSubmitted: (_) => FocusScope.of(context)
                                  .requestFocus(_focusNodeTel),
                            ),
                          ),
                          Flexible(
                            flex: 2,
                            child: CustomTextFormField(
                              labelText: 'Telefone',
                              focusNode: _focusNodeTel,
                              key: ValueKey('phone'),
                              controller: _phone,
                              validator: (String value) {
                                if (value.trim() != '' &&
                                    value.trim().length != 11) {
                                  setState(() => _telefoneErrorMessage =
                                      'Telefone precisa ter 11 números');
                                } else {
                                  setState(() => _telefoneErrorMessage = null);
                                }
                                return null;
                              },
                              errorText: _telefoneErrorMessage,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              onSaved: (value) => _phone.text = value,
                              onFieldSubmitted: (_) => FocusScope.of(context)
                                  .requestFocus(_focusNodePass),
                            ),
                          ),
                          Flexible(
                            flex: 2,
                            child: Container(
                              child: CustomTextFormField(
                                focusNode: _focusNodePass,
                                labelText: 'Nova senha',
                                controller: _pass,
                                isPassword: true,
                                onFieldSubmitted: (_) => FocusScope.of(context)
                                    .requestFocus(_focusNodeConfirmPass),
                                onSaved: (value) => _pass.text = value,
                                textInputAction: TextInputAction.next,
                                key: ValueKey('password'),
                                validator: (String value) {
                                  if (value != '' && value.length < 7) {
                                    setState(() => _passwordErrorMessage =
                                        'Senha precisa ter pelo menos 7 caracteres');
                                  } else {
                                    setState(
                                        () => _passwordErrorMessage = null);
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
                              labelText: 'Confimar nova senha',
                              focusNode: _focusNodeConfirmPass,
                              controller: _confirmPass,
                              isPassword: true,
                              onSaved: (value) => _confirmPass.text = value,
                              key: ValueKey('confirmPassword'),
                              validator: (String value) {
                                if (value != '' && value.length < 7) {
                                  setState(() => _confirmPasswordErrorMessage =
                                      'Senha precisa ter pelo menos 7 caracteres');
                                } else if (value != '' && value != _pass.text) {
                                  setState(() => _confirmPasswordErrorMessage =
                                      'Senhas estão diferentes');
                                } else {
                                  setState(() =>
                                      _confirmPasswordErrorMessage = null);
                                }
                                return null;
                              },
                              errorText: _confirmPasswordErrorMessage,
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Container(
                              width: 0.4.wp,
                              margin: EdgeInsets.only(top: 10),
                              child: ElevatedButton(
                                onPressed: _loading ? null : () => _submit(ctx),
                                child: _loading
                                    ? SizedBox(
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              new AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                          strokeWidth: 3.0,
                                        ),
                                        height: 30.w,
                                        width: 30.w,
                                      )
                                    : AutoSizeText(
                                        'Continuar',
                                        style: GoogleFonts.montserrat(
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
