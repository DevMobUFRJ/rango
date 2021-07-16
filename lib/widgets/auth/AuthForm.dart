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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pass = TextEditingController();
  final TextEditingController _confirmPass = TextEditingController();

  String _name = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  File _userImageFile;
  String _emailErrorMessage;
  String _nameErrorMessage;
  String _passwordErrorMessage;
  String _confirmPasswordErrorMessage;
  final _focusNodeConfirmPass = FocusNode();
  final _focusNodePass = FocusNode();
  final _focusNodeName = FocusNode();

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
          constraints: BoxConstraints(maxHeight: 0.9.hp),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (widget._isLogin)
                  Flexible(
                    flex: 3,
                    child: Text(
                      "RANGO",
                      style: GoogleFonts.montserrat(
                        fontSize: 80.nsp,
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  ),
                Expanded(
                  flex: widget._isLogin ? 3 : 6,
                  child: Form(
                    key: _formKey,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          if (!widget._isLogin) UserImagePicker(_pickedImage),
                          Flexible(
                            flex: 2,
                            child: CustomTextFormField(
                              labelText: 'Email:',
                              key: ValueKey('email'),
                              controller: _emailController,
                              onChanged: (value) => {
                                setState(
                                  () => _email = value,
                                )
                              },
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
                              onSaved: (value) =>
                                  setState(() => _email = value),
                              keyboardType: TextInputType.emailAddress,
                              onFieldSubmitted: (_) => FocusScope.of(context)
                                  .requestFocus(!widget._isLogin
                                      ? _focusNodeName
                                      : _focusNodePass),
                              textInputAction: TextInputAction.next,
                              errorText: _emailErrorMessage,
                            ),
                          ),
                          if (!widget._isLogin)
                            Flexible(
                              flex: 2,
                              child: CustomTextFormField(
                                labelText: 'Nome',
                                errorText: _nameErrorMessage,
                                focusNode: _focusNodeName,
                                onChanged: (value) =>
                                    {setState(() => _name = value)},
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
                                onFieldSubmitted: (_) => FocusScope.of(context)
                                    .requestFocus(_focusNodePass),
                                textInputAction: TextInputAction.next,
                              ),
                            ),
                          Flexible(
                            flex: 2,
                            child: CustomTextFormField(
                              labelText: 'Senha:',
                              key: ValueKey('password'),
                              controller: _pass,
                              focusNode: _focusNodePass,
                              onChanged: (value) => {
                                setState(
                                  () => _password = value,
                                )
                              },
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
                          ),
                          if (!widget._isLogin)
                            Flexible(
                              flex: 2,
                              child: CustomTextFormField(
                                labelText: 'Confirmar Senha:',
                                controller: _confirmPass,
                                onChanged: (value) =>
                                    setState(() => _confirmPassword = value),
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
                                isPassword: true,
                              ),
                            ),
                          if (widget._isLogin)
                            Expanded(
                              flex: 1,
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
                          Flexible(
                            flex: 1,
                            child: SizedBox(
                              width: 0.7.wp,
                              child: ElevatedButton(
                                onPressed: widget._isLoading
                                    ? () => {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              duration: Duration(seconds: 2),
                                              content: Text(
                                                'Carregando, aguarde.',
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          )
                                        }
                                    : (widget._isLogin &&
                                                (_email.isEmpty ||
                                                    _password.isEmpty)) ||
                                            (!widget._isLogin &&
                                                (_email.isEmpty ||
                                                    _password.isEmpty ||
                                                    _name.isEmpty ||
                                                    _confirmPassword.isEmpty))
                                        ? null
                                        : _submit,
                                child: widget._isLoading
                                    ? Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 0.02.wp),
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
                                            vertical: 0.02.wp),
                                        child: Text(
                                          'Continuar',
                                          style: GoogleFonts.montserrat(
                                              color: Colors.white,
                                              fontSize: 36.nsp),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
