import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  final Function(String) onChanged;
  final num numberOfLines;
  final int maxLength;

  CustomTextFormField({
    @required this.labelText,
    this.textInputAction,
    this.onFieldSubmitted,
    @required this.key,
    this.validator,
    this.onSaved,
    this.keyboardType,
    this.errorText,
    this.isPassword = false,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.numberOfLines = 1,
    this.maxLength,
  });

  @override
  _CustomTextFormFieldState createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 0.05.wp, bottom: 0.01.hp),
              child: Text(
                widget.labelText,
                style: TextStyle(
                  fontSize: 38.nsp,
                  color: Theme.of(context).accentColor,
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
              cursorColor: Theme.of(context).accentColor,
              onSaved: widget.onSaved,
              onChanged: widget.onChanged,
              maxLength: widget.maxLength,
              minLines: 1,
              maxLines: widget.numberOfLines,
              obscureText: widget.isPassword != null && !widget.isPassword
                  ? false
                  : !_showPassword,
              decoration: InputDecoration(
                counterText: "",
                errorStyle: TextStyle(fontSize: 22.nsp),
                border: InputBorder.none,
                contentPadding: widget.isPassword != null && widget.isPassword
                    ? EdgeInsets.all(15)
                    : EdgeInsets.only(left: 15),
                suffixIcon: widget.isPassword != null && widget.isPassword
                    ? IconButton(
                        icon: Icon(
                          !_showPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Theme.of(context).accentColor,
                        ),
                        onPressed: () =>
                            {setState(() => _showPassword = !_showPassword)},
                      )
                    : null,
              ),
              keyboardType: widget.keyboardType,
            ),
          ),
          if (widget.errorText != null) ErrorMessageText(widget.errorText),
        ],
      ),
    );
  }
}
