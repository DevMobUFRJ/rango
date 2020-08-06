import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rango/widgets/pickers/UserImagePicker.dart';

class AuthForm extends StatefulWidget {
  final void Function({
    String email,
    String name,
    File image,
    String password,
    BuildContext ctx,
  }) submitForm;
  final bool _isLoading;
  final bool _isLogin;

  AuthForm(this.submitForm, this._isLoading, this._isLogin);

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();

  String _name = '';
  String _email = '';
  String _password = '';
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  File _userImageFile;

  void _pickedImage(File image) => _userImageFile = image;

  void _submit() {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();
    if (isValid) {
      _formKey.currentState.save();
      widget.submitForm(
        email: _email.trim(),
        name: _name.trim(),
        password: _password.trim(),
        ctx: context,
        image: _userImageFile,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraint) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraint.maxHeight),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    if (!widget._isLogin) UserImagePicker(_pickedImage),
                    if (!widget._isLogin) SizedBox(height: 30),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 10, bottom: 10),
                        child: Text(
                          'Email:',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.deepOrange[300],
                          ),
                        ),
                      ),
                    ),
                    Material(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 5,
                      child: TextFormField(
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).nextFocus(),
                        key: ValueKey('email'),
                        validator: (value) {
                          if (value.isEmpty || !value.contains('@')) {
                            return 'Coloque um email válido';
                          }
                          return null;
                        },
                        onSaved: (value) => _email = value,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(left: 15)),
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    if (!widget._isLogin) SizedBox(height: 30),
                    if (!widget._isLogin)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, bottom: 10),
                          child: Text(
                            'Nome:',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.deepOrange[300],
                            ),
                          ),
                        ),
                      ),
                    if (!widget._isLogin)
                      Material(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 5,
                        child: TextFormField(
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) =>
                              FocusScope.of(context).nextFocus(),
                          key: ValueKey('name'),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(left: 15),
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Digite seu nome";
                            }
                            return null;
                          },
                          onSaved: (value) => _name = value,
                        ),
                      ),
                    SizedBox(height: 30),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 10, bottom: 10),
                        child: Text(
                          'Senha:',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.deepOrange[300],
                          ),
                        ),
                      ),
                    ),
                    Material(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 5,
                      child: TextFormField(
                        textAlign: TextAlign.start,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).nextFocus(),
                        key: ValueKey('password'),
                        onSaved: (value) => _password = value,
                        onChanged: (value) => setState(() => _password = value),
                        validator: (value) {
                          if (value.isEmpty || value.length < 7) {
                            return 'Senha precisa ter 7 caracteres';
                          }
                          return null;
                        },
                        obscureText: !_showPassword,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(15),
                          suffixIcon: IconButton(
                            icon: Icon(!_showPassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () =>
                                setState(() => _showPassword = !_showPassword),
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    if (!widget._isLogin) SizedBox(height: 30),
                    if (!widget._isLogin)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, bottom: 10),
                          child: Text(
                            'Confirmar Senha:',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.deepOrange[300],
                            ),
                          ),
                        ),
                      ),
                    if (!widget._isLogin)
                      Material(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 5,
                        child: TextFormField(
                          textAlign: TextAlign.start,
                          key: ValueKey('confirmPassword'),
                          validator: (value) {
                            if (value.isEmpty ||
                                value.length < 7 ||
                                value != _password) {
                              return 'Senhas não conferem';
                            }
                            return null;
                          },
                          obscureText: !_showConfirmPassword,
                          decoration: InputDecoration(
                              suffixIcon: IconButton(
                                icon: Icon(!_showConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () => setState(() =>
                                    _showConfirmPassword =
                                        !_showConfirmPassword),
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(15)),
                        ),
                      ),
                    SizedBox(height: 50),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 60),
                      child: SizedBox(
                        width: double.infinity,
                        child: RaisedButton(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          onPressed: _submit,
                          child: widget._isLoading
                              ? SizedBox(
                                  child: CircularProgressIndicator(
                                    valueColor:
                                        new AlwaysStoppedAnimation<Color>(
                                            Colors.white),
                                    strokeWidth: 3.0,
                                  ),
                                  height: 15,
                                  width: 15,
                                )
                              : Text(
                                  'Continuar',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
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
      ),
    );
  }
}
