import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  String _telefoneErrorMessage;

  TextEditingController _name = TextEditingController();
  TextEditingController _phone = TextEditingController();

  File _userImageFile;
  bool _loading = false;
  User _user;

  final _focusNodeName = FocusNode();
  final _focusNodeTel = FocusNode();

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
      _user = FirebaseAuth.instance.currentUser;
    });
    super.initState();
  }

  void _submit(BuildContext context) async {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();
    if (isValid &&
        _telefoneErrorMessage == null &&
        _nameErrorMessage == null) {
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
          await FirebaseAuth.instance.currentUser.updateDisplayName(_name.text);
        }
        if (_userImageFile != null) {
          final ref = FirebaseStorage.instance
              .ref()
              .child('users/${_user.uid}/picture.png');
          await ref.putFile(_userImageFile).whenComplete(() => null);
          final url = await ref.getDownloadURL();
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
        }
        setState(() {
          _loading = false;
        });
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
          physics: NeverScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 0.9.hp),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    UserImagePicker(
                      _pickedImage,
                      image: widget.user.picture,
                      editText: 'Editar',
                    ),
                    SizedBox(height: 20),
                    CustomTextFormField(
                      labelText: 'Nome',
                      focusNode: _focusNodeName,
                      key: ValueKey('name'),
                      controller: _name,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.words,
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
                    SizedBox(height: 20),
                    CustomTextFormField(
                      labelText: 'Celular com DDD',
                      focusNode: _focusNodeTel,
                      key: ValueKey('phone'),
                      controller: _phone,
                      validator: (String value) {
                        if (value.trim() != '' &&
                            value.trim().length != 11) {
                          setState(() => _telefoneErrorMessage =
                          'Celular precisa ter 11 números');
                        } else {
                          setState(() => _telefoneErrorMessage = null);
                        }
                        return null;
                      },
                      errorText: _telefoneErrorMessage,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      onSaved: (value) => _phone.text = value,
                      onFieldSubmitted: (_) => _submit(ctx),
                    ),
                    SizedBox(height: 10),
                    Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 0.05.wp, vertical: 0.01.hp),
                        child: SizedBox(
                          width: 0.5.wp,
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
                              'Salvar',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 38.nsp,
                              ),
                            ),
                          ),
                        )
                    )
                  ],
                ),
              )
            ),
          ),
        ),
      ),
    );
  }
}
