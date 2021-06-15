import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class HorariosScreen extends StatefulWidget {
  @override
  _HorariosScreenState createState() => _HorariosScreenState();
}

class _HorariosScreenState extends State<HorariosScreen> {
  final _formKey = GlobalKey<FormState>();

  String _horaSeg;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          'Horários de funcionamento',
          style: GoogleFonts.montserrat(
            color: Theme.of(context).accentColor,
            fontSize: 35.nsp,
          ),
        ),
      ),
      body: Container(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                  'Selecione as caixas referentes aos dias de abertura e então escreva os horários de funcionamento'),
              Row(
                children: [
                  Flexible(child: Text('Seg')),
                  Flexible(
                    child: Checkbox(
                      value: true,
                      onChanged: (value) => {},
                    ),
                  ),
                  Flexible(
                    child: Material(
                      shape: RoundedRectangleBorder(),
                      elevation: 1,
                      child: TextFormField(
                        decoration: InputDecoration(
                          errorStyle: TextStyle(fontSize: 22.nsp),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(left: 15),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
