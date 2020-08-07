import 'package:flutter/material.dart';

class ErrorMessageText extends StatelessWidget {
  final String errorMessage;

  ErrorMessageText(this.errorMessage);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 15, top: 5),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          errorMessage,
          style: TextStyle(color: Colors.red[700]),
        ),
      ),
    );
  }
}
