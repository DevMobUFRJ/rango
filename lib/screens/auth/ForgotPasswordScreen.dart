import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rango/widgets/auth/CustomTextFormField.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static const routeName = '/forgot-password';
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String _email;
  String _emailErrorMessage;

  Future<void> _submit(BuildContext ctx) async {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(ctx).unfocus();
    if (isValid && _emailErrorMessage == null) {
      _formKey.currentState.save();
      try {
        final firebaseAuth = FirebaseAuth.instance;
        await firebaseAuth.sendPasswordResetEmail(email: _email);
        ScaffoldMessenger.of(context)
            .showSnackBar(
              SnackBar(
                backgroundColor: Theme.of(ctx).accentColor,
                content: Text(
                  'Email enviado',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                      color: Colors.white, fontSize: 28.nsp),
                ),
              ),
            )
            .closed
            .then((value) => Navigator.of(ctx).pop());
      } catch (error) {
        print(error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: AutoSizeText(
          'Esqueceu a senha',
          maxLines: 1,
          style: GoogleFonts.montserrat(
            color: Theme.of(context).accentColor,
            fontSize: 35.nsp,
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 0.1.wp),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
              flex: 1,
              child: Text(
                "RANGO",
                style: GoogleFonts.montserrat(
                  fontSize: 80.nsp,
                  color: Theme.of(context).accentColor,
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: AutoSizeText(
                "Preencha o campo abaixo para receber o email de recuperação de senha",
                style: GoogleFonts.montserrat(
                  fontSize: 30.nsp,
                  color: Theme.of(context).accentColor,
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: Form(
                key: _formKey,
                child: CustomTextFormField(
                  labelText: 'Email',
                  key: ValueKey('email'),
                  onChanged: (value) => setState(() => _email = value),
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
                  textInputAction: TextInputAction.done,
                  errorText: _emailErrorMessage,
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: ElevatedButton(
                onPressed: _email == null ? null : () => _submit(context),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 0.1.wp,
                    vertical: 0.01.hp,
                  ),
                  child: AutoSizeText(
                    'Confirmar',
                    style: GoogleFonts.montserrat(
                        fontSize: 36.nsp, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
