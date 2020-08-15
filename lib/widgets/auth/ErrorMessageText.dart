import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ErrorMessageText extends StatelessWidget {
  final String errorMessage;

  ErrorMessageText(this.errorMessage);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334);
    return Padding(
      padding: EdgeInsets.only(left: 15, top: 5),
      child: Align(
        alignment: Alignment.centerLeft,
        child: AutoSizeText(
          errorMessage,
          maxLines: 1,
          style: GoogleFonts.montserrat(
            color: Colors.red[700],
            fontSize: 26.nsp,
          ),
        ),
      ),
    );
  }
}
