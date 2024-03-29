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
  final Function(String) onChanged;
  final TextEditingController controller;
  final FocusNode focusNode;
  final int numberOfLines;
  final int maxLength;
  final TextCapitalization textCapitalization;

  CustomTextFormField({
    @required this.labelText,
    this.textInputAction,
    this.onFieldSubmitted,
    @required this.key,
    @required this.validator,
    this.onChanged,
    this.onSaved,
    this.keyboardType,
    @required this.errorText,
    this.isPassword = false,
    this.controller,
    this.focusNode,
    this.numberOfLines = 1,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
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
          elevation: 3,
          child: TextFormField(
            focusNode: widget.focusNode != null ? widget.focusNode : null,
            controller: widget.controller,
            textInputAction: widget.textInputAction,
            onFieldSubmitted: widget.onFieldSubmitted,
            key: widget.key,
            textCapitalization: widget.textCapitalization,
            validator: widget.validator,
            onSaved: widget.onSaved,
            maxLength: widget.maxLength,
            minLines: 1,
            cursorColor: Theme.of(context).accentColor,
            onChanged: widget.onChanged,
            maxLines: widget.numberOfLines,
            obscureText: widget.isPassword != null && !widget.isPassword
                ? false
                : !_showPassword,
            decoration: InputDecoration(
              errorStyle: TextStyle(fontSize: 22.nsp),
              counterText: '',
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
    );
  }
}
