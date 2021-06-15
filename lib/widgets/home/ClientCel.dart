import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ClientCel extends StatelessWidget {
  final String clientCel;

  ClientCel({
    @required this.clientCel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //TODO clicar e copiar para área de transferência
      onTap: () {
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text('teste'),
            duration: const Duration(seconds: 1),
            action: SnackBarAction(
              label: 'ACTION',
              onPressed: () {},
            ),
          ),
        );
      },
      child: Container(
        child: AutoSizeText(
          clientCel,
          maxLines: 1,
          style: GoogleFonts.montserrat(
            fontSize: 30.nsp,
          ),
        ),
      ),
    );
  }
}
