import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rango/resources/repository.dart';
import 'package:rango/utils/constants.dart';
import 'package:rango/widgets/auth/CustomTextFormField.dart';

class EditAccountScreen extends StatefulWidget {
  EditAccountScreen();

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditAccountScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _email = TextEditingController();
  TextEditingController _actualPass = TextEditingController();
  TextEditingController _pass = TextEditingController();
  TextEditingController _confirmPass = TextEditingController();

  String _emailErrorMessage;
  String _actualPasswordErrorMessage;
  String _passwordErrorMessage;
  String _confirmPasswordErrorMessage;

  final _actualPassFocusNode = FocusNode();
  final _passFocusNode = FocusNode();
  final _confirmPassFocusNode = FocusNode();

  bool _loading = false;
  User _user;

  @override
  void initState() {
    setState(() {
      _user = FirebaseAuth.instance.currentUser;
      _email = TextEditingController(text: FirebaseAuth.instance.currentUser.email);
    });
    super.initState();
  }

  void _submit(BuildContext context) async {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();
    if (isValid &&
        _emailErrorMessage == null &&
        _passwordErrorMessage == null &&
        _confirmPasswordErrorMessage == null &&
        _actualPasswordErrorMessage == null) {
      _formKey.currentState.save();
      bool hasChanges = _email.text.trim() != _user.email || _pass.text.trim().isNotEmpty;
      if (!hasChanges) {
        return;
      }
      setState(() => _loading = true);
      try {
        String newEmail = _user.email;
        String newPassword = _actualPass.text;
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: _user.email, password: _actualPass.text);

        if (_email.text.trim() != _user.email) {
          await _user.updateEmail(_email.text.trim());
          await Repository.instance.updateSeller(_user.uid, {'email': _email.text.trim()});
          newEmail = _email.text.trim();
        }
        if (_pass.text.trim().isNotEmpty) {
          await _user.updatePassword(_pass.text);
          newPassword = _pass.text;
        }

        await FirebaseAuth.instance.signInWithEmailAndPassword(email: newEmail, password: newPassword);

        setState(() {
          _loading = false;
        });
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 2),
            backgroundColor: Theme.of(context).accentColor,
            content: Text(
              'Conta atualizada com sucesso',
              textAlign: TextAlign.center,
            ),
          ),
        );
      } on FirebaseAuthException catch (error) {
        setState(() => _loading = false);
        String errorText = '';
        switch (error.code) {
          case 'wrong-password':
            errorText = wrongPasswordErrorMessage;
            break;
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
        if (errorText.isNotEmpty) {
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
        }
        print(error);
      } catch (error) {
        setState(() => _loading = false);
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
        print(error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          'Editar Conta',
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
                      CustomTextFormField(
                        labelText: 'Email *',
                        keyboardType: TextInputType.emailAddress,
                        key: ValueKey('email'),
                        controller: _email,
                        validator: (String value) {
                          _emailErrorMessage = null;
                          if (value == '') {
                            _emailErrorMessage = 'Email não pode ser vazio!';
                          } else if (!value.contains('@')) {
                            _emailErrorMessage = 'Insira um email válido';
                          }
                          return _emailErrorMessage;
                        },
                        errorText: _emailErrorMessage,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => FocusScope.of(context)
                            .requestFocus(_actualPassFocusNode),
                      ),
                      CustomTextFormField(
                        labelText: 'Senha atual *',
                        controller: _actualPass,
                        focusNode: _actualPassFocusNode,
                        isPassword: true,
                        onFieldSubmitted: (_) => FocusScope.of(context)
                            .requestFocus(_passFocusNode),
                        textInputAction: TextInputAction.next,
                        key: ValueKey('actualPassword'),
                        validator: (String value) {
                          _actualPasswordErrorMessage = null;
                          if (value.isEmpty || value.length < 7) {
                            _actualPasswordErrorMessage = 'Senha precisa ter pelo menos 7 caracteres';
                          }
                          return null;
                        },
                        errorText: _actualPasswordErrorMessage,
                      ),
                      CustomTextFormField(
                        labelText: 'Nova senha',
                        controller: _pass,
                        focusNode: _passFocusNode,
                        isPassword: true,
                        onFieldSubmitted: (_) => FocusScope.of(context)
                            .requestFocus(_confirmPassFocusNode),
                        textInputAction: TextInputAction.next,
                        key: ValueKey('password'),
                        validator: (String value) {
                          _passwordErrorMessage = null;
                          if (value != '' && value.length < 7) {
                            _passwordErrorMessage = 'Senha precisa ter pelo menos 7 caracteres';
                          }
                          return null;
                        },
                        errorText: _passwordErrorMessage,
                      ),
                      CustomTextFormField(
                        labelText: 'Confirmar senha',
                        focusNode: _confirmPassFocusNode,
                        controller: _confirmPass,
                        isPassword: true,
                        key: ValueKey('confirmPassword'),
                        validator: (String value) {
                          _confirmPasswordErrorMessage = null;
                          if (value != '' && value.length < 7) {
                            _confirmPasswordErrorMessage = 'Senha precisa ter pelo menos 7 caracteres';
                          } else if (_pass.text != '' && value != _pass.text) {
                            _confirmPasswordErrorMessage = 'Senhas não conferem';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) => _submit(ctx),
                        errorText: _confirmPasswordErrorMessage,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 0.05.wp, vertical: 0.01.hp),
                        child: SizedBox(
                          width: 0.5.wp,
                          child: ElevatedButton(
                            onPressed: _loading
                                ? null
                                : () => _submit(ctx),
                            child: _loading
                                ? SizedBox(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                                strokeWidth: 3.0,
                              ),
                              height: 30.w,
                              width: 30.w,
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
            )
        ),
      ),
    );
  }
}
