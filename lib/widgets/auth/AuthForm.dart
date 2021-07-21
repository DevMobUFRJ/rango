import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rango/screens/auth/ForgotPasswordScreen.dart';
import 'package:rango/widgets/auth/CustomTextFormField.dart';
import 'package:rango/widgets/pickers/UserImagePicker.dart';

class AuthForm extends StatefulWidget {
  final void Function({
    String email,
    String name,
    File image,
    String password,
    String phone,
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

  final TextEditingController _email = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _pass = TextEditingController();
  final TextEditingController _confirmPass = TextEditingController();

  File _userImageFile;
  String _emailErrorMessage;
  String _nameErrorMessage;
  String _phoneErrorMessage;
  String _passwordErrorMessage;
  String _confirmPasswordErrorMessage;

  final _focusNodeEmail = FocusNode();
  final _focusNodeName = FocusNode();
  final _focusNodePhone = FocusNode();
  final _focusNodePass = FocusNode();
  final _focusNodeConfirmPass = FocusNode();

  void _pickedImage(File image) => _userImageFile = image;

  void _submit() {
    try {
      final isValid = _formKey.currentState.validate();
      FocusScope.of(context).unfocus();
      if (isValid &&
          _emailErrorMessage == null &&
          _nameErrorMessage == null &&
          _passwordErrorMessage == null &&
          _confirmPasswordErrorMessage == null &&
          _phoneErrorMessage == null) {
        _formKey.currentState.save();
        widget.submitForm(
          email: _email.text.trim(),
          name: _name.text.trim(),
          password: _pass.text.trim(),
          ctx: context,
          image: _userImageFile,
          phone: _phone.text.trim(),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 2),
          content: Text(
            e.toString(),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraint) => SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Container(
          constraints: BoxConstraints(minHeight: constraint.maxHeight),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                if (widget._isLogin)
                  Container(
                    child: Column(
                      children: [
                        Flexible(
                          flex: 0,
                          child: Image(
                            image: AssetImage('assets/imgs/rango.png'),
                            width: 0.5.wp,
                          ),
                        ),
                        Flexible(
                          flex: 0,
                          child: Text(
                            "RANGO",
                            style: TextStyle(
                              color: Theme.of(context).accentColor,
                              fontSize: 80.nsp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Container(
                  child: Form(
                    key: _formKey,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          if (!widget._isLogin) UserImagePicker(_pickedImage),
                          Container(
                            margin: EdgeInsets.only(bottom: 10),
                            child: CustomTextFormField(
                              labelText: 'Email',
                              focusNode: _focusNodeEmail,
                              key: ValueKey('email'),
                              validator: (value) {
                                if (value.isEmpty || !value.contains('@')) {
                                  setState(() {
                                    _emailErrorMessage =
                                        'Coloque um email válido';
                                  });
                                } else {
                                  setState(() {
                                    _emailErrorMessage = null;
                                  });
                                }
                                return null;
                              },
                              onSaved: (value) => _email.text = value,
                              keyboardType: TextInputType.emailAddress,
                              onFieldSubmitted: (_) => !widget._isLogin
                                  ? FocusScope.of(context)
                                      .requestFocus(_focusNodeName)
                                  : FocusScope.of(context)
                                      .requestFocus(_focusNodePass),
                              textInputAction: TextInputAction.next,
                              errorText: _emailErrorMessage,
                            ),
                          ),
                          if (!widget._isLogin)
                            Container(
                              margin: EdgeInsets.only(bottom: 10),
                              child: CustomTextFormField(
                                labelText: 'Nome',
                                focusNode: _focusNodeName,
                                errorText: _nameErrorMessage,
                                key: ValueKey('name'),
                                keyboardType: TextInputType.text,
                                textCapitalization: TextCapitalization.words,
                                onSaved: (value) => _name.text = value,
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
                                onFieldSubmitted: (_) => FocusScope.of(context)
                                    .requestFocus(_focusNodePhone),
                                textInputAction: TextInputAction.next,
                              ),
                            ),
                          if (!widget._isLogin)
                            Container(
                              margin: EdgeInsets.only(bottom: 10),
                              child: CustomTextFormField(
                                labelText: 'Telefone',
                                focusNode: _focusNodePhone,
                                errorText: _phoneErrorMessage,
                                maxLength: 11,
                                key: ValueKey('phone'),
                                onSaved: (value) => _phone.text = value,
                                validator: (value) {
                                  if (value.length > 0 && value.length != 11) {
                                    setState(() {
                                      _phoneErrorMessage =
                                          'Telefone precisa de 11 números';
                                    });
                                  } else {
                                    setState(() {
                                      _phoneErrorMessage = null;
                                    });
                                  }
                                  return null;
                                },
                                onFieldSubmitted: (_) => FocusScope.of(context)
                                    .requestFocus(_focusNodePass),
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                          Container(
                            margin: EdgeInsets.only(bottom: 10),
                            child: CustomTextFormField(
                              labelText: 'Senha',
                              focusNode: _focusNodePass,
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
                                  {setState(() => _pass.text = value)},
                              errorText: _passwordErrorMessage,
                              isPassword: true,
                              textInputAction: !widget._isLogin
                                  ? TextInputAction.next
                                  : TextInputAction.done,
                              onFieldSubmitted: !widget._isLogin
                                  ? (_) => FocusScope.of(context)
                                      .requestFocus(_focusNodeConfirmPass)
                                  : (_) => _submit(),
                            ),
                          ),
                          if (!widget._isLogin)
                            Container(
                              margin: EdgeInsets.only(bottom: 10),
                              child: CustomTextFormField(
                                labelText: 'Confirmar Senha',
                                controller: _confirmPass,
                                key: ValueKey('confirmPassword'),
                                focusNode: _focusNodeConfirmPass,
                                validator: (value) {
                                  if (value.isEmpty ||
                                      value.length < 7 ||
                                      value != _pass.text) {
                                    setState(() =>
                                        _confirmPasswordErrorMessage =
                                            'Senhas não conferem');
                                  } else {
                                    setState(() =>
                                        _confirmPasswordErrorMessage = null);
                                  }
                                  return null;
                                },
                                errorText: _confirmPasswordErrorMessage,
                                onSaved: (value) =>
                                    {setState(() => _confirmPass.text = value)},
                                isPassword: true,
                                onFieldSubmitted: (_) => _submit(),
                              ),
                            ),
                          if (widget._isLogin)
                            Container(
                              margin: EdgeInsets.only(bottom: 10),
                              child: TextButton(
                                onPressed: () => Navigator.of(context)
                                    .pushNamed(ForgotPasswordScreen.routeName),
                                child: Text(
                                  'Esqueceu a senha?',
                                  style: GoogleFonts.montserrat(
                                    decoration: TextDecoration.underline,
                                    color: Color(0xFF72A69C),
                                  ),
                                ),
                              ),
                            ),
                          SizedBox(
                            width: 0.5.wp,
                            child: ElevatedButton(
                              onPressed: widget._isLoading ? null : _submit,
                              child: widget._isLoading
                                  ? SizedBox(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            new AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                        strokeWidth: 3.0,
                                      ),
                                      height: 40.w,
                                      width: 40.w,
                                    )
                                  : Container(
                                      child: Text(
                                        'Continuar',
                                        style: GoogleFonts.montserrat(
                                            color: Colors.white,
                                            fontSize: 36.nsp),
                                      ),
                                    ),
                            ),
                          ),
                        ],
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
}
