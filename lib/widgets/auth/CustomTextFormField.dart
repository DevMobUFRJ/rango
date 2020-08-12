import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:rango/widgets/auth/ErrorMessageText.dart';

class CustomTextFormField extends StatefulWidget {
  final String labelText;
  final TextInputAction textInputAction;
  final Function onFieldSubmitted;
  final ValueKey key;
  final Function validator;
  final Function(String) onSaved;
  final TextInputType keyboardType;
  final String errorText;
  final bool isPassword;
  final TextEditingController controller;
  final FocusNode focusNode;

  CustomTextFormField({
    @required this.labelText,
    this.textInputAction,
    this.onFieldSubmitted,
    @required this.key,
    @required this.validator,
    this.onSaved,
    this.keyboardType,
    @required this.errorText,
    this.isPassword = false,
    this.controller,
    this.focusNode,
  });

  @override
  _CustomTextFormFieldState createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 10, bottom: 10),
            child: Text(
              widget.labelText,
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
            focusNode: widget.focusNode != null ? widget.focusNode : null,
            controller: widget.controller,
            textInputAction: widget.textInputAction,
            onFieldSubmitted: widget.onFieldSubmitted,
            key: widget.key,
            validator: widget.validator,
            onSaved: widget.onSaved,
            obscureText: widget.isPassword != null && !widget.isPassword
                ? false
                : !_showPassword,
            decoration: InputDecoration(
              errorStyle: TextStyle(fontSize: 16),
              border: InputBorder.none,
              contentPadding: widget.isPassword != null && widget.isPassword
                  ? EdgeInsets.all(15)
                  : EdgeInsets.only(left: 15),
              suffixIcon: widget.isPassword != null && widget.isPassword
                  ? IconButton(
                      icon: Icon(!_showPassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () =>
                          setState(() => _showPassword = !_showPassword),
                    )
                  : null,
            ),
            keyboardType: widget.keyboardType,
          ),
        ),
        if (widget.errorText != null) ErrorMessageText(widget.errorText),
      ],
    );
  }
}
