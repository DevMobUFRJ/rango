import 'package:flutter/material.dart';

void showSnackbar(context, bool error, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: Duration(seconds: 2),
      backgroundColor: error == true
          ? Theme.of(context).errorColor
          : Theme.of(context).accentColor,
      content: Text(
        message,
        textAlign: TextAlign.center,
      ),
    ),
  );
}
