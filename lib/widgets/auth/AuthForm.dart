import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rango/widgets/auth/CustomTextFormField.dart';
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
  final TextEditingController _pass = TextEditingController();
  final TextEditingController _confirmPass = TextEditingController();

  String _name = '';
  String _email = '';
  String _password = '';
  File _userImageFile;
  String _emailErrorMessage;
  String _nameErrorMessage;
  String _passwordErrorMessage;
  String _confirmPasswordErrorMessage;
  final _focusNodeConfirmPass = FocusNode();

  void _pickedImage(File image) => _userImageFile = image;

  void _submit() {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();
    if (isValid &&
        _emailErrorMessage == null &&
        _nameErrorMessage == null &&
        _passwordErrorMessage == null &&
        _confirmPasswordErrorMessage == null) {
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (widget._isLogin)
                  Text(
                    "RANGO",
                    style: GoogleFonts.montserrat(
                      fontSize: 50,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                Form(
                  key: _formKey,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        if (!widget._isLogin) UserImagePicker(_pickedImage),
                        if (!widget._isLogin) SizedBox(height: 30),
                        CustomTextFormField(
                          labelText: 'Email:',
                          key: ValueKey('email'),
                          validator: (value) {
                            if (value.isEmpty || !value.contains('@')) {
                              setState(() {
                                _emailErrorMessage = 'Coloque um email válido';
                              });
                            } else {
                              setState(() {
                                _emailErrorMessage = null;
                              });
                            }
                            return null;
                          },
                          onSaved: (value) => _email = value,
                          keyboardType: TextInputType.emailAddress,
                          onFieldSubmitted: (_) =>
                              FocusScope.of(context).nextFocus(),
                          textInputAction: TextInputAction.next,
                          errorText: _emailErrorMessage,
                        ),
                        SizedBox(height: 30),
                        if (!widget._isLogin)
                          CustomTextFormField(
                            labelText: 'Nome',
                            errorText: _nameErrorMessage,
                            key: ValueKey('name'),
                            onSaved: (value) => _name = value,
                            validator: (value) {
                              if (value.isEmpty) {
                                setState(() {
                                  _nameErrorMessage = 'Digite seu nome';
                                });
                              } else {
                                setState(() {
                                  _nameErrorMessage = null;
                                });
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) =>
                                FocusScope.of(context).nextFocus(),
                            textInputAction: TextInputAction.next,
                          ),
                        SizedBox(height: 30),
                        CustomTextFormField(
                          labelText: 'Senha:',
                          key: ValueKey('password'),
                          controller: _pass,
                          validator: (value) {
                            if (value.isEmpty || value.length < 7) {
                              setState(() => _passwordErrorMessage =
                                  'Senha precisa ter no mínimo 7 caracteres');
                            } else {
                              setState(() => _passwordErrorMessage = null);
                            }
                            return null;
                          },
                          onSaved: (value) =>
                              {setState(() => _password = value)},
                          errorText: _passwordErrorMessage,
                          isPassword: true,
                          textInputAction: !widget._isLogin
                              ? TextInputAction.next
                              : TextInputAction.done,
                          onFieldSubmitted: !widget._isLogin
                              ? (_) => FocusScope.of(context)
                                  .requestFocus(_focusNodeConfirmPass)
                              : null,
                        ),
                        if (!widget._isLogin) SizedBox(height: 30),
                        if (!widget._isLogin)
                          CustomTextFormField(
                            labelText: 'Confirmar Senha:',
                            controller: _confirmPass,
                            key: ValueKey('confirmPassword'),
                            focusNode: _focusNodeConfirmPass,
                            validator: (value) {
                              if (value.isEmpty ||
                                  value.length < 7 ||
                                  value != _pass.text) {
                                setState(() => _confirmPasswordErrorMessage =
                                    'Senhas não conferem');
                              } else {
                                setState(
                                    () => _confirmPasswordErrorMessage = null);
                              }
                              return null;
                            },
                            errorText: _confirmPasswordErrorMessage,
                            isPassword: true,
                          ),
                        SizedBox(height: 25),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 60),
                          child: SizedBox(
                            width: double.infinity,
                            child: RaisedButton(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              disabledColor: Colors.grey,
                              onPressed: widget._isLoading
                                  ? () => {
                                        Scaffold.of(context).showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Carregando, aguarde.')))
                                      }
                                  : _submit,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
