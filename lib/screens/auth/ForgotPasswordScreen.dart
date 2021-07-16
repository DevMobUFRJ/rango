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
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String _email;
  String _emailErrorMessage;

  Future<void> _submit(BuildContext ctx) async {
    setState(() => _loading = true);
    final isValid = _formKey.currentState.validate();
    FocusScope.of(ctx).unfocus();
    if (isValid && _emailErrorMessage == null) {
      _formKey.currentState.save();
      try {
        final firebaseAuth = FirebaseAuth.instance;
        await firebaseAuth.sendPasswordResetEmail(email: _email);
        setState(() => _loading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(
              SnackBar(
                backgroundColor: Theme.of(ctx).accentColor,
                duration: Duration(seconds: 2),
                content: Text(
                  'Email enviado',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 28.nsp,
                  ),
                ),
              ),
            )
            .closed
            .then(
              (value) => Navigator.of(ctx).pop(),
            );
      } catch (error) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(ctx).accentColor,
            duration: Duration(seconds: 2),
            content: Text(
              'Erro ao enviar email de recuperação',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 28.nsp,
              ),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              flex: 1,
              child: Column(
                children: [
                  Flexible(
                    flex: 1,
                    child: Image(image: AssetImage('assets/imgs/rango.png')),
                  ),
                  Flexible(
                    flex: 1,
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
            Flexible(
              flex: 1,
              child: AutoSizeText(
                "Preencha abaixo para receber o email de recuperação de senha",
                style: GoogleFonts.montserrat(
                  fontSize: 30.nsp,
                  color: Theme.of(context).accentColor,
                ),
              ),
            ),
            Flexible(
              flex: 0,
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
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                width: 0.4.wp,
                child: ElevatedButton(
                  onPressed: _email == null || _loading
                      ? null
                      : () => _submit(context),
                  child: _loading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : AutoSizeText(
                          'Confirmar',
                          style: GoogleFonts.montserrat(
                            fontSize: 36.nsp,
                            color: Colors.white,
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
}
