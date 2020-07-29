import 'package:flutter/material.dart';

class AuthForm extends StatefulWidget {
  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Form(
            // key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  key: ValueKey('email'),
                  validator: (value) {
                    if (value.isEmpty || !value.contains('@')) {
                      return 'Please enter a valid email addres';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: 'Email address'),
                ),
                TextFormField(
                  key: ValueKey('username'),
                  validator: (value) {
                    if (value.isEmpty || value.length < 4) {
                      return 'Please enter at least 4 chars';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Username',
                  ),
                ),
                TextFormField(
                  key: ValueKey('password'),
                  validator: (value) {
                    if (value.isEmpty || value.length < 7) {
                      return 'Password must be at least 7 chars long';
                    }
                    return null;
                  },
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                SizedBox(height: 12),
                RaisedButton(
                  onPressed: () {},
                  child: Text('Continuar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
